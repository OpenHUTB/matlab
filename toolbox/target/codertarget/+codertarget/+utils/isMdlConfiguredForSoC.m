function out=isMdlConfiguredForSoC(hObj)





    out=false;
    if isa(hObj,'Simulink.ConfigSet')||isa(hObj,'Simulink.ConfigSetRef')
        cs=hObj;
    else
        cs=hObj.getConfigSet;
    end

    if cs.isValidParam('HardwareBoardFeatureSet')&&...
        isequal(get_param(cs,'HardwareBoardFeatureSet'),'SoCBlockset')
        out=true;
    end
end