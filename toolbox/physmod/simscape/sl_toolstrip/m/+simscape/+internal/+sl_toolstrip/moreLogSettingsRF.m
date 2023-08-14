function moreLogSettingsRF(cbinfo,action)





    if isempty(simscape.internal.sl_toolstrip.getSelectedBlock(cbinfo))
        action.enabled=false;
        return;
    end
    action.enabled=true;

    mdlHandle=simscape.internal.sl_toolstrip.getModelHandle(cbinfo);
    if(~isempty(mdlHandle))
        if(get_param(mdlHandle,'SimscapeLogType')=="none")
            action.enabled=false;
        else
            action.enabled=true;
        end
    end
end