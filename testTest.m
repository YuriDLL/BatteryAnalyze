clc
clear
%% считываем csv фаил
CSVFile = readtable('../pack_1376_2018_04_08.csv','FileType',...
    'spreadsheet','DatetimeType','exceldatenum');
%% парсим данные
%создание векторов из таблицы файла
time  = table2array(CSVFile(:,1));
%более удобый формат времени duration
timeDurationZ = duration( hour(time),minute(time),second(time));
oneSec = seconds(1);
for i= 2:length(timeDurationZ)% = 2:length(timeDuraton)
    deltaTime = timeDurationZ(i)-timeDurationZ(i-1);
    if (deltaTime < oneSec)
        fprintf('WRONG! Row=%d\n',i);
    end
end