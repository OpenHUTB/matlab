function disallowLoggingRF(cbinfo,action)




    if isempty(simscape.internal.sl_toolstrip.getSelectedBlock(cbinfo))
        action.enabled=false;
        return;
    end
    action.enabled=true;

    mdlHandle=simscape.internal.sl_toolstrip.getModelHandle(cbinfo);
    action.selected=0;
    if(~isempty(mdlHandle)&&get_param(mdlHandle,'SimscapeLogType')=="none")
        action.selected=1;
    end
end