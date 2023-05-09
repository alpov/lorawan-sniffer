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
#include "loratap1.h"
#include "base64.h"

#define LINKTYPE_LORA_LORATAP 270

#define LORATAP_V0_HEADER_LENGTH (15)
#define LORATAP_V1_HEADER_LENGTH (sizeof(loratap_header_t))

typedef struct pcap_hdr_s {
    uint32_t magic_number;   /* magic number */
    uint16_t version_major;  /* major version number */
    uint16_t version_minor;  /* minor version number */
    int32_t  thiszone;       /* GMT to local correction */
    uint32_t sigfigs;        /* accuracy of timestamps */
    uint32_t snaplen;        /* max length of captured packets, in octets */
    uint32_t network;        /* data link type */
} pcap_hdr_t;

typedef struct pcaprec_hdr_s {
    uint32_t ts_sec;         /* timestamp seconds */
    uint32_t ts_usec;        /* timestamp microseconds */
    uint32_t incl_len;       /* number of octets of packet saved in file */
    uint32_t orig_len;       /* actual length of packet */
} pcaprec_hdr_t;


int main(int argc, char *argv[])
{
    FILE *captureFile;
    pcap_hdr_t file_header;
    FILE *inputFile;
    char *line = NULL;
    size_t len = 0;
    bool enable_v1 = false;
    
    if (argc != 4) {
        printf("Usage: %s {v0|v1} input_file output_file\n", argv[0]);
        return 0;
    }
    
    if (strcmp(argv[1], "v1") == 0) {
        enable_v1 = true;
    }
    
    inputFile = fopen(argv[2], "r");
    
    /* Create pcap with header */
    captureFile = fopen(argv[3], "w");
    file_header.magic_number = 0xa1b2c3d4;
    file_header.version_major = 2;
    file_header.version_minor = 4;
    file_header.thiszone = 0;
    file_header.sigfigs = 0;
    file_header.snaplen = 255;
    file_header.network = LINKTYPE_LORA_LORATAP;
    fwrite(&file_header, sizeof(pcap_hdr_t), 1, captureFile);
    
    while (getline(&line, &len, inputFile) != -1) {
        if (strlen(line) < 20) continue;
        char *addr_txt = line; addr_txt[18] = '\0';
        int gwid = atoi(addr_txt + 16);
        char *json_txt = line + 20;
        //printf("addr: '%s', json: '%s'\n", addr_txt, json_txt);

        cJSON *json = cJSON_Parse(json_txt);
        const cJSON *rxpk = NULL;
        cJSON_ArrayForEach(rxpk, cJSON_GetObjectItemCaseSensitive(json, "rxpk")) {
            if (!cJSON_HasObjectItem(rxpk, "time")) {
                printf("-");
                continue;
            }
            
            double	tmst = cJSON_GetObjectItemCaseSensitive(rxpk, "tmst")->valuedouble;
            char *	time = cJSON_GetObjectItemCaseSensitive(rxpk, "time")->valuestring;
            //int	tmms = cJSON_GetObjectItemCaseSensitive(rxpk, "tmms")->valueint;
            int		chan = cJSON_GetObjectItemCaseSensitive(rxpk, "chan")->valueint;
            int		rfch = cJSON_GetObjectItemCaseSensitive(rxpk, "rfch")->valueint;
            double	freq = cJSON_GetObjectItemCaseSensitive(rxpk, "freq")->valuedouble;
            int		stat = cJSON_GetObjectItemCaseSensitive(rxpk, "stat")->valueint;
            char *	modu = cJSON_GetObjectItemCaseSensitive(rxpk, "modu")->valuestring;
            char *	datr = cJSON_GetObjectItemCaseSensitive(rxpk, "datr")->valuestring;
            char *	codr = cJSON_GetObjectItemCaseSensitive(rxpk, "codr")->valuestring;
            double	lsnr = cJSON_GetObjectItemCaseSensitive(rxpk, "lsnr")->valuedouble;
            double	rssi = cJSON_GetObjectItemCaseSensitive(rxpk, "rssi")->valuedouble;
            int		size = cJSON_GetObjectItemCaseSensitive(rxpk, "size")->valueint;
            char *	data = cJSON_GetObjectItemCaseSensitive(rxpk, "data")->valuestring;
            
            int sf = 0, bw = 0;
            sscanf(datr, "SF%dBW%d", &sf, &bw);
            
            int cr = 0;
            if (strcmp(codr, "OFF") != 0) {
                sscanf(codr, "4/%d", &cr);
            }
            
            if (gwid == 3 && chan == 8 && stat == 0) {
                printf("b"); // Implicit
                if (!enable_v1) {
                    continue; // do not pass Class-B beacons
                }
            } else if (stat == -1) {
                printf("X"); // CRC Bad
                if (!enable_v1) {
                    continue; // do not pass packets with wrong CRC
                }
            } else if (stat == 0) {
                printf("-"); // No CRC
            } else {
                printf("."); // CRC OK
            }
            
            struct tm tm;
            strptime(time, "%Y-%m-%dT%H:%M:%S", &tm);
            
            /* Write header */
            pcaprec_hdr_t pcap_packet_header = {0};
            pcap_packet_header.ts_sec = timegm(&tm) + 1; // added 1 second because time is taken from NMEA, which is 1 second behind UBX
            pcap_packet_header.ts_usec = atoi(&time[20]);
            pcap_packet_header.incl_len = size + (enable_v1 ? LORATAP_V1_HEADER_LENGTH : LORATAP_V0_HEADER_LENGTH);
            pcap_packet_header.orig_len = size + (enable_v1 ? LORATAP_V1_HEADER_LENGTH : LORATAP_V0_HEADER_LENGTH);
            fwrite(&pcap_packet_header, sizeof(pcaprec_hdr_t), 1, captureFile);
            
            /* Write packet */
            loratap_header_t loratap_packet_header = {0};
            loratap_packet_header.lt_version = enable_v1 ? 1 : 0;
            loratap_packet_header.lt_length = enable_v1 ? htons(LORATAP_V1_HEADER_LENGTH) : htons(LORATAP_V0_HEADER_LENGTH);
            loratap_packet_header.channel.frequency = htonl((uint32_t)(freq * 1000000.));
            loratap_packet_header.channel.bandwidth = bw / 125;
            loratap_packet_header.channel.sf = sf;
            loratap_packet_header.rssi.packet_rssi = 255;
            loratap_packet_header.rssi.current_rssi = (uint8_t)(rssi + 139.);
            loratap_packet_header.rssi.max_rssi = 255;
            loratap_packet_header.rssi.snr = (uint8_t)(lsnr * 4.);
            loratap_packet_header.sync_word = 0x34; // always LoRaWAN, was: (chan == 8) ? 0xAA : 0x34;
            loratap_packet_header.source_gw = bswap_64(strtoull(addr_txt, NULL, 0));
            loratap_packet_header.timestamp = htonl((uint32_t)tmst); // valueint clips to int32_t, have to use double
            loratap_packet_header.flags.mod_fsk = (strcmp(modu, "FSK") == 0) ? 1 : 0;
            loratap_packet_header.flags.iq_inverted = (gwid == 2 || (gwid == 3 && chan != 8)) ? 1 : 0; // Downlink is inverted, uplink and beacon non-inverted
            loratap_packet_header.flags.implicit_hdr = (gwid == 3 && chan == 8 && stat == 0) ? 1 : 0; // Implicit header on channel 8 with CRC check disabled
            loratap_packet_header.flags.crc_ok = (stat == 1) ? 1 : 0;
            loratap_packet_header.flags.crc_bad = (stat == -1) ? 1 : 0;
            loratap_packet_header.flags.no_crc = (stat == 0) ? 1 : 0;
            loratap_packet_header.cr = cr;
            loratap_packet_header.datarate = htons(atoi(datr));
            loratap_packet_header.if_channel = chan;
            loratap_packet_header.rf_chain = rfch;
            loratap_packet_header.tag = 0; // reserved
            fwrite(&loratap_packet_header, enable_v1 ? LORATAP_V1_HEADER_LENGTH : LORATAP_V0_HEADER_LENGTH, 1, captureFile);
            
            /* Write payload */
            char data_raw[2048];
            int data_len = Base64decode(data_raw, data);
            assert(size == data_len);
            fwrite(data_raw, size, 1, captureFile);
        }
        cJSON_Delete(json);
    }
    
    fclose(inputFile);
    fclose(captureFile);
    free(line);
    printf("\ndone\n");
    
    return 0;
}
