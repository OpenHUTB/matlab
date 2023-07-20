function out=supportsFieldProgramming(hObj)







    if isa(hObj,'CoderTarget.SettingsController')
        hObj=hObj.getConfigSet();
    elseif ischar(hObj)
        hObj=getActiveConfigSet(hObj);
    else
        assert(isa(hObj,'Simulink.ConfigSet'),'getAttribute called with a wrong argument');
    end
    if codertarget.data.isParameterInitialized(hObj,'Runtime.BootloaderProgrammingSupport')
        out=isequal(codertarget.data.getParameterValue(hObj,'Runtime.BootloaderProgrammingSupport'),1);
    else
        out=0;
    end
end