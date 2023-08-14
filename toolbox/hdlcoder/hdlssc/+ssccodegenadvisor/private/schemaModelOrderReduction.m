function[addon]=schemaModelOrderReduction(task)












    modelAdvisorObj=task.MAObj;
    sscCodeGenWorkflowObjCheck=modelAdvisorObj.getCheckObj('com.mathworks.hdlssc.ssccodegenadvisor.workflowObjectCheck');
    sscCodeGenWorkflowObj=sscCodeGenWorkflowObjCheck.ResultData;


    switchList=sscCodeGenWorkflowObj.listOfSwitches;
    dlgInfo=getModelOrderReductionDialog(modelAdvisorObj);


    addon.Items{1}=dlgInfo.Items{1};
    addon.Items{1}.Enabled=true;


    appID=modelAdvisorObj.ApplicationID;

    addon.DialogTitle=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_checks:modelOrderReductionCheckLinearization');
    addon.DialogTag=['com.mathworks.hdlssc.ssccodegenadvisor.modelOrderReduction',...
    appID];
    hmdlAdvCheck=task.Check;



    checkAllBtn.Name='Check All';
    checkAllBtn.Tag='ModelOrderReductionCheckAll';
    checkAllBtn.Type='pushbutton';
    checkAllBtn.RowSpan=[2,2];
    checkAllBtn.ColSpan=[4,4];
    checkAllBtn.Alignment=4;
    checkAllBtn.DialogRefresh=true;
    checkAllBtn.Source=task;
    checkAllBtn.MatlabMethod='ssccodegenadvisor.modelOrderReductionCheckAll';
    checkAllBtn.MatlabArgs={modelAdvisorObj,true};


    uncheckAllBtn.Name='Uncheck All';
    uncheckAllBtn.Tag='ModelOrderReductionUncheckAll';
    uncheckAllBtn.Type='pushbutton';
    uncheckAllBtn.RowSpan=[2,2];
    uncheckAllBtn.ColSpan=[5,5];
    uncheckAllBtn.Alignment=2;
    uncheckAllBtn.DialogRefresh=true;
    uncheckAllBtn.MatlabMethod='ssccodegenadvisor.modelOrderReductionCheckAll';
    uncheckAllBtn.MatlabArgs={modelAdvisorObj,false};



    numrows=size(switchList,1);
    tabledata=cell(numrows,4);


    tableOfSwitches.Name='Switched Linear Elements eligible for linearization';
    tableOfSwitches.Tag='SwitchLinearTable';
    tableOfSwitches.Type='table';
    tableOfSwitches.RowSpan=[2,2];
    tableOfSwitches.ColSpan=[1,10];
    tableOfSwitches.MinimumSize=[1000,300];
    tableOfSwitches.Alignment=0;
    tableOfSwitches.HeaderVisibility=[0,1];
    tableOfSwitches.DialogRefresh=true;
    tableOfSwitches.Editable=1;
    tableOfSwitches.RowCharacterHeight=repmat(2,[1,numrows]);
    tableOfSwitches.Size=[numrows,4];
    tableOfSwitches.ColumnStretchable=[1,1,1,1];
    tableOfSwitches.ColHeader={'Block Name','Block Type','Linearize','Rs'};
    tableOfSwitches.ItemClickedCallback=@utilLinkToBlock;
    tableOfSwitches.ValueChangedCallback=@utilTableOfSwitchesValueChange;
    rowNum=1;
    for i=1:size(switchList,1)
        rowData=makeRowData(switchList(i),rowNum);
        tabledata(i,:)=rowData;
    end
    tableOfSwitches.Data=tabledata;

    sscCodeGenWorkflowObjCheck.InputParameters{2}=tableOfSwitches;






    if isempty(sscCodeGenWorkflowObj.listOfSwitches)||any([sscCodeGenWorkflowObj.listOfSwitches.Approx])
        runBtnName=DAStudio.message('Simulink:tools:MARunThisTask');
    else
        runBtnName='Skip This Task';
    end
    runBtn.Name=runBtnName;
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

    ResultMsg.Name=[DAStudio.message('Simulink:tools:MAResult'),':'];
    ResultMsg.Type='text';
    ResultMsg.Tag='text_ResultMsg';
    ResultMsg.RowSpan=[5,5];
    ResultMsg.ColSpan=[1,1];

    ResultIcon.Type='image';
    ResultIcon.RowSpan=[5,5];
    ResultIcon.ColSpan=[2,2];
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



    if(task.State==ModelAdvisor.CheckStatus.NotRun)
        if task.Selected
            if isa(task.getParent,'ModelAdvisor.Procedure')
                summary.Text=DAStudio.message('Simulink:tools:MAPressRunThisTask');
            else
                summary.Text=DAStudio.message('Simulink:tools:MAPressRunThisCheck');
            end
        else
            if isa(task.getParent,'ModelAdvisor.Procedure')
                summary.Text=DAStudio.message('Simulink:tools:MASelectThenPressRunThisTask');
            else
                summary.Text=DAStudio.message('Simulink:tools:MASelectThenPressRunThisCheck');
            end
        end
        if task.MAObj.IsLibrary&&~hmdlAdvCheck.SupportLibrary&&~modeladvisorprivate('modeladvisorutil2','FeatureControl','ForceRunOnLibrary')
            summary.Text=DAStudio.message('ModelAdvisor:engine:CheckNotSupportLibrary');
        end
    else

        JSfunction=['<script type="text/javascript"> <!--',...
        modeladvisorprivate('modeladvisorutil2','generate_collapsible_JS',task.MAObj),...
        '--></script>'];

        CSS=ModelAdvisor.Element('style',...
        'type','text/css');
        CSS.setContent(modeladvisorprivate('modeladvisorutil2','CSSFormatting'));

        summary.Text=[CSS.emitHTML,JSfunction,hmdlAdvCheck.ResultInHTML];
    end

    summary.Text=regexprep(summary.Text,['<!-- inputparam_section_start -->','.*','<!-- inputparam_section_finish -->'],'');


    summary.Text=strrep(summary.Text,'<p />','<p>');
    mp=ModelAdvisor.Preferences;
    if mp.UseWebkit
        summary.Type='webbrowser';
        summary.HTML=summary.Text;
    else
        summary.Type='textbrowser';
    end
    summary.Tag='ResultBrowser';
    summary.RowSpan=[6,6];
    summary.ColSpan=[1,10];
    summary.MinimumSize=[1,150];
    addon.Items{end+1}=dlgInfo.Items{2};
    addon.Items{end+1}=tableOfSwitches;
    addon.Items{end+1}=checkAllBtn;
    addon.Items{end+1}=uncheckAllBtn;

    addon.Items{end+1}=runBtn;
    addon.Items{end+1}=ResultMsg;
    addon.Items{end+1}=ResultIcon;
    addon.Items{end+1}=ResultStatusString;
    addon.Items{end+1}=summary;



    addon.LayoutGrid=[6,5];
    addon.ColStretch=[0,0,1,1,1];
end


function rowData=makeRowData(switchVals,rowNum)
    switchName=switchVals.Name;
    switchType=switchVals.Type;
    approx=switchVals.Approx;
    Rs=switchVals.Rs;

    rowData=cell(1,4);

    linkWidget.Type='hyperlink';
    linkWidget.Name=get_param(switchName,'Name');
    rowData{1}=linkWidget;

    textWidget.Type='text';
    textWidget.Name=switchType;
    rowData{2}=textWidget;

    checkbox.Type='checkbox';
    checkbox.Alignment=6;
    checkbox.Tag=strcat('linCheckBox',num2str(rowNum));
    checkbox.Value=approx;
    checkbox.DialogRefresh=true;
    rowData{3}=checkbox;

    rowData{4}=Rs;
end

function url=getBlockHyperlink(blockName)%#ok<DEFNU>
    url=strcat('matlab:Simulink.internal.highlightResourceOwnerBlock(''',blockName,''')');

end



