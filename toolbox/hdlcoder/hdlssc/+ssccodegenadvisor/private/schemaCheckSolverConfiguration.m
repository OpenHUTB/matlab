function[addon]=schemaCheckSolverConfiguration(task)















    dlgInfo=getCheckSolverConfigurationDialog();

    addon.Items{1}=dlgInfo.Items{1};
    addon.Items{1}.Enabled=true;


    addon.DialogTitle=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_checks:checkSolverConfigurationCheckTitle');
    addon.DialogTag='com.mathworks.hdlssc.ssccodegenadvisor.checkSolverConfigurationDialog';
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

    addon.Items{end+1}=runBtn;
    addon.Items{end+1}=ResultMsg;
    addon.Items{end+1}=ResultIcon;
    addon.Items{end+1}=ResultStatusString;
    addon.Items{end+1}=summary;

    addon.LayoutGrid=[6,5];
    addon.ColStretch=[0,0,1,1,1];
end
