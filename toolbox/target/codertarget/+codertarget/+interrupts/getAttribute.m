function ret=getAttribute(hObj,PropName)





    if isa(hObj,'CoderTarget.SettingsController')
        hObj=hObj.getConfigSet();
    elseif ischar(hObj)
        hObj=getActiveConfigSet(hObj);
    else
        assert(isa(hObj,'Simulink.ConfigSet')||...
        isa(hObj,'Simulink.ConfigSetRef')||...
        isa(hObj,'coder.CodeConfig'),...
        [mfilename,' called with a wrong argument']);
    end

    intdef=codertarget.interrupts.internal.getHardwareBoardInterruptInfo(hObj);
    ret=intdef.(PropName);
end

