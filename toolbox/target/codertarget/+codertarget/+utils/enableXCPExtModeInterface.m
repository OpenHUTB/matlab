function enableXCPExtModeInterface(hObj)





    if isa(hObj,'Simulink.ConfigSet')||...
        isa(hObj,'Simulink.ConfigSetRef')
        hCS=hObj;
    elseif isa(hObj,'CoderTarget.SettingsController')
        hCS=hObj.getConfigSet;
    else

        hCS=getActiveConfigSet(hObj);
    end

    tlcOpts=get_param(hCS,'TLCOptions');
    tlcOpts=[tlcOpts,' -aExtModeXCPClassicInterface=0'];
    set_param(hCS,'TLCOptions',tlcOpts);
end


