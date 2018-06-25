%восстановление сжатых данных
i=2;
oneSec = seconds(1);
while (i<=length(timeDuration))% = 2:length(timeDuraton)
    deltaTime = timeDuration(i)-timeDuration(i-1);
    if (deltaTime > oneSec)
        deltaSec = seconds(deltaTime);
        %массив для вставки
        bufTime = duration(0,0,1:deltaSec-1);
        bufTime = bufTime' + timeDuration(i-1);
        %вставка недостающих элементов
        timeDuration = [timeDuration(1:i-1);bufTime;...
            timeDuration(i:end)];
        %восстановление напряжения
        bufVoltage = zeros(deltaSec-1,1)+voltage(i-1);
        voltage = [voltage(1:i-1);bufVoltage;...
            voltage(i:end)];
        
        i = i+deltaSec;
    else
        i=i+1;
    end
    %тест
    if ( mod (i,1000) == 0)
        i
    end
end
i