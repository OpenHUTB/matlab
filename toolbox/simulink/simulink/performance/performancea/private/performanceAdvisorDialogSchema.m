function addonStruct=performanceAdvisorDialogSchema(group)


    masterrow=1;

    struct.Name='tabcontainer';
    struct.Type='tab';
    struct.Tag='tabcontainer_struct';
    struct.LayoutGrid=[3,20];
    struct.RowSpan=[masterrow,masterrow];
    struct.ColSpan=[1,10];


    if~isempty(group.MAObj.CustomObject)&&~isempty(group.MAObj.CustomObject.GUIReportTabName)
        reportTab.Name=group.MAObj.CustomObject.GUIReportTabName;
    end
    reportTab.Tag='tab_reportTab';




    introductionStr1.Name=DAStudio.message('SimulinkPerformanceAdvisor:advisor:Desc');
    introductionStr1.Type='text';
    introductionStr1.Tag='IntroStr1';
    introductionStr1.WordWrap=true;


    introductionStr3.Name=strcat('<b>',DAStudio.message('SimulinkPerformanceAdvisor:advisor:WorkflowLabel'),'<\b>');
    introductionStr3.Type='text';
    introductionStr3.Tag='WorkflowLabel';
    introductionStr3.WordWrap=true;


    introductionStr2.Name=DAStudio.message('SimulinkPerformanceAdvisor:advisor:IntroStr2');
    introductionStr2.Type='text';
    introductionStr2.Tag='IntroStr2';
    introductionStr2.WordWrap=true;


    setupPA.Name=strcat('<strong>',DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActionGroupName'),'<\strong>');
    setupPA.Type='text';
    setupPA.Tag='ActionGroupName';
    setupPA.WordWrap=true;


    compaStr1.Name=DAStudio.message('SimulinkPerformanceAdvisor:advisor:CompStrA');
    compaStr1.Type='text';
    compaStr1.Tag='CompStrA';
    compaStr1.WordWrap=true;


    compaStr2.Name=DAStudio.message('SimulinkPerformanceAdvisor:advisor:CompStrB');
    compaStr2.Type='text';
    compaStr2.Tag='CompStrB';
    compaStr2.WordWrap=true;


    actStr1.Name=DAStudio.message('SimulinkPerformanceAdvisor:advisor:SetupStr1');
    actStr1.Type='text';
    actStr1.Tag='SetupStr1';
    actStr1.WordWrap=true;



    actParam=group.InputParameters{1};
    actMode=loc_createInputParamFromDefinition(group,actParam,1);


    validateString.Name=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ValidationStr1');
    validateString.Type='text';
    validateString.Tag='ValidationStr1';
    validateString.WordWrap=true;


    validateParam=group.InputParameters{2};
    validateItem1=loc_createInputParamFromDefinition(group,validateParam,2);


    validateParam=group.InputParameters{3};
    validateItem2=loc_createInputParamFromDefinition(group,validateParam,3);


    selectChecksStr.Name=DAStudio.message('SimulinkPerformanceAdvisor:advisor:SelectChecksLabel');
    selectChecksStr.Type='text';
    selectChecksStr.Tag='SelectChecksLabel';
    selectChecksStr.WordWrap=true;


    timeOutParam=group.InputParameters{4};
    timeOutedit=loc_createInputParamFromDefinition(group,timeOutParam,4);


    analyzebutton.Enabled=1;
    quickScanbutton.Enabled=1;
    timeOutedit.Enabled=1;


    if isa(group,'ModelAdvisor.Procedure')
        analyzebutton.Name=DAStudio.message('Simulink:tools:MARunToFailure');

        analyzebutton.MatlabMethod='runToFail';
        analyzebutton.MatlabArgs={group};
        menuStruct=modeladvisorprivate('modeladvisorutil2','GetSelectMenuForTaskAdvsiorNode',group);
        analyzebutton.Enabled=strcmp(menuStruct.run2failureEnable,'on');
    else
        analyzebutton.Name=DAStudio.message('Simulink:tools:MARunSelectedChecks');


        analyzebutton.MatlabMethod='runTaskAdvisorWrapper';
        analyzebutton.MatlabArgs={group};
    end


    if group.MAObj.isSleeping
        analyzebutton.Enabled=false;
        quickScanButton.Enabled=false;
        timeOutedit.Enabled=false;
    end


    quickScanbutton.Type='pushbutton';
    quickScanbutton.Tag='QuickScan';
    quickScanbutton.RowSpan=[1,1];
    quickScanbutton.ColSpan=[1,1];
    quickScanbutton.DialogRefresh=true;
    quickScanbutton.MatlabArgs={group};
    quickScanbutton.ArgDataTypes={};
    quickScanbutton.Name=DAStudio.message('SimulinkPerformanceAdvisor:advisor:PAQuickScan');
    quickScanbutton.MatlabMethod='utilPAQuickScan';


    analyzebutton.Type='pushbutton';
    analyzebutton.Tag='RunAdvisor';
    analyzebutton.RowSpan=[1,1];
    analyzebutton.ColSpan=[3,3];
    analyzebutton.DialogRefresh=true;
    analyzebutton.MethodArgs={};
    analyzebutton.ArgDataTypes={};


    timeOutedit.RowSpan=[1,1];
    if(or(strcmp(computer,'MACI64'),strcmp(computer,'GLNXA64')))
        timeOutedit.ColSpan=[5,10];
    else
        timeOutedit.ColSpan=[5,9];
    end
    timeOutedit.DialogRefresh=true;
    timeOutedit.MatlabArgs={group,'%value'};
    timeOutedit.ArgDataTypes={'string'};
    timeOutedit.MatlabMethod='utilUpdateGlobalTimeOutValue';


    if~isempty(group.Description)

        analyzeVgrp.Type='group';
        analyzeVgrp.Name=' ';
        analyzeVgrp.Flat=true;
        analyzeVgrp.ColStretch=ones(20);
        analyzeVgrp.LayoutGrid=[1,20];
        analyzeVgrp.Tag='group_analyzeVgrp';
        analyzeVgrp.Items={quickScanbutton,analyzebutton,timeOutedit};
        analyzeVgrp.ColSpan=[1,20];
    else
        analyzeVgrp.Items={quickScanbutton,analyzebutton,timeOutedit};
        analyzeVgrp.ColSpan=[4,1];
    end



    launchrptcheckbox.Type='checkbox';
    launchrptcheckbox.Name=DAStudio.message('Simulink:tools:MAShowRptAfterRun');
    launchrptcheckbox.Enabled=true;
    launchrptcheckbox.Tag='CheckBox_launchReport';




    launchrptcheckbox.MatlabMethod='handleCheckEvent';
    launchrptcheckbox.MatlabArgs={group,'%tag','%dialog'};
    launchrptcheckbox.Value=group.LaunchReport;
    launchrptcheckbox.DialogRefresh=false;
    launchrptcheckbox.Alignment=0;

    spacer0.Name='     ';
    spacer0.Type='text';
    spacer0.Tag='text_emptymsg';
    spacer0.WordWrap=true;
    spacer0.ColSpan=[1,10];
    spacer0.MaximumSize=[0,5];

    spacer1.Name='     ';
    spacer1.Type='text';
    spacer1.Tag='text_emptymsg';
    spacer1.WordWrap=true;
    spacer1.ColSpan=[1,10];
    spacer1.MaximumSize=[0,5];





    row=1;
    introductionStr1.RowSpan=[row,row];
    row=row+1;
    spacer0.RowSpan=[row,row];
    row=row+1;
    introductionStr3.RowSpan=[row,row];
    row=row+1;
    introductionStr2.RowSpan=[row,row];
    row=row+1;
    spacer1.RowSpan=[row,row];
    row=row+1;
    setupPA.RowSpan=[row,row];
    row=row+1;
    compaStr1.RowSpan=[row,row];
    row=row+1;
    compaStr2.RowSpan=[row,row];
    row=row+1;
    actStr1.RowSpan=[row,row];
    row=row+1;
    actMode.RowSpan=[row,row];
    row=row+1;
    validateString.RowSpan=[row,row];
    row=row+1;
    validateItem1.RowSpan=[row,row];
    row=row+1;
    validateItem2.RowSpan=[row,row];
    row=row+1;
    selectChecksStr.RowSpan=[row,row];
    row=row+1;
    analyzeVgrp.RowSpan=[row,row];

    if(strcmp(computer,'MACI64'))
        launchrptcheckbox.RowSpan=[row,row];
    else
        launchrptcheckbox.RowSpan=[row,row+2];
    end


    introductionStr1.ColSpan=[1,19];
    introductionStr3.ColSpan=[2,19];
    introductionStr2.ColSpan=[2,16];
    setupPA.ColSpan=[2,19];
    compaStr1.ColSpan=[2,19];
    compaStr2.ColSpan=[2,19];
    actStr1.ColSpan=[2,19];
    actMode.ColSpan=[3,8];
    validateString.ColSpan=[2,19];
    validateItem1.ColSpan=[3,8];
    validateItem2.ColSpan=[3,8];
    selectChecksStr.ColSpan=[2,19];

    launchrptcheckbox.ColSpan=[13,19];



    usingPAGroup.Type='group';
    usingPAGroup.Name=DAStudio.message('SimulinkPerformanceAdvisor:advisor:RunGroupName');
    usingPAGroup.Tag='Introduction';
    usingPAGroup.Flat=false;
    usingPAGroup.RowSpan=[1,1];
    usingPAGroup.ColSpan=[1,20];
    usingPAGroup.ColStretch=zeros(20);
    usingPAGroup.LayoutGrid=[row,200];
    usingPAGroupItems={introductionStr1,spacer0};
    usingPAGroupItems=[usingPAGroupItems,{introductionStr3,introductionStr2,spacer1,setupPA,compaStr1,compaStr2,actStr1,actMode,validateString,validateItem1,validateItem2,selectChecksStr,analyzeVgrp,launchrptcheckbox}];
    usingPAGroup.Items=usingPAGroupItems;
    reportTab.Items={usingPAGroup};




    grouprow=2;
    row=1;

    counterStructure=modeladvisorprivate('modeladvisorutil2','getNodeSummaryInfo',group);
    rptmsg.Name=[DAStudio.message('Simulink:tools:MAReport'),': '];
    rptmsg.Type='text';
    rptmsg.Tag='text_rptmsg';
    rptmsg.WordWrap=true;
    rptmsg.RowSpan=[row,row];
    rptmsg.ColSpan=[1,1];

    [rptPath,rptName,rptExt]=fileparts(modeladvisorprivate('modeladvisorutil2','GetReportNameForTaskNode',...
    group,group.MAObj.AtticData.WorkDir));
    rtpFileName=[rptPath,filesep,rptName,rptExt;];

    group.MAobj.UserData.Results.logLocation=rtpFileName;
    group.MAobj.UserData.Results.model=group.MAobj.ModelName;
    rptLink.Name=['...\',rptName,rptExt];
    rptLink.ToolTip=group.MAobj.UserData.Results.logLocation;
    rptLink.Type='hyperlink';
    rptLink.Tag='hyperlink_rptLink';



    rptLink.MatlabMethod='viewReport';
    rptLink.MatlabArgs={group,''};


    rptLink.RowSpan=[row,row];
    rptLink.ColSpan=[2,3];

    exportbutton.Enabled=1;
    exportbutton.Name=DAStudio.message('Simulink:tools:MASaveReport');
    exportbutton.Type='pushbutton';
    exportbutton.Tag='exportReport';
    exportbutton.RowSpan=[1,1];
    exportbutton.ColSpan=[4,5];
    exportbutton.Alignment=5;
    exportbutton.DialogRefresh=true;



    exportbutton.MatlabMethod='exportReport';
    exportbutton.MatlabArgs={group};
    exportbutton.Tag='exportReport';


    row=row+1;
    rptDateTitle.Name=[DAStudio.message('Simulink:tools:MADateTime'),': '];
    rptDateTitle.Type='text';
    rptDateTitle.Tag='text_rptDateTitle';
    rptDateTitle.WordWrap=true;
    rptDateTitle.RowSpan=[row,row];
    rptDateTitle.ColSpan=[1,1];

    if counterStructure.generateTime~=0
        rptDateMsg.Name=datestr(counterStructure.generateTime);
    else
        rptDateMsg.Name=DAStudio.message('Simulink:tools:MANotApplicable');
    end
    rptDateMsg.Type='text';
    rptDateMsg.Tag='text_rptDateMsg';
    rptDateMsg.WordWrap=true;
    rptDateMsg.RowSpan=[row,row];
    rptDateMsg.ColSpan=[2,10];

    row=row+1;
    summarymsg.Name=[DAStudio.message('Simulink:tools:MASummary'),': '];
    summarymsg.Type='text';
    summarymsg.Tag='text_summarymsg';
    summarymsg.WordWrap=true;
    summarymsg.RowSpan=[row,row];
    summarymsg.ColSpan=[1,1];

    passedIcon.Type='image';
    passedIcon.Tag='image_passedIcon';
    passedIcon.RowSpan=[row,row];
    passedIcon.ColSpan=[2,2];
    imagepath=fileparts(fullfile(matlabroot,group.getDisplayIcon));
    passedIcon.FilePath=fullfile(imagepath,'task_passed.png');
    passedCounter.Name=num2str(counterStructure.passCt);
    passedCounter.Name=[DAStudio.message('Simulink:tools:MAPass'),': ',passedCounter.Name];
    passedCounter.Type='text';
    passedCounter.Tag='text_passedCounter';
    passedCounter.WordWrap=true;
    passedCounter.RowSpan=[row,row];
    passedCounter.ColSpan=[3,3];

    failedIcon.Type='image';
    failedIcon.Tag='image_failedIcon';
    failedIcon.RowSpan=[row,row];
    failedIcon.ColSpan=[4,4];
    failedIcon.FilePath=fullfile(imagepath,'task_failed.png');
    failedCounter.Name=num2str(counterStructure.failCt);
    failedCounter.Name=[DAStudio.message('Simulink:tools:MAFail'),': ',failedCounter.Name];
    failedCounter.Type='text';
    failedCounter.Tag='text_failedCounter';
    failedCounter.WordWrap=true;
    failedCounter.RowSpan=[row,row];
    failedCounter.ColSpan=[5,5];

    warnIcon.Type='image';
    warnIcon.Tag='image_warnIcon';
    warnIcon.RowSpan=[row,row];
    warnIcon.ColSpan=[6,6];
    warnIcon.FilePath=fullfile(imagepath,'task_warning.png');
    warnCounter.Name=num2str(counterStructure.warnCt);
    warnCounter.Name=[DAStudio.message('Simulink:tools:MAWarning'),': ',warnCounter.Name];
    warnCounter.Type='text';
    warnCounter.Tag='text_warnCounter';
    warnCounter.WordWrap=true;
    warnCounter.RowSpan=[row,row];
    warnCounter.ColSpan=[7,7];

    nrunIcon.Type='image';
    nrunIcon.Tag='image_nrunIcon';
    nrunIcon.RowSpan=[row,row];
    nrunIcon.ColSpan=[8,8];
    nrunIcon.FilePath=fullfile(imagepath,'icon_task.png');
    nrunCounter.Name=num2str(counterStructure.nrunCt);
    nrunCounter.Name=[DAStudio.message('Simulink:tools:MANotRunMsg'),': ',nrunCounter.Name];
    nrunCounter.Type='text';
    nrunCounter.Tag='text_nrunCounter';
    nrunCounter.WordWrap=true;
    nrunCounter.RowSpan=[row,row];
    nrunCounter.ColSpan=[9,9];


    CurrentReportGroup.Type='group';
    CurrentReportGroup.Name=DAStudio.message('Simulink:tools:MAReport');
    CurrentReportGroup.RowSpan=[grouprow,grouprow];
    CurrentReportGroup.ColSpan=[1,20];
    CurrentReportGroup.ColStretch=zeros(1,10);
    CurrentReportGroup.LayoutGrid=[3,10];
    CurrentReportGroup.Items={rptmsg,rptLink,exportbutton,rptDateTitle,rptDateMsg,summarymsg,passedIcon,passedCounter,failedIcon,failedCounter,warnIcon,warnCounter,nrunIcon,nrunCounter};
    reportTab.Items{end+1}=CurrentReportGroup;



    grouprow=grouprow+1;
    LegendGroup.Type='group';
    LegendGroup.Name=DAStudio.message('Simulink:tools:MALegend');
    LegendGroup.RowSpan=[grouprow,grouprow];
    LegendGroup.ColSpan=[1,20];
    if~group.MAObj.IsLibrary||modeladvisorprivate('modeladvisorutil2','FeatureControl','ForceRunOnLibrary')
        CompileCheck.Name=[' ',DAStudio.message('Simulink:tools:PrefixForCompileCheck'),' ',DAStudio.message('Simulink:tools:MARequiresCompileShort')];
    else
        CompileCheck.Name=[' ',DAStudio.message('ModelAdvisor:engine:PrefixForNSupportLibCheck'),' ',DAStudio.message('ModelAdvisor:engine:CheckNotSupportLibrary')];
    end
    CompileCheck.Type='text';
    CompileCheck.Tag='text_CompileCheck';
    CompileCheck.WordWrap=true;
    CompileCheck.RowSpan=[1,1];
    CompileCheck.ColSpan=[1,1];
    LegendGroup.Items{1}=CompileCheck;
    LegendGroup.LayoutGrid=[1,2];
    reportTab.Items{end+1}=LegendGroup;



    grouprow=grouprow+1;
    emptymsg.Name='     ';
    emptymsg.Type='text';
    emptymsg.Tag='text_emptymsg';
    emptymsg.WordWrap=true;
    emptymsg.RowSpan=[grouprow,grouprow];
    emptymsg.ColSpan=[1,10];
    reportTab.Items{end+1}=emptymsg;

    reportTab.LayoutGrid=[1,20];
    reportTab.RowStretch=[0,0,0,1];

    struct.Tabs={reportTab};

    addonStruct.Items={struct};
    addonStruct.LayoutGrid=[1,10];
    addonStruct.RowStretch=1;
    addonStruct.ColStretch=[0,0,0,0,0,0,0,0,0,0];

end

function curParamItem=loc_createInputParamFromDefinition(this,curParam,i)

    curParamItem=[];
    curParamItem.RowSpan=curParam.RowSpan;
    curParamItem.ColSpan=curParam.ColSpan;
    curParamItem.Name=curParam.Name;
    switch(curParam.Type)
    case 'Bool'
        curParamItem.Type='checkbox';
    case 'String'
        curParamItem.Type='edit';
    case 'Enum'
        curParamItem.Type='combobox';
        curParamItem.Entries=curParam.Entries;
    case 'ComboBox'
        curParamItem.Type='combobox';
        curParamItem.Entries=curParam.Entries;
        curParamItem.Editable=true;
    case 'PushButton'
        curParamItem.Name=curParam.Name;
        curParamItem.Type='pushbutton';
    case 'Table'
        curParamItem.Type='table';
        curParamItem.Editable=true;
        curParamItem.Data=curParam.TableSetting.Data;
        curParamItem.Size=curParam.TableSetting.Size;
        curParamItem.ColHeader=curParam.TableSetting.ColHeader;
        curParamItem.ColumnCharacterWidth=curParam.TableSetting.ColumnCharacterWidth;
        curParamItem.ColumnHeaderHeight=curParam.TableSetting.ColumnHeaderHeight;
        curParamItem.HeaderVisibility=curParam.TableSetting.HeaderVisibility;
        curParamItem.ReadOnlyColumns=curParam.TableSetting.ReadOnlyColumns;
        curParamItem.ValueChangedCallback=curParam.TableSetting.ValueChangedCallback;
        curParamItem.MinimumSize=curParam.TableSetting.MinimumSize;
    otherwise
        DAStudio.error('Simulink:tools:MAUnsupportedInputParamType');
    end
    curParamItem.Enabled=curParam.Enable;
    curParamItem.Tag=['InputParameters_',num2str(i)];



    curParamItem.MatlabMethod='handleCheckEvent';
    curParamItem.MatlabArgs={this,'%tag','%dialog'};

    curParamItem.Value=curParam.Value;

    curParamItem.ToolTip=curParam.Description;
end



