function clockFreq=getTargetFrequency(obj)



    if obj.isFILWorkflow
        if isempty(obj.hFilBuildInfo)
            clockFreq=0;
        else
            strFreq=obj.hFilBuildInfo.FPGASystemClockFrequency;
            clockFreq=str2double(strFreq(1:end-3));
        end
    else

        hClockModule=obj.getClockModule;

        if isempty(hClockModule)
            clockFreq=0;
        else
            clockFreq=hClockModule.ClockOutputMHz;
        end
    end

end