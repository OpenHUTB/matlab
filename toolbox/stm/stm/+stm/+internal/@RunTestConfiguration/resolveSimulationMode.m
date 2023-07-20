function out=resolveSimulationMode(simMode)

    simMode=lower(simMode);
    if strcmpi(simMode,'Rapid Accelerator')
        out='rapid';
    elseif strcmp(simMode,stm.internal.MRT.share.getString('stm:SystemUnderTestView:ModelSettings'))
        out='';
    else
        out=simMode;
    end
end

