#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <assert.h>
#include <math.h>
#define __USE_XOPEN
#include <time.h>
#include <byteswap.h>
#include <arpa/inet.h>
#include <cjson/cJSON.h>

#define TM_FORMAT "%d.%d.%d %.2d:%.2d:%.2d"
#define TM_DATA(x) (x)->tm_mday, (x)->tm_mon+1, (x)->tm_year+1900, (x)->tm_hour, (x)->tm_min, (x)->tm_sec


int main(int argc, char *argv[])
{
    FILE *inputFile;
    char *line = NULL;
    size_t len = 0;
    int linenr = 0, linenr_saved = 0;
    struct tm scan_time = {}, scan_time_saved = {};
    int scan_gwcount[3] = { 0, 0, 0 };
    
    if (argc != 2) {
        printf("Usage: %s input_file\n", argv[0]);
        return 0;
    }
    
    inputFile = fopen(argv[1], "r");
    
    while (getline(&line, &len, inputFile) != -1) {
        linenr++;
        if (strstr(line, "util_ack listening") != NULL) {
            int dur = difftime(mktime(&scan_time), mktime(&scan_time_saved));
            printf("--\nStart at line %d from " TM_FORMAT ", packets: %d, %d, %d, elapsed: %dh %dm\n", linenr_saved, TM_DATA(&scan_time_saved), scan_gwcount[0], scan_gwcount[1], scan_gwcount[2], dur/3600, dur/60%60);
            memcpy(&scan_time_saved, &scan_time, sizeof(scan_time));
            memset(scan_gwcount, 0, sizeof(scan_gwcount));
            continue;
        }
        if (strlen(line) < 20) continue;
        char *addr_txt = line; addr_txt[18] = '\0';
        char *json_txt = line + 20;
        //printf("addr: '%s', json: '%s'\n", addr_txt, json_txt);

        cJSON *json = cJSON_Parse(json_txt);
        const cJSON *rxpk = NULL;
        cJSON_ArrayForEach(rxpk, cJSON_GetObjectItemCaseSensitive(json, "rxpk")) {
            if (!cJSON_HasObjectItem(rxpk, "time")) continue;
            
            //double	tmst = cJSON_GetObjectItemCaseSensitive(rxpk, "tmst")->valuedouble;
            char *	time = cJSON_GetObjectItemCaseSensitive(rxpk, "time")->valuestring;
            //int	tmms = cJSON_GetObjectItemCaseSensitive(rxpk, "tmms")->valueint;
            //int	chan = cJSON_GetObjectItemCaseSensitive(rxpk, "chan")->valueint;
            //int	rfch = cJSON_GetObjectItemCaseSensitive(rxpk, "rfch")->valueint;
            //double	freq = cJSON_GetObjectItemCaseSensitive(rxpk, "freq")->valuedouble;
            //int	stat = cJSON_GetObjectItemCaseSensitive(rxpk, "stat")->valueint;
            //char *	modu = cJSON_GetObjectItemCaseSensitive(rxpk, "modu")->valuestring;
            //char *	datr = cJSON_GetObjectItemCaseSensitive(rxpk, "datr")->valuestring;
            //char *	codr = cJSON_GetObjectItemCaseSensitive(rxpk, "codr")->valuestring;
            //double	lsnr = cJSON_GetObjectItemCaseSensitive(rxpk, "lsnr")->valuedouble;
            //double	rssi = cJSON_GetObjectItemCaseSensitive(rxpk, "rssi")->valuedouble;
            //int	size = cJSON_GetObjectItemCaseSensitive(rxpk, "size")->valueint;
            //char *	data = cJSON_GetObjectItemCaseSensitive(rxpk, "data")->valuestring;
            
            struct tm tm;
            strptime(time, "%Y-%m-%dT%H:%M:%S", &tm);
            
            if (tm.tm_year+1900 < 2020) continue; // ignore invalid dates
            memcpy(&scan_time, &tm, sizeof(tm));
            if (scan_gwcount[0] == 0 && scan_gwcount[1] == 0 && scan_gwcount[2] == 0) {
                printf("Valid at line %d from " TM_FORMAT ", gap: %ds\n", linenr, TM_DATA(&scan_time), (int)difftime(mktime(&scan_time), mktime(&scan_time_saved)));
                memcpy(&scan_time_saved, &scan_time, sizeof(scan_time));
                linenr_saved = linenr;
            }
            
            if (strcmp(addr_txt, "0xB827EBAFAC000001") == 0) scan_gwcount[0]++;
            else if (strcmp(addr_txt, "0xB827EBAFAC000002") == 0) scan_gwcount[1]++;
            else if (strcmp(addr_txt, "0xB827EBAFAC000003") == 0) scan_gwcount[2]++;
        }
        cJSON_Delete(json);
    }
    
    fclose(inputFile);
    free(line);
    
    int dur = difftime(mktime(&scan_time), mktime(&scan_time_saved));
    printf("--\nEnd   at line %d from " TM_FORMAT ", packets: %d, %d, %d, elapsed: %dh %dm\n", linenr, TM_DATA(&scan_time), scan_gwcount[0], scan_gwcount[1], scan_gwcount[2], dur/3600, dur/60%60);
    
    return 0;
}
