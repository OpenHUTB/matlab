

function[name,value]=getTickIntervalNameValue(widget,majorTicks,isLogScale)

    isAutoTickInterval=~isempty(widget)&&(widget.AutoTickInterval);
    if isLogScale
        name=DAStudio.message('SimulinkHMI:dialogs:LogTickIntervalPrompt');
        if(isAutoTickInterval)
            value='auto';
        else
            value=log10(majorTicks(2)/majorTicks(1));
        end
    else
        name=DAStudio.message('SimulinkHMI:dialogs:TickIntervalPrompt');
        if(isAutoTickInterval)
            value='auto';
        else
            value=majorTicks(2)-majorTicks(1);
        end
    end
end