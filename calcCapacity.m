function capacity = calcCapacity(data,R)
%% фильтруем напряжение
sizeWindow =400;
data.voltageFilter =data.voltage- data.current*R;
%data.voltageFilter2 =smooth(data.voltage,sizeWindow);
data.voltageFilter3 =smooth(data.voltageFilter,sizeWindow);
% figure
% hold on
% yyaxis left
% %plot (data.timeDuration,data.voltage,'DurationTickFormat','hh:mm:ss');
% %plot (data.timeDuration,data.voltageFilter2,'DurationTickFormat','hh:mm:ss');
% plot (data.timeDuration,data.voltageFilter3,'DurationTickFormat','hh:mm:ss');
% yyaxis right
% plot (data.timeDuration,data.SOC,'DurationTickFormat','hh:mm:ss');
% hold off
%% определение емкости
%определяем интервалы разряда
%максимальное и минимальное напряжение для батареи 282
VFull = 49.5;
VEmpty = 48;
%максимальное и минимальное напряжение для батареи 995
% VFull = 23.5;
% VEmpty = 21.5;
%минимальный интервал разрядки на котором будет расчитываться емкость
minDudationDischarge = duration(1,0,0);

discharge = false;
% массив циклов разрядки
%[(время старта разряда) (время окончания разряда)]
timeDischarge = [ duration(0,0,0) duration(0,0,0)];
for i=2:length(data.voltage)
    if (data.voltageFilter3(i-1)>=VFull && data.voltageFilter3(i)<=VFull)
        if (~discharge)
            discharge = true;
        end
        timeDischarge(end,1) = duration (0,0,i);
    elseif(data.voltageFilter3(i-1)>=VEmpty && data.voltageFilter3(i)<=VEmpty)
        if(discharge)
            if ((duration (0,0,i)-timeDischarge(end,1))>=minDudationDischarge)
                timeDischarge(end,2) = duration (0,0,i);
                timeDischarge = [timeDischarge; duration(0,0,0) duration(0,0,0)];
            end
            discharge =false;
        end
    end
end
timeDischarge = timeDischarge(1:end-1,:);
[countDischarge X] = size(timeDischarge);
clearvars X;
capacity = zeros(countDischarge,1);
%интегрируем ток в периуды разрядки
for i=1:countDischarge
    startDischarge = seconds(timeDischarge(i,1));
    endDischarge = seconds(timeDischarge(i,2));
    sumCurrent = -sum (data.current(startDischarge:endDischarge));
    capacity(i) = sumCurrent/3600;%(endDischarge-startDischarge);
end