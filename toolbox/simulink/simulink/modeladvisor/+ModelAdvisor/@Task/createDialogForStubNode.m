

function[addonStruct]=createDialogForStubNode(this)


    groupRowIndex=1;


    AnalysisGroup.Type='group';
    AnalysisGroup.Name=DAStudio.message('Simulink:tools:MAAnalysis');
    AnalysisGroup.RowSpan=[groupRowIndex,groupRowIndex];
    AnalysisGroup.ColSpan=[1,10];

    row_ind=1;
    AnalyzeItems={};


    WfDes.Name=this.Description;
    WfDes.Type='text';
    WfDes.Tag='text_Description';
    WfDes.Alignment=0;
    WfDes.WordWrap=true;
    WfDes.RowSpan=[row_ind,row_ind];
    WfDes.ColSpan=[1,10];
    AnalyzeItems{end+1}=WfDes;



    row_ind=row_ind+1;
    if isa(this.ParentObj,'ModelAdvisor.Procedure')
        analyze.Name=DAStudio.message('Simulink:tools:MARunThisTask');
    else
        analyze.Name=DAStudio.message('Simulink:tools:MARunThisCheck');
    end
    analyze.Tag='RunAdvisor';
    analyze.Type='pushbutton';
    analyze.RowSpan=[1,1];
    analyze.ColSpan=[1,2];
    analyze.Alignment=5;
    analyze.Enabled=false;
    analyze.DialogRefresh=true;



    analyze.MatlabMethod='runTaskAdvisor';
    analyze.MatlabArgs={this};
    analyzeVgrp.Type='group';
    analyzeVgrp.Name='';
    analyzeVgrp.Flat=true;
    analyzeVgrp.RowSpan=[row_ind,row_ind];
    analyzeVgrp.ColSpan=[1,10];
    analyzeVgrp.ColStretch=[0,0,1,0,0,1,1,1,1,1];
    analyzeVgrp.LayoutGrid=[1,10];
    analyzeVgrp.Items={analyze};
    AnalyzeItems{end+1}=analyzeVgrp;



    row_ind=row_ind+1;
    ResultMsgPanel.Type='panel';
    ResultMsgPanel.RowSpan=[row_ind,row_ind];
    ResultMsgPanel.ColSpan=[1,10];
    ResultMsgPanel.ColStretch=[0,0,0,0,0,1,1,1,1,0];
    ResultMsgPanel.LayoutGrid=[1,10];

    ResultMsg.Name=[DAStudio.message('Simulink:tools:MAResult'),':  '];
    ResultMsg.Type='text';
    ResultMsg.Alignment=5;
    ResultMsg.Tag='text_ResultMsg';
    ResultMsg.RowSpan=[1,1];
    ResultMsg.ColSpan=[1,1];
    ResultMsgPanel.Items{1}=ResultMsg;


    ResultIcon.Type='image';
    ResultIcon.RowSpan=[1,1];
    ResultIcon.ColSpan=[2,2];
    ResultIcon.Alignment=5;
    ResultIcon.FilePath=fullfile(matlabroot,this.getDisplayIcon);
    ResultMsgPanel.Items{end+1}=ResultIcon;

    overallstatusString=ModelAdvisor.CheckStatusUtil.getText(this.State);




    ResultStatusString.Name=overallstatusString;
    ResultStatusString.Type='text';
    ResultStatusString.RowSpan=[1,1];
    ResultStatusString.ColSpan=[3,3];
    ResultMsgPanel.Items{end+1}=ResultStatusString;
    AnalyzeItems{end+1}=ResultMsgPanel;


    row_ind=row_ind+1;

    if this.MACIndex==-2
        summary.Text=DAStudio.message('ModelAdvisor:engine:InputParamMismatchInConfigFileDlgMsg',this.MAC);
    else
        summary.Text=DAStudio.message('Simulink:tools:MAMissCorrespondCheck',this.MAC);
    end


    summary.Text=strrep(summary.Text,'<p />','<p>');
    summary.Type='textbrowser';
    summary.Tag='ResultBrowser';
    summary.RowSpan=[row_ind,row_ind];
    summary.ColSpan=[1,10];
    summary.MinimumSize=[1,150];
    AnalyzeItems{end+1}=summary;

    AnalysisGroup.LayoutGrid=[row_ind,10];
    AnalysisGroup.RowStretch=[zeros(1,row_ind-1),1];
    AnalysisGroup.ColStretch=[0,0,0,1,1,1,1,1,1,1];
    AnalysisGroup.Items=AnalyzeItems;

    addonStruct.Items={AnalysisGroup};
    addonStruct.RowStretch=1;

    addonStruct.LayoutGrid=[groupRowIndex,10];
    addonStruct.ColStretch=[0,0,0,0,0,0,0,0,0,0];
    addonStruct.DialogTitle=this.DisplayName;