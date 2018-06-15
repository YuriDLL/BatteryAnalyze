function [mr, dev]=deviation( a)
%mr - мат ожидание
%dev - средне квадратичное отклонение
mr = mean(a);
%A = sum((mr - a).^2)/(length(a)-1)
dev = sqrt(cov(a));
dev = abs(dev/mr*100);%процентное соотношение 
end