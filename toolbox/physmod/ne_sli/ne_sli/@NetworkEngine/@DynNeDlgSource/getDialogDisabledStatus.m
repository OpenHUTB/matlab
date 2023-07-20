function disabled=getDialogDisabledStatus(hThis)





    if strcmp(get_param(bdroot(hThis.BlockHandle),'SimulationStatus'),'compiled')
        disabled=false;
        return
    end

    disabled=pmsl_ismodelrunning(hThis.BlockHandle);

end