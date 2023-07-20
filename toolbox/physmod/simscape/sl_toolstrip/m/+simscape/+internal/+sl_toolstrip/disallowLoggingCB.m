function disallowLoggingCB(cbinfo,action)



    mdlHandle=simscape.internal.sl_toolstrip.getModelHandle(cbinfo);
    if(~isempty(mdlHandle))
        set_param(mdlHandle,'SimscapeLogType','none');
        action.selected=1;
    end
end