function  process_beacon_ts(name)


% nr,time_epoch,len,srcgw,crc,rssi,snr,frequency,sf,cr,ftype,devaddr,fport,fcnt
% 1,1659362668.811991000,27,1,1,-108.0,0.0,867100000,11,5,2,654426274,8,36916

%close all;
%clear all;
%name = '05_Wien_beacon_all';

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

%% Histogram of time shifts
figure();
edges = [-Inf -2.5:1:37.5 Inf]; col = 16;
c = (histcounts(M(:,col), edges));
bar(c, 'Stacked', 'BarWidth', 0.7);
xticks(1:length(edges)-1);
%set(gca, 'xticklabel', {'<-3', -3:1:40, '>40'});
set(gca, 'xticklabel', {'<-2', '', '', 0, '', 2, '', 4, '', 6, '', 8, '', 10, '', 12, '', 14, '', 16, '', 18, '', 20, '', 22, '', 24, '', 26, '', 28, '', 30, '', 32, '', 34, '', 36, '', '>37'});
xlabel('Time shift [s]'); ylabel('Total packet count'); grid on;
ylim([0 70]);
c2=c;
c2(c>70) = 66;
c3=(1:length(c))-0.4;
c3(c>70) = c3(c>70)+2.0;
text(c3, c2, num2str(c'), 'vert', 'bottom', 'horiz', 'center');
%title(name4title,'Interpreter','none');
set(findall(gcf,'-property','FontSize'),'FontSize',font)
fig = gcf;
fig.Position(3)=fig.Position(3)*2;
fig.Position(4)=fig.Position(4)*1.3;
print(strcat(name, '_03'), '-dpng');

