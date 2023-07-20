
function addonStruct=createCustomRoot(this)
    addonStruct.Items={};

    row=1;

    row=row+1;
    GeneralDescription.Text=this.StartMessage;
    GeneralDescription.Type='textbrowser';
    GeneralDescription.Tag='textbrowser_GeneralDescription';
    GeneralDescription.RowSpan=[row,row];
    GeneralDescription.ColSpan=[1,10];

    addonStruct.Items{end+1}=GeneralDescription;


    row=row+1;
    LegendGroup.Type='group';
    LegendGroup.Name=DAStudio.message('Simulink:tools:MALegend');
    LegendGroup.RowSpan=[row,row];
    LegendGroup.ColSpan=[1,10];
    curRow=1;

    curRow=curRow+1;
    SelectedCheck.Name=DAStudio.message('Simulink:tools:MANotRunMsg');
    SelectedCheck.Type='text';
    SelectedCheck.Tag='text_SelectedCheck';
    SelectedCheck.WordWrap=true;
    SelectedCheck.RowSpan=[curRow,curRow];
    SelectedCheck.ColSpan=[2,2];
    LegendGroup.Items={SelectedCheck};
    selectedIcon.Type='image';
    selectedIcon.Tag='image_selectedIcon';
    selectedIcon.RowSpan=[curRow,curRow];
    selectedIcon.ColSpan=[1,1];
    imagepath=fullfile(matlabroot,'toolbox/simulink/simulink/modeladvisor/private/');
    selectedIcon.FilePath=fullfile(imagepath,'icon_task.png');
    LegendGroup.Items{end+1}=selectedIcon;

    curRow=curRow+1;
    PassedCheck.Name=DAStudio.message('Simulink:tools:MAPassedMsg');
    PassedCheck.Type='text';
    PassedCheck.Tag='text_PassedCheck';
    PassedCheck.WordWrap=true;
    PassedCheck.RowSpan=[curRow,curRow];
    PassedCheck.ColSpan=[2,2];
    LegendGroup.Items{end+1}=PassedCheck;
    passedIcon.Type='image';
    passedIcon.Tag='image_passedIcon';
    passedIcon.RowSpan=[curRow,curRow];
    passedIcon.ColSpan=[1,1];
    passedIcon.FilePath=fullfile(imagepath,'task_passed.png');
    LegendGroup.Items{end+1}=passedIcon;

    curRow=curRow+1;
    FailedCheck.Name=DAStudio.message('Simulink:tools:MAFailedMsg');
    FailedCheck.Type='text';
    FailedCheck.Tag='text_FailedCheck';
    FailedCheck.WordWrap=true;
    FailedCheck.RowSpan=[curRow,curRow];
    FailedCheck.ColSpan=[2,2];
    LegendGroup.Items{end+1}=FailedCheck;
    failedIcon.Type='image';
    failedIcon.Tag='image_failedIcon';
    failedIcon.RowSpan=[curRow,curRow];
    failedIcon.ColSpan=[1,1];
    failedIcon.FilePath=fullfile(imagepath,'task_failed.png');
    LegendGroup.Items{end+1}=failedIcon;

    curRow=curRow+1;
    WarnCheck.Name=DAStudio.message('Simulink:tools:MAWarning');
    WarnCheck.Type='text';
    WarnCheck.Tag='text_WarnCheck';
    WarnCheck.WordWrap=true;
    WarnCheck.RowSpan=[curRow,curRow];
    WarnCheck.ColSpan=[2,2];
    LegendGroup.Items{end+1}=WarnCheck;
    WarnIcon.Type='image';
    WarnIcon.Tag='image_WarnIcon';
    WarnIcon.RowSpan=[curRow,curRow];
    WarnIcon.ColSpan=[1,1];
    WarnIcon.FilePath=fullfile(imagepath,'task_warning.png');
    LegendGroup.Items{end+1}=WarnIcon;

    curRow=curRow+1;
    Groupmsg.Name=DAStudio.message('Simulink:tools:MAGroupLegendNote');
    Groupmsg.Type='text';
    Groupmsg.Tag='text_Groupmsg';
    Groupmsg.WordWrap=true;
    Groupmsg.RowSpan=[curRow,curRow];
    Groupmsg.ColSpan=[2,2];
    LegendGroup.Items{end+1}=Groupmsg;
    GroupIcon.Type='image';
    GroupIcon.Tag='image_GroupIcon';
    GroupIcon.RowSpan=[curRow,curRow];
    GroupIcon.ColSpan=[1,1];
    GroupIcon.FilePath=fullfile(imagepath,'icon_folder.png');
    LegendGroup.Items{end+1}=GroupIcon;

    curRow=curRow+1;
    Proceduremsg.Name=DAStudio.message('Simulink:tools:MAProcedureLegendNote');
    Proceduremsg.Type='text';
    Proceduremsg.Tag='text_Proceduremsg';
    Proceduremsg.WordWrap=true;
    Proceduremsg.RowSpan=[curRow,curRow];
    Proceduremsg.ColSpan=[2,2];
    LegendGroup.Items{end+1}=Proceduremsg;
    ProcedureIcon.Type='image';
    ProcedureIcon.Tag='image_ProcedureIcon';
    ProcedureIcon.RowSpan=[curRow,curRow];
    ProcedureIcon.ColSpan=[1,1];
    ProcedureIcon.FilePath=fullfile(imagepath,'icon_procedure.png');
    LegendGroup.Items{end+1}=ProcedureIcon;

    curRow=curRow+1;
    CompileCheck.Name=DAStudio.message('Simulink:tools:MARequiresCompileShort');
    CompileCheck.Type='text';
    CompileCheck.Tag='text_CompileCheck';
    CompileCheck.WordWrap=true;
    CompileCheck.RowSpan=[curRow,curRow];
    CompileCheck.ColSpan=[2,2];
    LegendGroup.Items{end+1}=CompileCheck;
    CompileFlag.Name=[' ',DAStudio.message('Simulink:tools:PrefixForCompileCheck'),' '];
    CompileFlag.Bold=1;
    CompileFlag.Type='text';
    CompileFlag.WordWrap=true;
    CompileFlag.RowSpan=[curRow,curRow];
    CompileFlag.ColSpan=[1,1];
    LegendGroup.Items{end+1}=CompileFlag;

    curRow=curRow+1;
    R2FInProgree.Name=DAStudio.message('Simulink:tools:MAInProgress',['"',DAStudio.message('Simulink:tools:MARunToFailure'),'"']);
    R2FInProgree.Type='text';
    R2FInProgree.Tag='text_R2FInProgree';
    R2FInProgree.WordWrap=true;
    R2FInProgree.RowSpan=[curRow,curRow];
    R2FInProgree.ColSpan=[2,2];
    LegendGroup.Items{end+1}=R2FInProgree;
    R2FInProgreeFlag.Name='->>>';
    R2FInProgreeFlag.Bold=1;
    R2FInProgreeFlag.Type='text';
    R2FInProgreeFlag.WordWrap=false;
    R2FInProgreeFlag.RowSpan=[curRow,curRow];
    R2FInProgreeFlag.ColSpan=[1,1];
    LegendGroup.Items{end+1}=R2FInProgreeFlag;
    LegendGroup.LayoutGrid=[curRow,2];
    addonStruct.Items{end+1}=LegendGroup;


    row=row+1;
    CurrentReportGroup.Type='group';
    CurrentReportGroup.Name=DAStudio.message('Simulink:tools:MAReport');
    CurrentReportGroup.RowSpan=[row,row];
    CurrentReportGroup.ColSpan=[1,10];
    CurrentReportGroup.ColStretch=zeros(1,10);


    counterStructure=modeladvisorprivate('modeladvisorutil2','getNodeSummaryInfo',this);

    grouprow=0;

    grouprow=grouprow+1;
    rptmsg.Name=[DAStudio.message('Simulink:tools:MAReport'),': '];
    rptmsg.Type='text';
    rptmsg.Tag='text_rptmsg';
    rptmsg.WordWrap=true;
    rptmsg.RowSpan=[grouprow,grouprow];
    rptmsg.ColSpan=[1,1];

    [rptPath,rptName,rptExt]=fileparts(modeladvisorprivate('modeladvisorutil2','GetReportNameForTaskNode',...
    this,this.MAObj.AtticData.WorkDir));
    rptLink.Name=['...\',rptName,rptExt];
    rptLink.ToolTip=[rptPath,filesep,rptName,rptExt];
    rptLink.Type='hyperlink';
    rptLink.Tag='hyperlink_rptLink';



    rptLink.MatlabMethod='viewReport';
    rptLink.MatlabArgs={this,''};


    rptLink.RowSpan=[grouprow,grouprow];
    rptLink.ColSpan=[2,3];

    grouprow=grouprow+1;
    rptDateTitle.Name=[DAStudio.message('Simulink:tools:MADateTime'),': '];
    rptDateTitle.Type='text';
    rptDateTitle.Tag='text_rptDateTitle';
    rptDateTitle.WordWrap=true;
    rptDateTitle.RowSpan=[grouprow,grouprow];
    rptDateTitle.ColSpan=[1,1];

    if counterStructure.generateTime~=0
        rptDateMsg.Name=datestr(counterStructure.generateTime);
    else
        rptDateMsg.Name=DAStudio.message('Simulink:tools:MANotApplicable');
    end
    rptDateMsg.Type='text';
    rptDateMsg.Tag='text_rptDateMsg';
    rptDateMsg.WordWrap=true;
    rptDateMsg.RowSpan=[grouprow,grouprow];
    rptDateMsg.ColSpan=[2,10];

    grouprow=grouprow+1;
    summarymsg.Name=[DAStudio.message('Simulink:tools:MASummary'),': '];
    summarymsg.Type='text';
    summarymsg.Tag='text_summarymsg';
    summarymsg.WordWrap=true;
    summarymsg.RowSpan=[grouprow,grouprow];
    summarymsg.ColSpan=[1,1];

    passedIcon.Type='image';
    passedIcon.Tag='image_passedIcon';
    passedIcon.RowSpan=[grouprow,grouprow];
    passedIcon.ColSpan=[2,2];
    imagepath=fileparts(fullfile(matlabroot,this.getDisplayIcon));
    passedIcon.FilePath=fullfile(imagepath,'task_passed.png');
    passedCounter.Name=num2str(counterStructure.passCt);
    passedCounter.Name=[DAStudio.message('Simulink:tools:MAPass'),': ',passedCounter.Name];
    passedCounter.Type='text';
    passedCounter.Tag='text_passedCounter';
    passedCounter.WordWrap=true;
    passedCounter.RowSpan=[grouprow,grouprow];
    passedCounter.ColSpan=[3,3];

    failedIcon.Type='image';
    failedIcon.Tag='image_failedIcon';
    failedIcon.RowSpan=[grouprow,grouprow];
    failedIcon.ColSpan=[4,4];
    failedIcon.FilePath=fullfile(imagepath,'task_failed.png');
    failedCounter.Name=num2str(counterStructure.failCt);
    failedCounter.Name=[DAStudio.message('Simulink:tools:MAFail'),': ',failedCounter.Name];
    failedCounter.Type='text';
    failedCounter.Tag='text_failedCounter';
    failedCounter.WordWrap=true;
    failedCounter.RowSpan=[grouprow,grouprow];
    failedCounter.ColSpan=[5,5];

    warnIcon.Type='image';
    warnIcon.Tag='image_warnIcon';
    warnIcon.RowSpan=[grouprow,grouprow];
    warnIcon.ColSpan=[6,6];
    warnIcon.FilePath=fullfile(imagepath,'task_warning.png');
    warnCounter.Name=num2str(counterStructure.warnCt);
    warnCounter.Name=[DAStudio.message('Simulink:tools:MAWarning'),': ',warnCounter.Name];
    warnCounter.Type='text';
    warnCounter.Tag='text_warnCounter';
    warnCounter.WordWrap=true;
    warnCounter.RowSpan=[grouprow,grouprow];
    warnCounter.ColSpan=[7,7];

    nrunIcon.Type='image';
    nrunIcon.Tag='image_nrunIcon';
    nrunIcon.RowSpan=[grouprow,grouprow];
    nrunIcon.ColSpan=[8,8];
    nrunIcon.FilePath=fullfile(imagepath,'icon_task.png');
    nrunCounter.Name=num2str(counterStructure.nrunCt);
    nrunCounter.Name=[DAStudio.message('Simulink:tools:MANotRunMsg'),': ',nrunCounter.Name];
    nrunCounter.Type='text';
    nrunCounter.Tag='text_nrunCounter';
    nrunCounter.WordWrap=true;
    nrunCounter.RowSpan=[grouprow,grouprow];
    nrunCounter.ColSpan=[9,9];

    CurrentReportGroup.LayoutGrid=[grouprow,10];
    CurrentReportGroup.Items={rptmsg,rptLink,rptDateTitle,rptDateMsg,summarymsg,passedIcon,passedCounter,failedIcon,failedCounter,warnIcon,warnCounter,nrunIcon,nrunCounter};
    addonStruct.Items{end+1}=CurrentReportGroup;

    addonStruct.LayoutGrid=[row,10];
    addonStruct.RowStretch=[zeros(1,row-2),0,0];
    addonStruct.ColStretch=[0,0,0,0,0,0,0,0,0,0];