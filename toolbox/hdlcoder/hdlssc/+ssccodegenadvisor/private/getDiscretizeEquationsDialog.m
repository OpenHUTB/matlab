function tbTab=getDiscretizeEquationsDialog(mdladvObj)













    sscCodeGenWorkflowObj=mdladvObj.getCheckObj('com.mathworks.hdlssc.ssccodegenadvisor.workflowObjectCheck').ResultData;

    description.Type='text';
    description.Name=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_checks:discretizeCheckTitleTips');
    description.RowSpan=[1,1];
    descriptionSection.Type='panel';
    descriptionSection.Items={description};
    descriptionSection.LayoutGrid=[1,4];
    descriptionSection.RowSpan=[1,1];
    descriptionSection.ColSpan=[1,4];
    descriptionSection.Enabled=true;


    sampleTime_lbl.Type='text';
    sampleTime_lbl.Name=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_checks:discretizeChangeSampleTimeTips');
    sampleTime_lbl.Tag='com.mathworks.hdlssc.ssccodegenadvisor.tipsTag';
    sampleTime_lbl.RowSpan=[2,2];
    sampleTime_lbl.ColSpan=[1,1];

    sampleTime_field.Type='text';
    sampleTime_field.Tag='com.mathworks.hdlssc.ssccodegenadvisor.sampleTimeTag';
    sampleTime_field.Name=utilUpdateSampleTime(sscCodeGenWorkflowObj);
    sampleTime_field.RowSpan=[2,2];
    sampleTime_field.ColSpan=[2,2];

    hyperlinkWhatIsThis.Type='hyperlink';
    hyperlinkWhatIsThis.Name=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_checks:discretizeChangeSampleTimeHyperlink');
    hyperlinkWhatIsThis.Tag='com.mathworks.hdlssc.ssccodegenadvisor.changeSampleTime';
    hyperlinkWhatIsThis.Enabled=true;
    hyperlinkWhatIsThis.RowSpan=[3,3];
    hyperlinkWhatIsThis.ColSpan=[1,4];
    hyperlinkWhatIsThis.MatlabMethod='ssccodegenadvisor.dialogHyperlinkCallback';
    hyperlinkWhatIsThis.MatlabArgs={'%tag'};

    tipsSection.Type='group';
    tipsSection.Name='Tips';
    tipsSection.Items=[{sampleTime_lbl},{sampleTime_field},{hyperlinkWhatIsThis}];
    tipsSection.LayoutGrid=[1,4];
    tipsSection.ColStretch=[0,0,0,1];
    tipsSection.RowSpan=[2,2];
    tipsSection.ColSpan=[1,4];
    tipsSection.Enabled=true;


    tbTab.Items={descriptionSection,tipsSection};
    tbTab.LayoutGrid=[2,4];
    tbTab.RowStretch=[0,0,1];
    tbTab.Name=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_checks:discretizeCheckTitle');
