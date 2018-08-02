clc
clear
%[data]=takeVectors('data\pack_282_2018_05_02.csv','data\matFiles\pack_282_2018_05_02.mat');
load('data/matFiles/pack_282_2018_05_02.mat');
visualization(data)
R = calcResistance(data);
%ДЛЯ ДНЕЙ, В КОТОРЫЕ НЕЛЬЗЯ ОПРЕДЕЛИТЬ R
%R = 0.007
R = mean (R);
calcCapacity( data,R)


