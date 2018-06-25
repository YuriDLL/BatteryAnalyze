function R = calcResistance(data)
    %% определение сопротивления
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
for i=1: length(data.timeDuration)
    if (abs(data.current(i))<Izero)
        if(~flagZeroCur)
            timeStartZero = data.timeDuration(i);
            flagZeroCur = true;
        end
    else
        if(flagZeroCur)
            duratonZero =data.timeDuration(i)-timeStartZero;
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
    [mr dev] = deviation(data.current(startRelax:endRelax));
    if (abs(mr)>Imin && dev < devmax)
        deltaV =abs(data.current(seconds(zeroPer(i,1))+seconds(zeroPer(i,2))-2)...
            - data.current(endRelax));
        deltaI = abs(mr);
        R = [R deltaV/deltaI];
        %отображение результатов
        fprintf('Time=%s, current=%2.1f, deltaV=%f, R=%f t =%f \n',...
            char(data.timeDuration(startRelax)),mr,deltaV,R(end),data.temp(startRelax))
    end
end
%убираем первый элемент
R = R(2:end);
end