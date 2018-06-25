function [data]=takeVectors(filename)
%% считываем csv фаил
%переписываем все зап¤тые в точки в файле
comma2point_overwrite(filename);
delimiter = ';';
startRow = 2;
%сгенерированная функци¤
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
% дл¤ распознавани¤ дробныйх чисел замекн¤ем за¤птые на точки
voltageZ  = table2array(dataArray(2));
tempZ = table2array(dataArray(3));
currentZ = table2array(dataArray(4));
SOCZ =  uint8(table2array(dataArray(5)));
balZ = logical(table2array(dataArray(6)));
chgZ = logical(table2array(dataArray(7)));
%восстановление сжатых данных
%размер массива увеличен из за битых значений( значений с одним временем)
zapas = 20;
%массивы дл¤ разжатых данных
data.timeDuration = duration( 0,0,0:(86400+zapas-1))';
data.voltage = zeros (86400+zapas ,1);
data.temp = zeros (86400+zapas ,1);
data.current= zeros (86400+zapas ,1);
data.SOC = uint8(zeros (86400+zapas ,1));
data.bal = false (86400+zapas ,1);
data.chg = false (86400+zapas ,1);

i=2;%
j = 2;
%обработка первых элементов
data.voltage(1) = voltageZ(1);
data.temp(1) = tempZ(1);
data.current(1) = currentZ(1);
data.SOC(1) = SOCZ(1);
data.bal(1) = balZ(1);
data.chg(1) = chgZ(1);
%
oneSec = seconds(1);
for i= 2:length(timeDurationZ)
    deltaTime = timeDurationZ(i)-timeDurationZ(i-1);
    if (deltaTime > oneSec)
        %кол-во секунд
        deltaSec = seconds(deltaTime);
        %напр¤жение
        %массив дл¤ вставки
        bufVoltage = zeros(deltaSec,1)+voltageZ(i-1);
        bufVoltage(deltaSec) = voltageZ(i);
        %перенос массива
        data.voltage(j:j+deltaSec-1) = bufVoltage;
        %температура
        buftemp = zeros(deltaSec,1)+tempZ(i-1);
        buftemp(deltaSec) = tempZ(i);
        data.temp(j:j+deltaSec-1) = buftemp;
        %ток
        bufCurrent = zeros(deltaSec,1)+currentZ(i-1);
        bufCurrent(deltaSec) = currentZ(i);
        data.current(j:j+deltaSec-1) = bufCurrent;
        %SOC
        bufSOC = uint8(zeros(deltaSec,1))+SOCZ(i-1);
        bufSOC(deltaSec) = SOCZ(i);
        data.SOC(j:j+deltaSec-1) = bufSOC;
        %BAL
        bufbal = false(deltaSec,1) | balZ(i-1);
        bufbal(deltaSec) = balZ(i);
        data.bal(j:j+deltaSec-1) = bufbal;
        %CHG
        bufchg = false(deltaSec,1) | chgZ(i-1);
        bufchg(deltaSec) = chgZ(i);
        data.chg(j:j+deltaSec-1) = bufchg;     
        
        j = j+deltaSec;
    else
        data.voltage(j) = voltageZ(i);
        data.temp(j) = tempZ(i);
        data.current(j) = currentZ(i);
        data.SOC(j) = SOCZ(i);
        data.bal(j) = balZ(i);
        data.chg(j) = chgZ(i);
        j=j+1;
    end
end
end