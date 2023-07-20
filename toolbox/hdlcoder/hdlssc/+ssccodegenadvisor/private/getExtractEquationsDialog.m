function tbTab=getExtractEquationsDialog(mdladvObj)













    sscCodeGenWorkflowObj=mdladvObj.getCheckObj('com.mathworks.hdlssc.ssccodegenadvisor.workflowObjectCheck').ResultData;


    description.Type='text';
    description.Name=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_checks:getStateSpaceParametersCheckTitleTips');
    description.RowSpan=[1,1];
    descriptionSection.Type='panel';
    descriptionSection.Items={description};
    descriptionSection.LayoutGrid=[1,4];
    descriptionSection.RowSpan=[1,1];
    descriptionSection.ColSpan=[1,4];
    descriptionSection.Enabled=true;


    simulationStopTime_lbl.Type='text';
    simulationStopTime_lbl.Name=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_checks:getStateSpaceParametersCheckSimulationTimeName');
    simulationStopTime_lbl.RowSpan=[2,2];
    simulationStopTime_lbl.ColSpan=[1,1];

    simulationStopTime.Type='edit';
    simulationStopTime.Value=utilUpdateSimulationStopTime(sscCodeGenWorkflowObj);
    simulationStopTime.Tag='com.mathworks.hdlssc.ssccodegenadvisor.simulationStopTimeTag';
    simulationStopTime.Enabled=false;
    simulationStopTime.RowSpan=[2,2];
    simulationStopTime.ColSpan=[2,6];

    simulationStopTimeSection.Type='panel';
    simulationStopTimeSection.Items=[{simulationStopTime_lbl},...
    {simulationStopTime}];
    simulationStopTimeSection.LayoutGrid=[1,6];
    simulationStopTimeSection.ColStretch=[0,0,0,0,0,1];
    simulationStopTimeSection.RowSpan=[2,2];
    simulationStopTimeSection.ColSpan=[1,4];
    simulationStopTimeSection.Enabled=true;



    tips.Type='text';
    tips.Name=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_checks:getStateSpaceParametersCheckNote');
    tips.Tag='com.mathworks.hdlssc.ssccodegenadvisor.tipsTag';
    tips.RowSpan=[3,3];
    tips.ColSpan=[1,1];

    hyperlinkWhatIsThis.Type='hyperlink';
    hyperlinkWhatIsThis.Name=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_checks:whatsThis');
    hyperlinkWhatIsThis.Tag='com.mathworks.hdlssc.ssccodegenadvisor.simulationStopTime';
    hyperlinkWhatIsThis.Enabled=true;
    hyperlinkWhatIsThis.RowSpan=[3,3];
    hyperlinkWhatIsThis.ColSpan=[2,2];
    hyperlinkWhatIsThis.MatlabMethod='ssccodegenadvisor.dialogHyperlinkCallback';
    hyperlinkWhatIsThis.MatlabArgs={'%tag'};

    tipsSection.Type='group';
    tipsSection.Name='Tips';
    tipsSection.Items=[{tips},{hyperlinkWhatIsThis}];
    tipsSection.LayoutGrid=[1,6];
    tipsSection.RowStretch=1;
    tipsSection.ColStretch=[1,1,1,1,1,1];
    tipsSection.RowSpan=[3,3];
    tipsSection.ColSpan=[1,4];
    tipsSection.Enabled=true;




    tbTab.Items={descriptionSection,simulationStopTimeSection,tipsSection};
    tbTab.LayoutGrid=[3,5];
    tbTab.ColStretch=[0,0,0,0,1];
    tbTab.Name=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_checks:getStateSpaceParametersCheckTitle');
