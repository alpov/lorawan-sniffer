function  process_beacon2(name, mode)


% nr,time_epoch,len,srcgw,crc,rssi,snr,frequency,sf,cr,ftype,devaddr,fport,fcnt
% 1,1659362668.811991000,27,1,1,-108.0,0.0,867100000,11,5,2,654426274,8,36916

%close all;
%clear all;
%name='../loralog/csv/05_Wien_beacon'; mode='utcshift';
%name='../loralog/csv/07_Brno_beacon'; mode='unix';

if strcmp(mode, 'unix')
    invalidstr = 'UNIX time'; 
    append = '_unix';
    shift = 315964782;
elseif strcmp(mode, 'utcshift')
    invalidstr = 'UTC shift'; 
    append = '_utcshift';
    shift = -18;
end

%name = '05_Wien_beacon'; invalidstr = 'UTC shift'; append = '_utcshift';
%name = '07_Brno_beacon'; invalidstr = 'UNIX time'; append = '_unix';

M = readmatrix(strcat(name, '_valid.csv'), 'TreatAsMissing', 'NaN');
N = readmatrix(strcat(name, append, '.csv'), 'TreatAsMissing', 'NaN');
numdays = days(datetime(M(end,2), 'ConvertFrom', 'posixtime')-datetime(M(1,2), 'ConvertFrom', 'posixtime'));

% Extract city and type from filename
[~, filename, ~] = fileparts(name);
[city, type] = strtok(filename(4:end), '_');
type = type(2:end);

% Replace underscores with spaces and format output string
type = strrep(type, '_', ' ');
name4title = sprintf('%s (%s)', city, type);
font = 12;

%% Histogram of RSSI
figure();
edges = -121:2:-59; col = 6;
c1 = (histcounts(M(:,col), edges) ./ numdays);
c2 = (histcounts(N(:,col), edges) ./ numdays);
bar(-120:2:-60,[c1' c2'], 'Stacked', 'BarWidth', 1);
xlabel('RSSI [dBm]'); ylabel('Packet count per day'); grid on;
legend('Valid', invalidstr);
%title(name4title,'Interpreter','none');
set(findall(gcf,'-property','FontSize'),'FontSize',font)
print(strcat(name, '_04'), '-dpng');

%% Histogram of SNR
figure();
edges = -15.5:1:15.5; col = 7;
c1 = (histcounts(M(:,col), edges) ./ numdays);
c2 = (histcounts(N(:,col), edges) ./ numdays);
bar(-15:1:15, [c1' c2'], 'Stacked', 'BarWidth', 1);
xlabel('SNR [dBm]'); ylabel('Packet count per day'); grid on;
legend('Valid', invalidstr);
%title(name4title,'Interpreter','none');
set(findall(gcf,'-property','FontSize'),'FontSize',font)
print(strcat(name, '_05'), '-dpng');

%% Timing jitter
figure();
edges = 0:2:500; col = 16;
c1 = (histcounts(1e6*(M(:,col)-0.154076), edges) ./ numdays);
c2 = (histcounts(1e6*(N(:,col)-0.154076+shift), edges) ./ numdays);
bar(edges(2:end), [c1' c2'], 'Stacked', 'BarWidth', 1);
%bar(edges(2:end), c1, 'Stacked', 'BarWidth', 1);
%hold on;
%bar(edges(2:end), c2, 'Stacked', 'BarWidth', 1);
xlabel('Difference [us]'); ylabel('Packet count per day'); grid on;
legend('Valid', invalidstr);
%title(name4title,'Interpreter','none');
set(findall(gcf,'-property','FontSize'),'FontSize',font)
print(strcat(name, '_08'), '-dpng');

