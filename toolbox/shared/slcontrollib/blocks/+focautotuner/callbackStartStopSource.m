function callbackStartStopSource(blkh)







    if~strcmpi(get_param(bdroot(blkh),'SimulationStatus'),'stopped')
        return
    end

    blkObj=get_param(blkh,'Object');
    maskObj=get_param(blkh,'MaskObject');

    isUseExternalSource=strcmp(blkObj.UseExternalSourceStartStop,'on');
    dlgObj=maskObj.getDialogControl('tblExpStartStopTimes');
    if isUseExternalSource
        dlgObj.Enabled='off';
        dlgObj.Visible='off';
    else
        dlgObj.Enabled='on';
        dlgObj.Visible='on';
    end


    object=maskObj.Parameters.findobj('Name','UseExternalActiveLoop');
    if isUseExternalSource
        object.Enabled='off';
    else
        object.Enabled='on';
    end

end