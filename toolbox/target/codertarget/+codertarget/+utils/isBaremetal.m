function ret=isBaremetal(hObj)




    if isa(hObj,'Simulink.ConfigSet')||...
        isa(hObj,'Simulink.ConfigSetRef')
        hCS=hObj;
    elseif isa(hObj,'CoderTarget.SettingsController')
        hCS=hObj.getConfigSet;
    else

        hCS=getActiveConfigSet(hObj);
    end

    if~codertarget.data.isValidParameter(hCS,'RTOS')
        ret=true;
    else
        ret=isequal(codertarget.data.getParameterValue(hCS,'RTOS'),'Baremetal');
    end

end


