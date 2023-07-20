function val=getRangeTargetFrequency(obj)



    if obj.isIPCoreGen

        hClockModule=obj.getClockModule;
        if isempty(hClockModule)
            val='none';
        else
            min=hClockModule.ClockMinMHz;
            max=hClockModule.ClockMaxMHz;
            val=sprintf('%s-%s',num2str(min),num2str(max));
        end
    elseif obj.isFILWorkflow
        val='5-200';
    else
        val='none';
    end

end