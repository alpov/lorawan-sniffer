function  process_valid(name)


% nr,time_epoch,len,srcgw,crc,rssi,snr,frequency,sf,cr,ftype,devaddr,fport,fcnt
% 1,1659362668.811991000,27,1,1,-108.0,0.0,867100000,11,5,2,654426274,8,36916

%close all;
%clear all;
%name = '../loralog/csv/03_Brno_join_valid';

M = readmatrix(strcat(name, '.csv'), 'TreatAsMissing', 'NaN');
numdays = days(datetime(M(end,2), 'ConvertFrom', 'posixtime')-datetime(M(1,2), 'ConvertFrom', 'posixtime'));

% Extract city and type from filename
[~, filename, ~] = fileparts(name);
[city, type] = strtok(filename(4:end), '_');
type = type(2:end);

% Replace underscores with spaces and format output string
type = strrep(type, '_', ' ');
name4title = sprintf('%s (%s)', city, type);
font = 12;

%% Histogram of spreading factor usage of all packets
figure();
edges = 6.5:1:12.5; col = 9;
c1 = (histcounts(M(M(:,4)==1,col), edges) ./ numdays);
c2 = (histcounts(M(M(:,4)==2,col), edges) ./ numdays);
c3 = (histcounts(M(M(:,4)==3,col), edges) ./ numdays);
c = c1+c2+c3;
bar([c1' c2' c3'], 'Stacked', 'BarWidth', 0.7);
set(gca, 'xticklabel', {'SF7', 'SF8', 'SF9', 'SF10', 'SF11', 'SF12'});
%xlabel('Spreading factor'); 
ylabel('Packet count per day'); grid on;
text(1:length(c), c, num2str(round(c')), 'vert', 'bottom', 'horiz', 'center');
legend('Uplink', 'Downlink RX1', 'Downlink RX2');
%title(name4title,'Interpreter','none');
set(findall(gcf,'-property','FontSize'),'FontSize',font)
print(strcat(name, '_01'), '-dpng');

%% Histogram of coding ratio
figure();
edges = 4.5:1:8.5; col = 10;
c1 = (histcounts(M(M(:,4)==1,col), edges) ./ numdays);
c2 = (histcounts(M(M(:,4)==2,col), edges) ./ numdays);
c3 = (histcounts(M(M(:,4)==3,col), edges) ./ numdays);
c = c1+c2+c3;
bar([c1' c2' c3'], 'Stacked', 'BarWidth', 0.7);
set(gca, 'xticklabel', {'CR 4/5', 'CR 4/6', 'CR 4/7', 'CR 4/8'});
%xlabel('Coding ratio'); 
ylabel('Packet count per day'); grid on;
text(1:length(c), c, num2str(round(c')), 'vert', 'bottom', 'horiz', 'center');
legend('Uplink', 'Downlink RX1', 'Downlink RX2');
%title(name4title,'Interpreter','none');
set(findall(gcf,'-property','FontSize'),'FontSize',font)
print(strcat(name, '_02'), '-dpng');

%% Histogram of frequency channels usage of all packets
figure();
edges = 1e6.*[867.0 867.2 867.4 867.6 867.8 868.0 868.2 868.4 868.6 869.6]; col = 8;
c1 = (histcounts(M(M(:,4)==1,col), edges) ./ numdays);
c2 = (histcounts(M(M(:,4)==2,col), edges) ./ numdays);
c3 = (histcounts(M(M(:,4)==3,col), edges) ./ numdays);
c = c1+c2+c3;
bar([c1' c2' c3'], 'Stacked', 'BarWidth', 0.7);
set(gca, 'xticklabel', {'867.1', '867.3', '867.5', '867.7', '867.9', '868.1', '868.3', '868.5', '869.525'});
xtickangle(45);
xlabel('Frequency [MHz]'); ylabel('Packet count per day'); grid on;
text(1:length(c), c, num2str(round(c')), 'vert', 'bottom', 'horiz', 'center');
legend('Uplink', 'Downlink RX1', 'Downlink RX2');
%title(name4title,'Interpreter','none');
set(findall(gcf,'-property','FontSize'),'FontSize',font)
print(strcat(name, '_03'), '-dpng');

%% Histogram of RSSI
figure();
edges = -131:2:-49; col = 6;
c1 = (histcounts(M(M(:,4)==1,col), edges) ./ numdays);
c2 = (histcounts(M(M(:,4)==2,col), edges) ./ numdays);
c3 = (histcounts(M(M(:,4)==3,col), edges) ./ numdays);
bar(-130:2:-50,[c1' c2' c3'], 'Stacked', 'BarWidth', 1);
xlabel('RSSI [dBm]'); ylabel('Packet count per day'); grid on;
legend('Uplink', 'Downlink RX1', 'Downlink RX2');
%title(name4title,'Interpreter','none');
set(findall(gcf,'-property','FontSize'),'FontSize',font)
print(strcat(name, '_04'), '-dpng');

%% Histogram of SNR
figure();
edges = -25.5:1:15.5; col = 7;
c1 = (histcounts(M(M(:,4)==1,col), edges) ./ numdays);
c2 = (histcounts(M(M(:,4)==2,col), edges) ./ numdays);
c3 = (histcounts(M(M(:,4)==3,col), edges) ./ numdays);
bar(-25:1:15, [c1' c2' c3'], 'Stacked', 'BarWidth', 1);
xlabel('SNR [dBm]'); ylabel('Packet count per day'); grid on;
legend('Uplink', 'Downlink RX1', 'Downlink RX2');
%title(name4title,'Interpreter','none');
set(findall(gcf,'-property','FontSize'),'FontSize',font)
print(strcat(name, '_05'), '-dpng');

%% Histogram of packet length
figure();
edges = [0 11.5:4:55.5 255]; col = 3;
c1 = (histcounts(M(M(:,4)==1,col), edges) ./ numdays);
c2 = (histcounts(M(M(:,4)==2,col), edges) ./ numdays);
c3 = (histcounts(M(M(:,4)==3,col), edges) ./ numdays);
c = c1+c2+c3;
bar([c1' c2' c3'], 'Stacked', 'BarWidth', 0.7);
xticks(1:length(edges)-1);
set(gca, 'xticklabel', {'<12', '12-15', '16-19', '20-23', '24-27', '28-31', '31-34', '35-39', '40-43', '44-47', '48-51', '52-55', '>55'});
xtickangle(45);
xlabel('Data length [B]'); ylabel('Packet count per day'); grid on;
text(1:length(c), c, num2str(round(c')), 'vert', 'bottom', 'horiz', 'center');
legend('Uplink', 'Downlink RX1', 'Downlink RX2');
%title(name4title,'Interpreter','none');
set(findall(gcf,'-property','FontSize'),'FontSize',font)
print(strcat(name, '_06'), '-dpng');

%% Histogram of message types in LoRaWAN
figure();
edges = [-0.5:1:7.5 65535]; col = 11;
c1 = (histcounts(M(M(:,4)==1,col), edges) ./ numdays);
c2 = (histcounts(M(M(:,4)==2,col), edges) ./ numdays);
c3 = (histcounts(M(M(:,4)==3,col), edges) ./ numdays);
c = c1+c2+c3;
bar([c1' c2' c3'], 'Stacked', 'BarWidth', 0.7);
set(gca, 'xticklabel', {'Join Request', 'Join Accept', 'Uncnf. Data Up', 'Uncnf. Data Down', 'Cnf. Data Up', 'Cnf. Data Down', 'RFU', 'Proprietary', 'Class-B Beacon'});
%set(gca, 'yscale', 'log');
xtickangle(45);
%xlabel('Message Type'); 
ylabel('Packet count per day'); grid on;
text(1:length(c), c, num2str(round(c')), 'vert', 'bottom', 'horiz', 'center');
legend('Uplink', 'Downlink RX1', 'Downlink RX2');
%title(name4title,'Interpreter','none');
set(findall(gcf,'-property','FontSize'),'FontSize',font)
print(strcat(name, '_07'), '-dpng');

%% Histogram of FPort
% figure();
% edges = 0:1:255; col = 13;
% c1 = (histcounts(M(M(:,4)==1,col), edges) ./ numdays);
% c2 = (histcounts(M(M(:,4)==2,col), edges) ./ numdays);
% c3 = (histcounts(M(M(:,4)==3,col), edges) ./ numdays);
% bar([c1' c2' c3'], 'Stacked', 'BarWidth', 1);
% xlabel('FPort'); ylabel('Packet count per day'); grid on;
% legend('Uplink', 'Downlink RX1', 'Downlink RX2');
% title(name4title,'Interpreter','none');
% set(findall(gcf,'-property','FontSize'),'FontSize',font)
% print(strcat(name, '_08'), '-dpng');

%% Air Time
airtime_up = zeros(1,9);
airtime_down = zeros(1,9);
col = 16;
freq = 1e6.*[867.1 867.3 867.5 867.7 867.9 868.1 868.3 868.5 869.525];
for i = 1:length(freq)
    L = M(:,4)==1 & M(:,8)==freq(i);
    airtime_up(i) = sum(M(L,col));

    L1 = M(:,4)==2 & M(:,8)==freq(i);
    L2 = M(:,4)==3 & M(:,8)==freq(i);
    airtime_down(i) = sum(M(L1,col)) + sum(M(L2,col));
end
airtime_up = airtime_up*1e-3 ./ numdays ./ 86400 .* 100;
airtime_down = airtime_down*1e-3 ./ numdays ./ 86400 .* 100;

fprintf('\ndataset = %s, numdays = %.2f\n', name, numdays);
fprintf('dir/dev     count    days    %% tot    %% ch1  %% ch2  %% ch3  %% ch4  %% ch5  %% ch6  %% ch7  %% ch8  %% rx2      %% g   %% g1\n');
fprintf('uplink              %5.2f   %6.3f   %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f   %6.3f %6.3f\n', numdays, sum(airtime_up), airtime_up, sum(airtime_up(1:5)), sum(airtime_up(6:8)));
fprintf('downlink            %5.2f   %6.3f   %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f   %6.3f %6.3f\n', numdays, sum(airtime_down), airtime_down, sum(airtime_down(1:5)), sum(airtime_down(6:8)));

%% Histogram of channel occupation
figure();
c1 = airtime_up;
c2 = airtime_down;
bar([c1' c2']);
set(gca, 'xticklabel', {'Ch.1', 'Ch.2', 'Ch.3', 'Ch.4', 'Ch.5', 'Ch.6', 'Ch.7', 'Ch.8', 'RX2'});
ylabel('Channel utilization [%]'); grid on;
legend('Uplink', 'Downlink', 'Location', 'NorthWest');
set(findall(gcf,'-property','FontSize'),'FontSize',font)
print(strcat(name, '_08'), '-dpng');

%% Air Time, per DevAddr
L = M(:,4)==1;
Mflt = M(L,:);

% Count occurrences of each unique value in input_array
[unique_vals, ~, val_counts] = unique(Mflt(:,12));
counts = accumarray(val_counts, 1);

airtime = zeros(length(unique_vals),15);

for i=1:length(unique_vals)
    L = Mflt(:,12)==unique_vals(i);
    airtime_ch = zeros(1,9);
    for j = 1:length(freq)
        L2 = Mflt(:,8)==freq(j);
        airtime_ch(j) = sum(Mflt(L & L2,col));
    end
    numdays_dev = days(datetime(max(Mflt(L,2)), 'ConvertFrom', 'posixtime') - datetime(min(Mflt(L,2)), 'ConvertFrom', 'posixtime'));
    airtime(i,:) = [unique_vals(i) counts(i) numdays_dev sum(Mflt(L,col)) airtime_ch sum(airtime_ch(1:5)), sum(airtime_ch(6:8))];
end

airtime(:,4:end) = airtime(:,4:end)*1e-3 ./ airtime(:,3) ./ 86400 .* 100;

airtime(airtime(:,3)<1/24,:) = []; % delete all devices transmitting within only 1 hour
airtime(airtime(:,1)==0,:) = []; % delete zero devaddr
airtime(airtime(:,14)<1 & airtime(:,15)<1,:) = []; % delete all devices transmitting <1% in both G and G1

[~, I] = sort(airtime(:,4), 'descend');
airtime = airtime(I,:);

for i=1:size(airtime,1)
    fprintf('%08X   %6d   %5.2f   %6.3f   %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f   %6.3f %6.3f\n', airtime(i,:));
end
