function c=checkDynamicBoundaryConditions(data,params,varargin)





    v=data.v;
    opMode=data.opMode;


    p=inputParser();
    addParameter(p,'Plot',false);
    parse(p,varargin{:});


    [va95,rpa,vAvg]=RDE.functions.calcDynamicBoundaryConditionsData(v,opMode,params);


    vaCond=va95-RDE.functions.calcVa95Boundary(vAvg,params);
    rpaCond=RDE.functions.calcRpaBoundary(vAvg,params)-rpa;
    c=max([vaCond;rpaCond]);

    if p.Results.Plot

figure
        subplot(1,2,1)
        plot(v*3.6,RDE.functions.calcVa95Boundary(v,params),'b.')
        hold on
        plot(vAvg*3.6,va95,'xk');
        hold off
        xlabel('Speed (km/h)')
        ylabel('v*a (m^2/s^3)')
        grid on
        subplot(1,2,2)
        plot(v*3.6,RDE.functions.calcRpaBoundary(v,params),'b.')
        hold on
        plot(vAvg*3.6,rpa,'xk');
        hold off
        xlabel('Speed (km/h)')
        ylabel('RPA (m/s^2)')
        grid on
    end
end

