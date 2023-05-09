%%
clc
tic
%close all; process_all('../loralog/csv/01_Brno_all');
%close all; process_valid('../loralog/csv/01_Brno_valid');
close all; process_all('../loralog/csv/02_Liege_all');
close all; process_valid('../loralog/csv/02_Liege_valid');
%close all; process_all('../loralog/csv/03_Brno_join_all');
%close all; process_valid('../loralog/csv/03_Brno_join_valid');
close all; process_all('../loralog/csv/04_Graz_all');
close all; process_valid('../loralog/csv/04_Graz_valid');
close all; process_all('../loralog/csv/05_Wien_all');
close all; process_valid('../loralog/csv/05_Wien_valid');
close all; process_all('../loralog/csv/07_Brno_all');
close all; process_valid('../loralog/csv/07_Brno_valid');
close all;
%%
%close all; process_beacon('../loralog/csv/01_Brno_beacon');
close all; process_beacon('../loralog/csv/02_Liege_beacon');
close all; process_beacon2('../loralog/csv/05_Wien_beacon', 'utcshift');
close all; process_beacon2('../loralog/csv/07_Brno_beacon', 'unix');
close all; process_beacon_ts('../loralog/csv/05_Wien_beacon_all');
close all; process_beacon_jitter('../loralog/csv/');
%%

close all; process_occup('../loralog/csv/00_occupation');
close all;
toc

%%
if exist('../loralog/matlab', 'dir')
    rmdir('../loralog/matlab', 's');
end
mkdir ('../loralog/matlab');
copyfile('../loralog/csv/00_jitter_all.png', '../loralog/matlab');
copyfile('../loralog/csv/00_occupation_01.png', '../loralog/matlab');
copyfile('../loralog/csv/00_occupation_02.png', '../loralog/matlab');

copyfile('../loralog/csv/02_Liege_all_07.png', '../loralog/matlab');

copyfile('../loralog/csv/04_Graz_all_07.png', '../loralog/matlab');

copyfile('../loralog/csv/05_Wien_all_07.png', '../loralog/matlab');
copyfile('../loralog/csv/05_Wien_all_08.png', '../loralog/matlab');
copyfile('../loralog/csv/05_Wien_valid_*.png', '../loralog/matlab');
copyfile('../loralog/csv/05_Wien_beacon_all_03.png', '../loralog/matlab');

copyfile('../loralog/csv/07_Brno_all_07.png', '../loralog/matlab');
copyfile('../loralog/csv/07_Brno_all_08.png', '../loralog/matlab');
copyfile('../loralog/csv/07_Brno_valid_07.png', '../loralog/matlab');

