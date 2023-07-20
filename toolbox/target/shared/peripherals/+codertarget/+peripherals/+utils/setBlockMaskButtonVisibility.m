function setBlockMaskButtonVisibility(blkH,buttonName)







    blkMaskObj=get_param(blkH,'MaskObject');
    peripheralConfigBtn=blkMaskObj.getDialogControl(buttonName);


    if codertarget.targethardware.arePeripheralsSupported(bdroot(blkH))
        peripheralConfigBtn.Visible='on';
    else
        peripheralConfigBtn.Visible='off';
    end
end
