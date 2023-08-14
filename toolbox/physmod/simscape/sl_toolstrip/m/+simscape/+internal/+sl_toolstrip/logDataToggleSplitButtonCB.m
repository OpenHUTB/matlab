function logDataToggleSplitButtonCB(cbinfo,action)



    blkHandle=simscape.internal.sl_toolstrip.getSelectedBlock(cbinfo);
    if(~isempty(blkHandle)&&pmlog_is_logging_supported(blkHandle))
        if(get_param(blkHandle,'LogSimulationData')=="off")
            set_param(blkHandle,'LogSimulationData',"on");
            action.selected=1;
        else
            set_param(blkHandle,'LogSimulationData',"off");
            action.selected=0;
        end
    end
end