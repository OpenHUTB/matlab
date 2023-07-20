function coverageSwitchCB(cbinfo)




    cs=getActiveConfigSet(cbinfo.model.name);
    csref=isa(cs,'Simulink.ConfigSetRef');

    if(cbinfo.EventData)
        covEnable='on';
    else
        covEnable='off';
    end

    if csref
        configset.reference.overrideParameter(cbinfo.model.name,'CovEnable',covEnable);
    else
        set_param(cbinfo.model.name,'CovEnable',covEnable);
    end
end
