function plotVA95(data,params)










    v=data.v;
    opMode=data.opMode;


    [va95,~,vAvg]=RDE.functions.calcDynamicBoundaryConditionsData(v,opMode,params);

    hold on;
    plot(v*3.6,RDE.functions.calcVa95Boundary(v,params),'b.','DisplayName','VA95 Boundary');
    plot(vAvg(1)*3.6,va95(1),'ok','MarkerSize',5,'MarkerFaceColor',[0,0.4470,0.7410],'DisplayName','urban');
    plot(vAvg(2)*3.6,va95(2),'ok','MarkerSize',5,'MarkerFaceColor',[0.8500,0.3250,0.0980],'DisplayName','rural');
    plot(vAvg(3)*3.6,va95(3),'ok','MarkerSize',5,'MarkerFaceColor',[0.9290,0.6940,0.1250],'DisplayName','motorway');
    xline(params.OperationModeBoundaries(1)*3.6);
    xline(params.OperationModeBoundaries(2)*3.6);
    hold off;
    grid on;
    xlabel('Speed (km/h)');
    ylabel('Velocity*Acceleration (m^2/s^3)');
    legend({'VA95 Boundary','urban','rural','motorway'},'Location','best');

end



