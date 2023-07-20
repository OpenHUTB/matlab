function automldcycltrck(Time,currentVel,cycleTime,cycleVel,upLimData,loLimData,limTime,errorOn,timeWindow,dTplot)%#codegen
    coder.allowpcode('plain')


    coder.extrinsic('plot','figure','axes','drawnow','xlim','ylim','legend','gcb','get_param','getString','message','regexp')
    persistent figH velHist timeHist plotH axH
    if isempty(figH)||~ishandle(figH)
        if isempty(dTplot)
            buffersize=floor(timeWindow/.01)+1;
        else
            buffersize=floor(timeWindow/dTplot)+1;
        end
        figH=figure('Name','Velocity Trace','NumberTitle','off','renderer','OpenGL','clipping','off');
        set(0,"currentfigure",figH);
        axH=gca(figH);
        hold on
        plot(cycleTime,cycleVel)
        ylim([0,max(cycleVel)])
        velHist=zeros(1,buffersize);
        timeHist=zeros(1,buffersize);
        plotH=plot(timeHist,velHist,'k-o');
        if errorOn
            plot(limTime,upLimData,'r-',limTime,loLimData,'r-')
            ylim([0,max(upLimData)])
        end
        set(axH,'XLim',[0,timeWindow*2]);
        block=gcb;
        startIndex=1;
        [startIndex,~]=regexp(block,'Timing Mode');
        outUnit=get_param(block(1:startIndex-1),'outUnit');
        xlabel(getString(message('autoblks_shared:autoblkDriveCycleSourcePlot:xlabel_time')));
        ylabel(getString(message('autoblks_shared:autoblkDriveCycleSourcePlot:ylabel_vel',outUnit)));
        grid on
        box on
        legend('Reference','Vehicle','Velocity Bounds');
        hold off
    elseif~isempty(findobj(figH))
        velHist=[velHist(2:end),currentVel];
        timeHist=[timeHist(2:end),Time];
        set(plotH,'Xdata',timeHist);
        set(plotH,'Ydata',velHist);
        if Time>=timeWindow
            set(axH,'XLim',[Time-timeWindow,Time+timeWindow])
        end
    end
end