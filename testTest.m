clc
clear
%% считываем csv фаил
%сгенерированная функция
filename = 'data\pack_282_2018_04_29test.csv';
%переписываем все запятые в точки в файле
comma2point_overwrite(filename);
delimiter = ';';
startRow = 2;
% For more information, see the TEXTSCAN documentation.
formatSpec = '%q%f%f%f%d8%d8%d8';
fileID = fopen(filename,'r');
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,...
    'MultipleDelimsAsOne', true, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
fclose(fileID);
clearvars filename  delimiter formatSpec fileID startRow;
%% парсим данные
%создание векторов из таблицы файла
time  = datetime(table2array(dataArray(1)));
%более удобый формат времени duration
timeDurationZ = duration( hour(time),minute(time),second(time));
oneSec = seconds(1);
for i= 2:length(timeDurationZ)% = 2:length(timeDuraton)
    deltaTime = timeDurationZ(i)-timeDurationZ(i-1);
    if (deltaTime < oneSec)
        fprintf('WRONG! Row=%d\n',i);
    end
end