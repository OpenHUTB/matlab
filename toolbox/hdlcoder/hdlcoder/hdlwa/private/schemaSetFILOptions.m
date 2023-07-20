function addon=schemaSetFILOptions(task)






    addon.DialogTitle=DAStudio.message('hdlcoder:hdlverifier:FILOptionsStepTitle');

    anaG=l_getAnalysisGroup(task);
    anaG.RowSpan=[1,3];
    anaG.ColSpan=[1,5];

    hmdlAdvCheck=task.Check;


    runBtn.Name=DAStudio.message('Simulink:tools:MARunThisTask');
    runBtn.Tag='SetFILOptionsRunAdvisor';
    runBtn.Type='pushbutton';
    runBtn.RowSpan=[4,4];
    runBtn.ColSpan=[1,1];
    runBtn.Alignment=5;
    runBtn.Enabled=task.Selected;
    runBtn.DialogRefresh=true;
    runBtn.Source=task;
    runBtn.ObjectMethod='runTaskAdvisor';
    runBtn.MethodArgs={};
    runBtn.ArgDataTypes={};

    ResultMsg.Name=[DAStudio.message('Simulink:tools:MAResult'),':  '];
    ResultMsg.Type='text';
    ResultMsg.Alignment=5;
    ResultMsg.Tag='text_ResultMsg';
    ResultMsg.RowSpan=[5,5];
    ResultMsg.ColSpan=[1,1];

    ResultIcon.Type='image';
    ResultIcon.RowSpan=[5,5];
    ResultIcon.ColSpan=[2,2];
    ResultIcon.Alignment=5;
    ResultIcon.FilePath=fullfile(matlabroot,task.getDisplayIcon);

    switch(task.State)
    case ModelAdvisor.CheckStatus.NotRun
        overallstatusString=DAStudio.message('Simulink:tools:MANotRunMsg');
    case ModelAdvisor.CheckStatus.Informational
        overallstatusString=DAStudio.message('Simulink:tools:MAWaivedMsg');
    case ModelAdvisor.CheckStatus.Passed
        overallstatusString=DAStudio.message('Simulink:tools:MAPassedMsg');
    case ModelAdvisor.CheckStatus.Warning
        overallstatusString=DAStudio.message('Simulink:tools:MAWarning');
    case ModelAdvisor.CheckStatus.Failed
        overallstatusString=DAStudio.message('Simulink:tools:MAFailedMsg');
    otherwise
        overallstatusString='';
    end
    ResultStatusString.Name=overallstatusString;
    ResultStatusString.Type='text';
    ResultStatusString.RowSpan=[5,5];
    ResultStatusString.ColSpan=[3,3];

    addon.Items={anaG,runBtn,ResultMsg,ResultIcon,ResultStatusString};

    addon.LayoutGrid=[5,5];
    addon.ColStretch=[0,0,0,1,1];
    addon.RowStretch=[1,1,1,0,0];




    addon.PostApplyCallback='hdlwa.setOptionsCallBack';
    addon.PostApplyArgs={'%source'};
    addon.PostApplyArgsDT={'handle'};

end

function paramG=l_getParamGroup(task)
    mdladvObj=task.MAObj;
    system=mdladvObj.System;
    hModel=bdroot(system);
    hDriver=hdlmodeldriver(hModel);
    hDI=hDriver.DownstreamIntegrationDriver;


    [BoardCommInfo,showAdvancedOptions,showIPWidget]=hDI.hFilWizardDlg.getConnectionWidget(hDI.getOption('Board').Value);%#ok<ASGLU>
    BoardCommInfo.RowSpan=[1,1];
    BoardCommInfo.ColSpan=[1,1];


    EnableHWBufferWidget=hDI.hFilWizardDlg.getEnableHWBufferWidget;
    EnableHWBufferWidget.RowSpan=[2,2];



    IpAddrTxt.Type='text';
    IpAddrTxt.Tag='edaIpAddrTxt';
    IpAddrTxt.Name=hDI.hFilWizardDlg.getCatalogMsgStr('IpAddr_Text');
    IpAddrTxt.RowSpan=[1,1];
    IpAddrTxt.ColSpan=[1,1];

    IpAddrEdt.Type='edit';
    IpAddrEdt.Tag='edaIpAddrEdt';
    IpAddrEdt.RowSpan=[1,1];
    IpAddrEdt.ColSpan=[2,2];
    IpAddrEdt.Source=hDI.hFilWizardDlg;
    IpAddrEdt.Value=hDI.hFilWizardDlg.BuildInfo.IPAddress;
    IpAddrEdt.ObjectMethod='onChangeAddr';
    IpAddrEdt.MethodArgs={'%dialog','%tag','%value'};
    IpAddrEdt.ArgDataTypes={'handle','string','string'};


    MacAddrTxt.Type='text';
    MacAddrTxt.Tag='edaMacAddrTxt';
    MacAddrTxt.Name=hDI.hFilWizardDlg.getCatalogMsgStr('MacAddr_Text');
    MacAddrTxt.RowSpan=[2,2];
    MacAddrTxt.ColSpan=[1,1];


    MacAddrEdt.Type='edit';
    MacAddrEdt.Tag='edaMacAddrEdt';
    MacAddrEdt.RowSpan=[2,2];
    MacAddrEdt.ColSpan=[2,2];
    MacAddrEdt.Source=hDI.hFilWizardDlg;
    MacAddrEdt.Value=hDI.hFilWizardDlg.BuildInfo.MACAddress;
    MacAddrEdt.ObjectMethod='onChangeAddr';
    MacAddrEdt.MethodArgs={'%dialog','%tag','%value'};
    MacAddrEdt.ArgDataTypes={'handle','string','string'};

    AddrGroup.Type='group';
    AddrGroup.Name=DAStudio.message('hdlcoder:hdlverifier:BoardAddresses');
    AddrGroup.Flat=false;
    AddrGroup.LayoutGrid=[2,2];
    AddrGroup.RowSpan=[3,3];
    AddrGroup.ColSpan=[1,2];
    AddrGroup.Items={IpAddrTxt,IpAddrEdt,MacAddrTxt,MacAddrEdt};

    SrcGroup=hDI.hFilWizardDlg.getSrcFileWidgets;
    SrcGroup.Name=DAStudio.message('hdlcoder:hdlverifier:FILOptionsAdditionalSrc');
    SrcGroup.RowSpan=[4,4];
    SrcGroup.ColSpan=[1,2];

    paramG.Type='group';
    paramG.Tag='FIL_options_input_parameter';
    paramG.Name=DAStudio.message('Simulink:tools:MAInputParameters');
    paramG.LayoutGrid=[4,2];
    paramG.ColStretch=[0,1];
    if showIPWidget
        paramG.Items={BoardCommInfo,EnableHWBufferWidget,AddrGroup,SrcGroup};
    else
        paramG.Items={BoardCommInfo,SrcGroup};
    end
end

function anaG=l_getAnalysisGroup(task)

    descTxt.Type='text';
    descTxt.Name=DAStudio.message('hdlcoder:hdlverifier:FILOptionsStepDesc');
    descTxt.Tag='descTxt';
    descTxt.WordWrap=true;
    descTxt.RowSpan=[1,1];
    descTxt.ColSpan=[1,4];

    paramG=l_getParamGroup(task);
    paramG.RowSpan=[2,2];
    paramG.ColSpan=[1,4];

    anaG.Type='group';
    anaG.Name=DAStudio.message('Simulink:tools:MAAnalysis');
    anaG.Items={descTxt,paramG};
    anaG.LayoutGrid=[3,4];
end

