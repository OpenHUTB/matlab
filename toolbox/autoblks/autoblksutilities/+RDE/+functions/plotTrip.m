function plotTrip(data,params)









    hold on;
    plot(seconds(data.t)/60,data.v*3.6,'DisplayName','Speed')
    yline(params.OperationModeBoundaries(1)*3.6,'-','Color',[0.8500,0.3250,0.0980],'DisplayName','urban/rural','LabelHorizontalAlignment','right');
    yline(params.OperationModeBoundaries(2)*3.6,'-','Color',[0.9290,0.6940,0.1250],'DisplayName','rural/motorway','LabelHorizontalAlignment','right');
    hold off;
    grid on;
    xlabel('Time (min)');
    ylabel('Velocity (km/h)');
    legend({'speed','urban/rural','rural/motorway'},'Location','best');
    drawnow;

end