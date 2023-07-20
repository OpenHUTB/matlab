function hwDiagRecordingCallback(hObj,hDlg,tag,~)





    hCS=hObj.getConfigSet();

    recordIdx=logical(hDlg.getWidgetValue(tag));
    ud=hDlg.userData;
    parValue=ud.Entries{recordIdx+1};
    parStore=DAStudio.message('codertarget:ui:HWDiagRecordingStorage');
    codertarget.data.setParameterValue(hCS,parStore,parValue);

    if codertarget.profile.internal.isKernelProfilingEnabled(hCS),return;end
    locInitializeTargetServicesIfNeeded(hCS);
    param='TargetServices.Running';
    switch(parValue)
    case 'Continuous'
        codertarget.data.setParameterValue(hCS,param,true);
    case 'Single-shot'
        codertarget.data.setParameterValue(hCS,param,false);
    end
end


function locInitializeTargetServicesIfNeeded(hCS)
    param='TargetServices';
    if~codertarget.data.isParameterInitialized(hCS,param)
        codertarget.data.setParameterValue(hCS,param,struct('Running',false));
    end
end