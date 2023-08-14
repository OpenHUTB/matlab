function packageCode(cbInfo,action)









    cs=getActiveConfigSet(cbInfo.model.handle);
    if isa(cs,'Simulink.ConfigSetRef')
        try
            value=get_param(cs,'PackageGeneratedCodeAndArtifacts');
        catch

            value='off';
        end
        action.enabled=(value=="on");
    else
        action.enabled=true;
    end
