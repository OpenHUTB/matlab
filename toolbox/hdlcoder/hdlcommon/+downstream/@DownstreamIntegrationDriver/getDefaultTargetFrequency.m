function inputFreq=getDefaultTargetFrequency(obj)


    if obj.isFILWorkflow
        inputFreq=25;
    else
        try
            hClockModule=obj.getClockModule;
            inputFreq=hClockModule.ClockInputMHz;
        catch
            inputFreq=0;
        end

    end















