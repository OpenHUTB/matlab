




function configurationPlotImpulseUpdate(block)
    plotImpulse=get_param(block,'PlotImpulse');

    terminateFun=[block,'/Terminate Function'];
    configurationPlotImpulseFcn='serdes.internal.callbacks.configurationPlotImpulse(bdroot(gcb));';
    currentStopFcn=get_param(block,'StopFcn');
    if strcmp(plotImpulse,'on')
        if isempty(currentStopFcn)

            set_param(block,'StopFcn',configurationPlotImpulseFcn);
        else
            if~contains(currentStopFcn,configurationPlotImpulseFcn)

                if~endsWith(currentStopFcn,';')
                    currentStopFcn=[currentStopFcn,';'];
                end

                combinedStopFcn=[configurationPlotImpulseFcn,currentStopFcn];
                set_param(block,'StopFcn',combinedStopFcn);
            end
        end

        set_param(terminateFun,'Commented','off');
    else

        removedStopFcn=erase(currentStopFcn,configurationPlotImpulseFcn);
        set_param(block,'StopFcn',removedStopFcn);

        set_param(terminateFun,'Commented','on');
    end


    serdes.internal.callbacks.configurationPlotTimeDomainUpdate(block);
end