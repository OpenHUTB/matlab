function dlgstruct=getDialogSchema(this,~)





    imagepath=fullfile('toolbox','simulink','simulink','modeladvisor','resources');
    dlgstruct.DisplayIcon=fullfile(imagepath,'ma.png');
    configFileStr=this.getConfigFile();
    if~isempty(configFileStr)
        configFileStr=[' - ',configFileStr];
    end
    dlgstruct.DialogTitle=[DAStudio.message('ModelAdvisor:engine:MADashboardTitle'),' ',this.mdl,configFileStr];
    dlgstruct.DialogTag=ModelAdvisorLite.GUIModelAdvisorLite.getDialogTag(this.mdl);
    dlgstruct.LayoutGrid=[3,13];
    dlgstruct.RowStretch=[0,0,1];
    dlgstruct.ColStretch=[0,0,0,0,0,0,0,0,0,0,0,0,0];
    dlgstruct.StandaloneButtonSet={''};
    dlgstruct.IsScrollable=false;

    position=this.getPosition;
    dlgstruct.Geometry=[position(1)+8,position(2)+30,285,30];
    dlgstruct.MinimalApply=true;


    ResultGroup.Type='group';
    ResultGroup.Flat=false;
    ResultGroup.LayoutGrid=[1,8];
    ResultGroup.RowSpan=[1,1];
    ResultGroup.ColSpan=[6,14];
    ResultGroup.RowStretch=0;
    ResultGroup.ColStretch=[0,0,0,0,0,0,0,0];
    if this.IsRunning
        ResultGroup.Enabled=false;
    else
        ResultGroup.Enabled=true;
    end


    passedIcon.Type='image';
    passedIcon.Tag='image_passedIcon';
    passedIcon.RowSpan=[1,1];
    passedIcon.ColSpan=[1,1];
    imagepath=fullfile(matlabroot,'toolbox','simulink','simulink','modeladvisor','private');
    passedIcon.FilePath=fullfile(imagepath,'task_passed.png');


    passedCounter.Name=num2str(this.NumPass);

    if this.IsResultAvailable
        passedCounter.Type='hyperlink';
        passedCounter.ObjectMethod='showReport';
        passedCounter.MethodArgs={'showPassedChecks'};
        passedCounter.ArgDataTypes={'string'};
        passedCounter.ToolTip=DAStudio.message('ModelAdvisor:engine:MADashboardShowReport');
    else
        passedCounter.Type='text';
        passedCounter.WordWrap=true;
    end
    passedCounter.Tag='text_passedCounter';
    passedCounter.RowSpan=[1,1];
    passedCounter.ColSpan=[2,2];


    failedIcon.Type='image';
    failedIcon.Tag='image_failedIcon';
    failedIcon.RowSpan=[1,1];
    failedIcon.ColSpan=[3,3];
    imagepath=fullfile(matlabroot,'toolbox','simulink','simulink','modeladvisor','private');
    failedIcon.FilePath=fullfile(imagepath,'task_failed.png');


    failedCounter.Name=num2str(this.NumFail);
    if this.IsResultAvailable
        failedCounter.Type='hyperlink';
        failedCounter.ObjectMethod='showReport';
        failedCounter.MethodArgs={'showFailedChecks'};
        failedCounter.ArgDataTypes={'string'};
        failedCounter.ToolTip=DAStudio.message('ModelAdvisor:engine:MADashboardShowReport');
    else
        failedCounter.Type='text';
        failedCounter.WordWrap=true;
    end
    failedCounter.Tag='text_failedCounter';
    failedCounter.RowSpan=[1,1];
    failedCounter.ColSpan=[4,4];


    warnIcon.Type='image';
    warnIcon.Tag='image_warnIcon';
    warnIcon.RowSpan=[1,1];
    warnIcon.ColSpan=[5,5];
    imagepath=fullfile(matlabroot,'toolbox','simulink','simulink','modeladvisor','private');
    warnIcon.FilePath=fullfile(imagepath,'task_warning.png');


    warnCounter.Name=num2str(this.NumWarn);
    if this.IsResultAvailable
        warnCounter.Type='hyperlink';
        warnCounter.ObjectMethod='showReport';
        warnCounter.MethodArgs={'showWarningChecks'};
        warnCounter.ArgDataTypes={'string'};
        warnCounter.ToolTip=DAStudio.message('ModelAdvisor:engine:MADashboardShowReport');
    else
        warnCounter.Type='text';
        warnCounter.WordWrap=true;
    end
    warnCounter.Tag='text_warnCounter';
    warnCounter.RowSpan=[1,1];
    warnCounter.ColSpan=[6,6];


    notRunIcon.Type='image';
    notRunIcon.Tag='image_notRunIcon';
    notRunIcon.RowSpan=[1,1];
    notRunIcon.ColSpan=[7,7];
    imagepath=fullfile(matlabroot,'toolbox','simulink','simulink','modeladvisor','private');
    notRunIcon.FilePath=fullfile(imagepath,'icon_task.png');


    notRunCounter.Name=num2str(this.NumNotRun);
    if this.IsResultAvailable
        notRunCounter.Type='hyperlink';
        notRunCounter.ObjectMethod='showReport';
        notRunCounter.MethodArgs={'showNotRunChecks'};
        notRunCounter.ArgDataTypes={'string'};
        notRunCounter.ToolTip=DAStudio.message('ModelAdvisor:engine:MADashboardShowReport');
    else
        notRunCounter.Type='text';
        notRunCounter.WordWrap=true;
    end
    notRunCounter.Tag='text_notRunCounter';
    notRunCounter.RowSpan=[1,1];
    notRunCounter.ColSpan=[8,8];

    ResultGroup.Items={passedIcon,passedCounter,...
    failedIcon,failedCounter,warnIcon,warnCounter,...
    notRunIcon,notRunCounter};



    runButton.Type='pushbutton';
    imagepath=fullfile(matlabroot,'toolbox','simulink','simulink','modeladvisor','resources');
    runButton.FilePath=fullfile(imagepath,'run_small.png');
    runButton.Tag='RunAdvisor';
    runButton.RowSpan=[1,1];
    runButton.ColSpan=[1,1];
    runButton.DialogRefresh=true;
    runButton.ObjectMethod='runTaskAdvisor';
    runButton.MethodArgs={};
    runButton.ArgDataTypes={};
    runButton.ToolTip=[DAStudio.message('ModelAdvisor:engine:MADashboardRunMA'),configFileStr];
    runButton.Enabled=~this.IsRunning;


    cancelButton.Type='pushbutton';
    cancelButton.FilePath=fullfile(imagepath,'stop.png');
    cancelButton.Tag='CancelRunAdvisor';
    cancelButton.RowSpan=[1,1];
    cancelButton.ColSpan=[1,1];
    cancelButton.DialogRefresh=true;
    cancelButton.ObjectMethod='cancelBackgroundRun';
    cancelButton.MethodArgs={};
    cancelButton.ArgDataTypes={};
    cancelButton.ToolTip=[DAStudio.message('ModelAdvisor:engine:BackgroundRunCancelTooltip'),configFileStr];



    status.Name=this.getStatusText();
    status.Type='text';
    status.WordWrap=true;
    status.Tag='text_status';
    status.RowSpan=[2,2];
    status.ColSpan=[1,8];

    reportButton.Type='pushbutton';
    reportButton.FilePath=fullfile(imagepath,'report_lite.png');
    reportButton.Tag='ShowReport';
    reportButton.RowSpan=[1,1];
    reportButton.ColSpan=[2,2];
    reportButton.DialogRefresh=true;
    reportButton.ObjectMethod='showReport';
    reportButton.MethodArgs={''};
    reportButton.ArgDataTypes={'string'};
    reportButton.ToolTip=DAStudio.message('ModelAdvisor:engine:MADashboardOpenReport');
    reportButton.Enabled=~this.IsRunning;

    highlightButton.Type='pushbutton';
    highlightButton.FilePath=fullfile(imagepath,'overlay.png');
    highlightButton.FilePath=fullfile(imagepath,'overlay.png');
    highlightButton.Tag='highlightButton';
    highlightButton.RowSpan=[1,1];
    highlightButton.ColSpan=[3,3];
    highlightButton.DialogRefresh=true;
    highlightButton.Enabled=~this.IsRunning;
    if this.IsResultAvailable
        highlightButton.ObjectMethod='clickHighlight';
    end
    if this.getHighlight()
        highlightButton.ToolTip=DAStudio.message('ModelAdvisor:engine:MADashboardUnHighlight');
    else
        highlightButton.ToolTip=DAStudio.message('ModelAdvisor:engine:MADashboardHighlight');
    end


    expandViewButton.Type='pushbutton';
    expandViewButton.FilePath=fullfile(imagepath,'max.png');

    expandViewButton.Tag='ExpandView';
    expandViewButton.RowSpan=[1,1];
    expandViewButton.ColSpan=[5,5];
    expandViewButton.Enabled=1;
    expandViewButton.DialogRefresh=true;
    expandViewButton.ObjectMethod='switchToFullMode';
    expandViewButton.MethodArgs={};
    expandViewButton.ArgDataTypes={};
    expandViewButton.ToolTip=DAStudio.message('ModelAdvisor:engine:MADashboardSwitch');

    mdladvObj=this.getMAObj;
    isRunInBackground=~isempty(mdladvObj)&&mdladvObj.runInBackground;
    if isRunInBackground&&this.IsRunning
        items={cancelButton,status};
    else
        items={runButton};
    end
    dlgstruct.Items=[items,{reportButton},{highlightButton},{ResultGroup},{expandViewButton}];
end

