function validateOverrideSettings(h)










    mi=get_param(h.Name,'DataLoggingOverride');
    assert(~isempty(mi));


    objMdlName=mi.Model;
    [mi,bInvalidSignals]=mi.validate(...
    h.Name,...
    false,...
    false,...
    true,...
    'remove');



    if bInvalidSignals||~strcmp(objMdlName,h.Name)
        preserveDirty=[];%#ok<*NASGU>

        if~bInvalidSignals&&~strcmp(objMdlName,h.Name)
            preserveDirty=Simulink.PreserveDirtyFlag(h.Name,'blockDiagram');
        end
        me=SigLogSelector.getExplorer;
        if~isempty(me)
            me.isSettingDataLoggingOveride=true;
        end
        set_param(h.Name,'DataLoggingOverride',mi);
        if~isempty(me)
            me.isSettingDataLoggingOveride=false;
        end
    end

end

