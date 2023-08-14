function signalLoggingTab=createSignalLoggingTab(hObj)











    chkLogSigData.Tag='chkLogSigData';
    chkLogSigData.Type='checkbox';
    chkLogSigData.Name=DAStudio.message('Simulink:dialog:SigpropChkLogSigDataName');
    chkLogSigData.Source=hObj;
    chkLogSigData.ObjectProperty='DataLogging';
    chkLogSigData.Mode=1;
    chkLogSigData.DialogRefresh=true;
    chkLogSigData.ColSpan=[1,1];


    chkTestPoint.Type='checkbox';
    chkTestPoint.Name=DAStudio.message('Simulink:dialog:SigpropChkTestPointName');
    chkTestPoint.Tag='chkTestPoint';
    chkTestPoint.ObjectProperty='TestPoint';
    chkTestPoint.Source=hObj;
    chkTestPoint.ColSpan=[2,2];
    chkTestPoint.DialogRefresh=true;
    chkTestPoint.Mode=1;


    spacer1.Tag='spacer1';
    spacer1.Type='panel';
    spacer1.ColSpan=[3,3];

    pnl1.Tag='pnl1';
    pnl1.Type='panel';
    pnl1.LayoutGrid=[1,3];
    pnl1.Items={chkLogSigData,chkTestPoint,spacer1};
    pnl1.ColStretch=[0,0,1];
    pnl1.RowSpan=[1,1];





    cmbLog.Tag='cmbLog';
    cmbLog.Type='combobox';
    cmbLog.Source=hObj;
    cmbLog.ObjectProperty='DataLoggingNameMode';
    cmbLog.Values=[0,1];
    cmbLog.Entries={DAStudio.message('Simulink:dialog:SigpropCmbLogEntryUseSignalName'),...
    DAStudio.message('Simulink:dialog:SigpropCmbLogEntryCustom')};
    cmbLog.Mode=1;
    cmbLog.DialogRefresh=true;
    cmbLog.ColSpan=[1,1];
    cmbLog.Enabled=convertToBool(hObj.dataLogging);

    txtName.Tag='txtName';
    txtName.Type='edit';
    txtName.Source=hObj;
    txtName.ObjectProperty='UserSpecifiedLogName';
    txtName.ColSpan=[2,2];
    txtName.Enabled=convertToBool(hObj.dataLogging)&&~(strcmp(hObj.dataLoggingNameMode,'SignalName'));
    txtName.Mode=1;

    grpLog.Tag='grpLog';
    grpLog.Type='group';
    grpLog.Name=DAStudio.message('Simulink:dialog:SigpropGrpLogName');
    grpLog.LayoutGrid=[1,2];
    grpLog.Items={cmbLog,txtName};
    grpLog.RowSpan=[2,2];





    chkDataPoints.Tag='chkDataPoints';
    chkDataPoints.Type='checkbox';
    chkDataPoints.Name=[DAStudio.message('Simulink:dialog:SigpropLblDataPointsName'),' '];
    chkDataPoints.RowSpan=[1,1];
    chkDataPoints.ColSpan=[1,1];
    chkDataPoints.Source=hObj;
    chkDataPoints.ObjectProperty='DataLoggingLimitDataPoints';
    chkDataPoints.Enabled=convertToBool(hObj.dataLogging);
    chkDataPoints.DialogRefresh=true;
    chkDataPoints.Mode=1;

    txtDataPoints.Tag='txtDataPoints';
    txtDataPoints.Type='edit';
    txtDataPoints.Name=chkDataPoints.Name;
    txtDataPoints.HideName=true;
    txtDataPoints.Source=hObj;
    txtDataPoints.ObjectProperty='DataLoggingMaxPoints';
    txtDataPoints.Mode=1;
    txtDataPoints.RowSpan=[1,1];
    txtDataPoints.ColSpan=[2,2];
    txtDataPoints.Enabled=convertToBool(hObj.dataLogging)&&convertToBool(hObj.DataLoggingLimitDataPoints);

    chkDecimation.Tag='chkDecimation';
    chkDecimation.Type='checkbox';
    chkDecimation.Name=[DAStudio.message('Simulink:dialog:SigpropLblDecimationName'),' '];
    chkDecimation.Source=hObj;
    chkDecimation.ObjectProperty='DataLoggingDecimateData';
    chkDecimation.RowSpan=[2,2];
    chkDecimation.ColSpan=[1,1];
    chkDecimation.Enabled=convertToBool(hObj.dataLogging);
    chkDecimation.DialogRefresh=1;
    chkDecimation.Mode=1;

    txtDecimation.Tag='txtDecimation';
    txtDecimation.Type='edit';
    txtDecimation.Name=chkDataPoints.Name;
    txtDecimation.HideName=true;
    txtDecimation.Source=hObj;
    txtDecimation.ObjectProperty='DataLoggingDecimation';
    txtDecimation.RowSpan=[2,2];
    txtDecimation.ColSpan=[2,2];
    txtDecimation.Mode=1;
    txtDecimation.Enabled=convertToBool(hObj.DataLoggingDecimateData)&&convertToBool(hObj.dataLogging);

    lblSampleTime.Tag='lblSampleTime';
    lblSampleTime.Name=DAStudio.message('Simulink:dialog:SigpropLblSampleTime');
    lblSampleTime.Type='text';
    lblSampleTime.RowSpan=[3,3];
    lblSampleTime.ColSpan=[1,1];
    lblSampleTime.Enabled=convertToBool(hObj.dataLogging);
    lblSampleTime.DialogRefresh=1;
    lblSampleTime.Mode=1;

    txtSampleTime.Tag='txtSampleTime';
    txtSampleTime.Type='edit';
    txtSampleTime.Name=lblSampleTime.Name;
    txtSampleTime.HideName=true;
    txtSampleTime.ObjectProperty='DataLoggingSampleTime';
    txtSampleTime.Mode=1;
    txtSampleTime.DialogRefresh=true;
    txtSampleTime.RowSpan=[3,3];
    txtSampleTime.ColSpan=[2,2];
    txtSampleTime.Enabled=convertToBool(hObj.dataLogging);

    grpData.Tag='grpData';
    grpData.Type='group';
    grpData.Name=DAStudio.message('Simulink:dialog:SigpropGrpDataName');

    grpData.LayoutGrid=[3,2];
    grpData.Items={chkDataPoints,txtDataPoints,...
    chkDecimation,txtDecimation,...
    lblSampleTime,txtSampleTime};
    grpData.RowSpan=[4,3];

    groupspacer.Type='panel';
    groupspacer.RowSpan=[4,4];

    signalLoggingTab.Tag='tab1';
    signalLoggingTab.Name=DAStudio.message('Simulink:dialog:SigpropTabOneName');
    signalLoggingTab.Items={pnl1,grpLog,grpData,groupspacer};
    signalLoggingTab.LayoutGrid=[4,1];
    signalLoggingTab.RowStretch=[0,0,0,1];

end

function ret=convertToBool(x)
    if(isa(x,'logical'))
        ret=x;
    else
        ret=strcmp(x,'on');
    end
end
