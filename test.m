clc
clear
[data]=takeVectors('data\pack_282_2018_05_02.csv');
visualization(data)
R = calcResistance(data);