function logDataToggleSplitButtonRF(cbinfo,action)




    blkHandle=simscape.internal.sl_toolstrip.getSelectedBlock(cbinfo);
    if isempty(blkHandle)
        action.enabled=false;
        return;
    end
    action.enabled=true;

    action.enabled=0;
    if(~isempty(blkHandle)&&pmlog_is_logging_supported(blkHandle)&&...
        ~(bdIsLibrary(bdroot(blkHandle))))
        action.enabled=1;
        if(get_param(blkHandle,'LogSimulationData')=="off")
            action.selected=0;
        else
            action.selected=1;
        end

    end

end