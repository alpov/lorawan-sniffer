function  process_beacon2_jitter(path)


% nr,time_epoch,len,srcgw,crc,rssi,snr,frequency,sf,cr,ftype,devaddr,fport,fcnt
% 1,1659362668.811991000,27,1,1,-108.0,0.0,867100000,11,5,2,654426274,8,36916

%close all;
%clear all;
%path='../loralog/csv/';

deltashift = 152576e-6 + 1500e-6 + 67e-6;

name='05_Wien_beacon';
M1 = readmatrix(strcat(path, name, '_valid.csv'), 'TreatAsMissing', 'NaN');
N1 = readmatrix(strcat(path, name, '_utcshift', '.csv'), 'TreatAsMissing', 'NaN');
numdays1 = days(datetime(M1(end,2), 'ConvertFrom', 'posixtime')-datetime(M1(1,2), 'ConvertFrom', 'posixtime'));
invalidstr1 = 'UTC shift'; 
shift1 = -18;
t_gw1 = [1.8 7.3] ./ 3e5;

name='07_Brno_beacon';
M2 = readmatrix(strcat(path, name, '_valid.csv'), 'TreatAsMissing', 'NaN');
N2 = readmatrix(strcat(path, name, '_unix', '.csv'), 'TreatAsMissing', 'NaN');
numdays2 = days(datetime(M2(end,2), 'ConvertFrom', 'posixtime')-datetime(M2(1,2), 'ConvertFrom', 'posixtime'));
invalidstr2 = 'UNIX time'; 
shift2 = 315964782;

name='02_Liege_beacon';
M3 = readmatrix(strcat(path, name, '_valid.csv'), 'TreatAsMissing', 'NaN');
numdays3 = days(datetime(M3(end,2), 'ConvertFrom', 'posixtime')-datetime(M3(1,2), 'ConvertFrom', 'posixtime'));
t_gw3 = [24 18.9 24.1 22.5 18.7 14.7 36.2] ./ 3e5;

name4title = 'Beacon jitter';
font = 12;

%% Timing jitter
figure();
edges = [-21:2:341]; col = 16;
x1values = edges(2:end)-1;
x2values = x1values .* 1e-6 .* 3e5;
x1ticks = 0:50:340;
x2ticks = x1ticks .* 1e-6 .* 3e5;
c1 = (histcounts(1e6*(M1(:,col)-deltashift), edges) ./ numdays1);
c2 = (histcounts(1e6*(N1(:,col)-deltashift+shift1), edges) ./ numdays1);
c3 = (histcounts(1e6*(M2(:,col)-deltashift), edges) ./ numdays2);
c4 = (histcounts(1e6*(N2(:,col)-deltashift+shift2), edges) ./ numdays2);
c5 = (histcounts(1e6*(M3(:,col)-deltashift), edges) ./ numdays3);

ax = axes();
hold(ax);
ax.Layer = 'top';
ax.XLim = [x1values(1) x1values(end)];
ax.XTick = x1ticks;
xlabel(ax, 'Signal propagation delay [\mus]');
ylabel(ax, 'Packet count per day'); 
grid on;

ax_top = axes();
hold(ax_top);
ax_top.XAxisLocation = 'top';
ax_top.YAxisLocation = 'right';
ax_top.XLim = [x2values(1) x2values(end)];
ax_top.XTick = x2ticks;
ax_top.Color = 'none';
xlabel(ax_top, 'Distance [km]'); 
linkprop([ax, ax_top],{'Units','Position','ActivePositionProperty'});
ax.Position(4) = ax.Position(4) * .96;

%bar(ax, x1values, [c1' c3' c5' c2' c4'], 'Stacked', 'BarWidth', 1);
alpha=1.0;
b2=bar(ax, x1values, c2, 'BarWidth', 1, 'FaceAlpha',alpha);
hold on;
b4=bar(ax, x1values, c4, 'BarWidth', 1, 'FaceAlpha',alpha);
b1=bar(ax, x1values, c1, 'BarWidth', 1, 'FaceAlpha',alpha);
b3=bar(ax, x1values, c3, 'BarWidth', 1, 'FaceAlpha',alpha);
b5=bar(ax, x1values, c5, 'BarWidth', 1, 'FaceAlpha',alpha);

chleg = get(ax, 'colororder');
%title(name4title,'Interpreter','none');
%hold on;
plot(ax, t_gw1*1e6, zeros(size(t_gw1)), 'k^', 'MarkerFaceColor', chleg(3,:), 'MarkerSize', 8, 'LineWidth', 1.3);
plot(ax, t_gw3*1e6, zeros(size(t_gw3)), 'k^', 'MarkerFaceColor', chleg(5,:), 'MarkerSize', 8, 'LineWidth', 1.3);

hleg=legend(ax, 'Vienna UTC shift', 'Brno UNIX time', 'Vienna valid', 'Brno valid', 'Liege valid', 'Vienna gateways', 'Liege gateways');
hleg.Position(1) = 0.55;

ax_top.YLim = ax.YLim;
ax_top.YTickLabel = [];

set(findall(gcf,'-property','FontSize'),'FontSize',font)
fig = gcf;
fig.Position(3)=fig.Position(3)*2;
fig.Position(4)=fig.Position(4)*1.3;
print(strcat(path,'00_jitter_all'), '-dpng');

