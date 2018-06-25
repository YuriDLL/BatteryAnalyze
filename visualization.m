function visualization(data)
%% визуализация
hAxes1=subplot(2,1,1);
yyaxis left
plot (data.timeDuration,data.voltage,'DurationTickFormat','hh:mm:ss');
yyaxis right
plot (data.timeDuration,data.current,'DurationTickFormat','hh:mm:ss');
hAxes2 = subplot(2,1,2);
yyaxis left
plot (data.timeDuration,data.chg,'DurationTickFormat','hh:mm:ss');
ylim([0 2]);
%матлаб делает их одноцветными и разобрать где что невозможно
hold on
plot (data.timeDuration,data.bal,'DurationTickFormat','hh:mm:ss');%
hold off
yyaxis right
plot (data.timeDuration,data.SOC,'DurationTickFormat','hh:mm:ss');
linkaxes([hAxes1,hAxes2], 'x');
xlim ( [duration(0,0,0) duration(24,0,0)]);
hold off
end