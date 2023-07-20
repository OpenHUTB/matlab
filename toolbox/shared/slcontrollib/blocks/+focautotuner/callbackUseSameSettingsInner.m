function callbackUseSameSettingsInner(blkh)






    blkObj=get_param(blkh,'Object');
    maskObj=get_param(blkh,'MaskObject');

    isUseSameSettings=strcmp(blkObj.UseSameSettingsInner,'on');
    isTuneBothLoops=strcmp(blkObj.TuneDaxisLoop,'on')&&strcmp(blkObj.TuneQaxisLoop,'on');
    isEnableSameSettings=isUseSameSettings&&isTuneBothLoops;


    localSetDlgObjVisibility(maskObj,'grpTuneIndividualLoopsInner',~isEnableSameSettings)
    localSetDlgObjVisibility(maskObj,'grpExperimentSettingsIndividualInner',~isEnableSameSettings)
    localSetDlgObjVisibility(maskObj,'grpTuneAllLoopsInner',isEnableSameSettings)
    localSetDlgObjVisibility(maskObj,'grpExperimentSettingsAllInner',isEnableSameSettings)

end

function localSetDlgObjVisibility(maskObj,dlgCtrlStr,En)
    dlgObj=maskObj.getDialogControl(dlgCtrlStr);
    if En
        dlgObj.Enabled='on';
        dlgObj.Visible='on';
    else
        dlgObj.Enabled='off';
        dlgObj.Visible='off';
    end
end