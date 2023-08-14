function ret=isXCPBuild(obj)




    if isa(obj,'Simulink.ConfigSet')||...
        isa(obj,'Simulink.ConfigSetRef')
        hCS=obj;
    elseif isa(obj,'CoderTarget.SettingsController')
        hCS=obj.getConfigSet;
    else
        hCS=getActiveConfigSet(obj);
    end

    ret=coder.internal.xcp.isXCPTarget(hCS);
end
