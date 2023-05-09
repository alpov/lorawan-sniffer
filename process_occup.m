function  process_occup(name)


% nr,time_epoch,len,srcgw,crc,rssi,snr,frequency,sf,cr,ftype,devaddr,fport,fcnt
% 1,1659362668.811991000,27,1,1,-108.0,0.0,867100000,11,5,2,654426274,8,36916

%close all;
%clear all;
%name = '../loralog/csv/03_Brno_join_valid';

M = [0.75 0.525 0;     0.216 0.146 0;     8.266 10.031 0;     5.463 4.136 0;     0.597 0.574 10.434;     2.929 1.672 0.12;     10.037 8.937 7.342;     3.483 3.509 8.157];

M2 = [0.13 0.158 0.138 0.155 0.169 0.175 0.203 0.146 0;     0.128 0.143 0.076 0.122 0.127 0.23 0.189 0.155 10.434;     0.048 0.044 0.041 0.045 0.038 0.049 0.048 0.049 0;     0.732 0.714 0.076 0.623 0.784 0.674 0.402 0.596 0.12;     1.736 2.046 0.852 1.944 1.687 3.897 2.799 3.335 0;     1.941 2.323 0.475 2.42 2.879 3.383 2.683 2.871 7.342;     1.11 1.137 1.012 1.121 1.082 1.231 1.216 1.688 0;     0.77 0.766 0.534 0.752 0.662 0.997 1.316 1.197 8.157];

font = 12;

%% Histogram of channel occupation
figure();
c1 = M(1:4,1)';
c2 = M(1:4,2)';
c = c1+c2;
bar([c1' c2']);
set(gca, 'xticklabel', {'Liege', 'Graz', 'Vienna', 'Brno'});
ylabel('Channel utilization [%]'); grid on;
legend('band L', 'band M');
set(findall(gcf,'-property','FontSize'),'FontSize',font)
print(strcat(name, '_01'), '-dpng');

%% Histogram of channel occupation
figure();
c1 = M(5:8,1)';
c2 = M(5:8,2)';
c3 = M(5:8,3)';
c = c1+c2+c3;
bar([c1' c2' c3']);
set(gca, 'xticklabel', {'Liege', 'Graz', 'Vienna', 'Brno'});
ylabel('Channel utilization [%]'); grid on;
legend('band L', 'band M', 'band P');
set(findall(gcf,'-property','FontSize'),'FontSize',font)
print(strcat(name, '_02'), '-dpng');

