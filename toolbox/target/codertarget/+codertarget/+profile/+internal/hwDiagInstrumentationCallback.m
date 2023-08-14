function hwDiagInstrumentationCallback(hObj,hDlg,tag,~)





    hCS=hObj.getConfigSet();

    instrIdx=logical(hDlg.getWidgetValue(tag));
    ud=hDlg.userData;
    parValue=ud.Entries{instrIdx+1};
    parStore=DAStudio.message('codertarget:ui:HWDiagInstrumentationStorage');
    codertarget.data.setParameterValue(hCS,parStore,parValue);

    switch(parValue)
    case 'Kernel'
        set_param(hCS,'CodeExecutionProfiling','off');
        set_param(hCS,'CodeProfilingInstrumentation','off');
    case 'Code'
        set_param(hCS,'CodeExecutionProfiling','on');
    end
    locManageTargetServices(hCS);
end


function locManageTargetServices(hCS)
    transport=codertarget.attributes.getExtModeData('Transport',hCS);
    useXCP=isequal(transport,Simulink.ExtMode.Transports.XCPTCP.Transport);
    if locIsCodeInstrumentationProfiler(hCS)
        if~useXCP
            hwRec=codertarget.data.getParameterValue(hCS,...
            DAStudio.message('codertarget:ui:HWDiagRecordingStorage'));
            val=isequal(hwRec,'Continuous');
            codertarget.data.setParameterValue(hCS,'TargetServices.Running',val);
        end
    else
        codertarget.data.setParameterValue(hCS,'TargetServices.Running',false);
    end
end


function ret=locIsCodeInstrumentationProfiler(hCS)
    paramName=DAStudio.message('codertarget:ui:HWDiagInstrumentationStorage');
    ret=codertarget.data.isParameterInitialized(hCS,paramName)&&...
    isequal(codertarget.data.getParameterValue(hCS,paramName),'Code');
end
