function configurationPlotTimeDomainUpdate(block)
    plotImpulse=get_param(block,'PlotImpulse');
    maskPlotImpulse=strcmp(plotImpulse,'on');
    plotTimeDomain=get_param(block,'PlotTimeDomain');
    maskPlotTimeDomain=strcmp(plotTimeDomain,'on');
    configurationPlotTDEyeFcn='serdes.internal.callbacks.configurationPlotTimeDomain(bdroot(gcb));';
    configurationPlotTDEyeFcnNoStat='serdes.internal.callbacks.configurationPlotTimeDomain(bdroot(gcb),true);';
    currentStopFcn=get_param(block,'StopFcn');
    hasTD=contains(currentStopFcn,configurationPlotTDEyeFcn);
    hasTDNoStat=contains(currentStopFcn,configurationPlotTDEyeFcnNoStat);
    if maskPlotTimeDomain
        if isempty(currentStopFcn)

            newStopFcn=configurationPlotTDEyeFcnNoStat;
            set_param(block,'StopFcn',newStopFcn);
        else
            if~hasTDNoStat&&~hasTD

                if~endsWith(currentStopFcn,';')
                    currentStopFcn=[currentStopFcn,';'];
                end

                if maskPlotImpulse
                    newStopFcn=[currentStopFcn,configurationPlotTDEyeFcn];
                else
                    newStopFcn=[currentStopFcn,configurationPlotTDEyeFcnNoStat];
                end
                set_param(block,'StopFcn',newStopFcn);
            elseif hasTD&&~maskPlotImpulse

                newStopFcn=erase(currentStopFcn,configurationPlotTDEyeFcn);
                newStopFcn=[newStopFcn,configurationPlotTDEyeFcnNoStat];
                set_param(block,'StopFcn',newStopFcn);
            elseif hasTDNoStat&&maskPlotImpulse

                newStopFcn=erase(currentStopFcn,configurationPlotTDEyeFcnNoStat);
                newStopFcn=[newStopFcn,configurationPlotTDEyeFcn];
                set_param(block,'StopFcn',newStopFcn);
            end
        end

        serdes.internal.callbacks.configurationDataLogging(bdroot(block),'on');
    else

        if hasTD
            newStopFcn=erase(currentStopFcn,configurationPlotTDEyeFcn);
            set_param(block,'StopFcn',newStopFcn);
        elseif hasTDNoStat
            newStopFcn=erase(currentStopFcn,configurationPlotTDEyeFcnNoStat);
            set_param(block,'StopFcn',newStopFcn);
        end
        serdes.internal.callbacks.configurationDataLogging(bdroot(block),'off');
    end
end