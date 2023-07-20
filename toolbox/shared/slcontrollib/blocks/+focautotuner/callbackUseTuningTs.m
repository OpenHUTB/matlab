function callbackUseTuningTs(blk)







    if any(strcmpi(get_param(bdroot(blk),'SimulationStatus'),{'external','running','paused'}))
        return
    end

    maskObj=Simulink.Mask.get(blk);
    object=maskObj.Parameters.findobj('Name','TsTuning');
    if strcmp(get_param(blk,'UseTuningTs'),'on')
        object.Enabled='on';
    else
        object.Enabled='off';
    end