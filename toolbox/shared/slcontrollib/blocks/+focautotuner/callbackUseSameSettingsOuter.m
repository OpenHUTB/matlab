function callbackUseSameSettingsOuter(blkh)






    blkObj=get_param(blkh,'Object');
    maskObj=get_param(blkh,'MaskObject');

    isUseSameSettings=strcmp(blkObj.UseSameSettingsOuter,'on');
    isTuneBothLoops=strcmp(blkObj.TuneSpeedLoop,'on')&&strcmp(blkObj.TuneFluxLoop,'on');
    isEnableSameSettings=isUseSameSettings&&isTuneBothLoops;


    localSetDlgObjVisibility(maskObj,'grpTuneIndividualLoopsOuter',~isEnableSameSettings)
    localSetDlgObjVisibility(maskObj,'grpExperimentSettingsIndividualOuter',~isEnableSameSettings)
    localSetDlgObjVisibility(maskObj,'grpTuneAllLoopsOuter',isEnableSameSettings)
    localSetDlgObjVisibility(maskObj,'grpExperimentSettingsAllOuter',isEnableSameSettings)

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