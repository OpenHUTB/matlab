function hwDiagShowInSDICallback(hObj,hDlg,tag,~)





    hCS=hObj.getConfigSet();

    showInSDI=logical(hDlg.getWidgetValue(tag));
    codertarget.data.setParameterValue(hCS,...
    DAStudio.message('codertarget:ui:HWDiagShowInSDIStorage'),showInSDI);



    if showInSDI&&locIsCodeInstrumentationProfiler(hCS)
        set_param(hCS,'CodeExecutionProfiling','on');
    else
        set_param(hCS,'CodeExecutionProfiling','off');
        set_param(hCS,'CodeProfilingInstrumentation','off');
    end
    locManageTargetServices(hCS);
end


function locManageTargetServices(hCS)
    transport=codertarget.attributes.getExtModeData('Transport',hCS);
    useXCP=isequal(transport,Simulink.ExtMode.Transports.XCPTCP.Transport);
    if~useXCP&&locIsCodeInstrumentationProfiler(hCS)
        hwRec=codertarget.data.getParameterValue(hCS,...
        DAStudio.message('codertarget:ui:HWDiagRecordingStorage'));
        val=isequal(hwRec,'Continuous');
        codertarget.data.setParameterValue(hCS,'TargetServices.Running',val);
    end
end


function ret=locIsCodeInstrumentationProfiler(hCS)
    paramName=DAStudio.message('codertarget:ui:HWDiagInstrumentationStorage');
    ret=codertarget.data.isParameterInitialized(hCS,paramName)&&...
    isequal(codertarget.data.getParameterValue(hCS,paramName),'Code');
end
