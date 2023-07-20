function utilUseExternal(blkh,params,chkpara)







    if any(strcmpi(get_param(bdroot(blkh),'SimulationStatus'),{'external','running','paused'}))
        return
    end


    maskObj=Simulink.Mask.get(blkh);
    for ii=1:length(params)
        object=maskObj.Parameters.findobj('Name',params{ii});
        if strcmp(get_param(blkh,chkpara),'on')
            object.Enabled='off';
        else
            object.Enabled='on';
        end
    end