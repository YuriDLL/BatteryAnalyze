clc
clear
%% считываем csv фаил
%сгенерированна¤ функци¤
filename = 'data\pack_282_2018_04_29test.csv';
%переписываем все зап¤тые в точки в файле
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
timeDuration = duration( 0,0,0:(86400+zapas-1))';
voltage = zeros (86400+zapas ,1);
temp = zeros (86400+zapas ,1);
current= zeros (86400+zapas ,1);
SOC = uint8(zeros (86400+zapas ,1));
bal = false (86400+zapas ,1);
chg = false (86400+zapas ,1);

i=2;%
j = 2;
%обработка первых элементов
voltage(1) = voltageZ(1);
temp(1) = tempZ(1);
current(1) = currentZ(1);
SOC(1) = SOCZ(1);
bal(1) = balZ(1);
chg(1) = chg(1);
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
        voltage(j:j+deltaSec-1) = bufVoltage;
        %температура
        buftemp = zeros(deltaSec,1)+tempZ(i-1);
        buftemp(deltaSec) = tempZ(i);
        temp(j:j+deltaSec-1) = buftemp;
        %ток
        bufCurrent = zeros(deltaSec,1)+currentZ(i-1);
        bufCurrent(deltaSec) = currentZ(i);
        current(j:j+deltaSec-1) = bufCurrent;
        %SOC
        bufSOC = uint8(zeros(deltaSec,1))+SOCZ(i-1);
        bufSOC(deltaSec) = SOCZ(i);
        SOC(j:j+deltaSec-1) = bufSOC;
        %BAL
        bufbal = false(deltaSec,1) | balZ(i-1);
        bufSOC(deltaSec) = balZ(i);
        bal(j:j+deltaSec-1) = bufbal;
        %CHG
        bufchg = false(deltaSec,1) | chgZ(i-1);
        bufchg(deltaSec) = chgZ(i);
        chg(j:j+deltaSec-1) = bufchg;     
        
        j = j+deltaSec;
    else
        voltage(j) = voltageZ(i);
        temp(j) = tempZ(i);
        current(j) = currentZ(i);
        SOC(j) = SOCZ(i);
        bal(j) = balZ(i);
        chg(j) = chgZ(i);
        j=j+1;
    end
end
%% визуализаци¤
hAxes1=subplot(2,1,1);
yyaxis left
plot (timeDuration,voltage,'DurationTickFormat','hh:mm:ss');
yyaxis right
plot (timeDuration,current,'DurationTickFormat','hh:mm:ss');
hAxes2 = subplot(2,1,2);
yyaxis left
plot (timeDuration,chg,'DurationTickFormat','hh:mm:ss');
ylim([0 2]);
%матлаб делает их одноцветными и разобрать где что невозможно
hold on
plot (timeDuration,bal,'DurationTickFormat','hh:mm:ss');%
hold off
yyaxis right
plot (timeDuration,SOC,'DurationTickFormat','hh:mm:ss');
linkaxes([hAxes1,hAxes2], 'x');
xlim ( [duration(0,0,0) duration(24,0,0)]);
%% ќпределение сопротивлени¤
%нахождение интервалов нулевого тока
Izero = 5; % погрешность нулевого тока
Tzero = duration ( 0,20,0); % продолжительность нулевого тока
%%%%
%минимальный ток нагрузки дл¤ замера
Imin = 50;
%максимальное среднеквадратичное отклонение дл¤ замера в %
devmax = 10;
%врем¤ дл¤ нарастани¤ тока после паузы
TRaise = duration ( 0,1,0);
%врем¤ установлени¤ напр¤жени¤
TRelax = duration (0,5,0);

flagZeroCur =false;
timeStartZero = duration (0,0,0);
%[Ts Td]
%Ts - врем¤ начала паузы
%Td - продолжительность паузы
zeroPer = duration(0,0,1:2);%массив пауз [Ts1 Td1; Ts2 Td2; ....]
for i=1: length(timeDuration)
    if (abs(current(i))<Izero)
        if(~flagZeroCur)
            timeStartZero = timeDuration(i);
            flagZeroCur = true;
        end
    else
        if(flagZeroCur)
            duratonZero =timeDuration(i)-timeStartZero;
            if (duratonZero>=Tzero)
                zeroPer = [zeroPer ; timeStartZero duratonZero ];
            end
            flagZeroCur = false;
        end
    end
end
%убираем первый элемент
zeroPer = zeroPer(2:end,:);
R = 0;
for i = 1: size(zeroPer,1)
    startRelax=seconds(zeroPer(i,1))+seconds(zeroPer(i,2))+seconds(TRaise)-3;
    endRelax = startRelax+seconds(TRelax)-1;
    [mr dev] = deviation(current(startRelax:endRelax));
    if (abs(mr)>Imin && dev < devmax)
        deltaV =abs(voltage(seconds(zeroPer(i,1))+seconds(zeroPer(i,2))-2)...
            - voltage(endRelax));
        deltaI = abs(mr);
        R = [R deltaV/deltaI];
        %отображение результатов
        fprintf('Time=%s, current=%2.1f, deltaV=%f, R=%f t =%f \n',...
            char(timeDuration(startRelax)),mr,deltaV,R(end),temp(startRelax))
    end
end
%убираем первый элемент
R = R(2:end);