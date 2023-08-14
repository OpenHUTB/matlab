function dlgstruct=getDialogSchema(h,name)%#ok<INUSD>





    pf=get(0,'ScreenPixelsPerInch')/72;



    isStopped=h.stopped;
    isFinalized=h.finalized;
    isLogSaved=~isempty(h.logPath);
    isBrokeOnCompat=h.breakOnCompat;
    isCoreAnalInProgress=h.sldvCoreAnalInProgress;

    info.Type='textbrowser';
    info.Text=h.ProgressStr;
    info.RowSpan=[1,1];
    info.ColSpan=[1,1];
    info.Tag='browserarea';
    info.Visible=h.hasInfoPanel;
    info.MinimumSize=pf*[400,120];
    info.MaximumSize=pf*[4400,120];

    logDisp.Name='LogText';
    logDisp.Type='textbrowser';
    logDisp.Text=h.Log;
    logDisp.Tag='logarea';
    logDisp.Editable=false;
    logDisp.RowSpan=[2,2];
    logDisp.ColSpan=[1,1];
    logDisp.MinimumSize=pf*[400,280];
    if runningMdlAdvDesignErrDetection()
        logDisp.Visible=false;
    end

    bottomtext.Name=' ';
    bottomtext.Type='text';
    bottomtext.RowSpan=[1,1];
    bottomtext.ColSpan=[1,4];
    bottomtext.Tag='bottomtext';
    bottomtext.Visible=~isFinalized;

    bottomtext2.Name=' ';
    bottomtext2.Type='text';
    bottomtext2.RowSpan=[1,1];
    bottomtext2.ColSpan=[1,3];
    bottomtext2.Tag='bottomtext2';
    bottomtext2.Visible=isFinalized;


    if slavteng('feature','IncrementalHighlighting')
        modelH=get_param(h.modelName,'Handle');
        session=sldvprivate('sldvGetActiveSession',modelH);
        if session.HighlightStatusFlag
            highlightStatus.Name=getString(message('Sldv:SldvresultsSummary:DisableHighlight'));
        else
            highlightStatus.Name=getString(message('Sldv:SldvresultsSummary:EnableHighlight'));
        end
    else
        highlightStatus.Name=getString(message('Sldv:SldvresultsSummary:Highlight'));
    end
    highlightStatus.Type='pushbutton';
    highlightStatus.RowSpan=[1,1];
    highlightStatus.ColSpan=[4,4];
    highlightStatus.Tag='highlightStatus';
    highlightStatus.DialogRefresh=true;
    highlightStatus.Visible=~isFinalized&&~isBrokeOnCompat&&h.hasInfoPanel;
    highlightStatus.Enabled=~isStopped&&isCoreAnalInProgress;
    highlightStatus.ObjectMethod='highlightCallback';
    highlightStatus.MethodArgs={'%dialog'};
    highlightStatus.ArgDataTypes={'handle'};

    aborter.Name=getString(message('Sldv:SldvresultsSummary:Stop'));
    aborter.Type='pushbutton';
    aborter.RowSpan=[1,1];
    aborter.ColSpan=[5,5];
    aborter.Tag='aborter';
    aborter.DialogRefresh=true;
    aborter.Visible=~isFinalized&&~isBrokeOnCompat;
    aborter.Enabled=~isStopped;
    aborter.ObjectMethod='abortAnalysis';
    aborter.MethodArgs={'%dialog'};
    aborter.ArgDataTypes={'handle'};

    saveButton.Name=getString(message('Sldv:SldvresultsSummary:SaveLog'));
    if isLogSaved
        saveButton.Name=getString(message('Sldv:SldvresultsSummary:ViewLog'));
    end
    saveButton.Type='pushbutton';
    saveButton.RowSpan=[1,1];
    saveButton.ColSpan=[3,3];
    saveButton.Tag='save';
    saveButton.DialogRefresh=true;
    saveButton.Visible=isLogSaved||isFinalized||isBrokeOnCompat;



    saveButton.Enabled=saveButton.Visible;
    saveButton.ObjectMethod='saveButton';
    saveButton.MethodArgs={'%dialog'};
    saveButton.ArgDataTypes={'handle'};

    closeButton.Name=getString(message('Sldv:SldvresultsSummary:Close'));
    closeButton.Type='pushbutton';
    closeButton.RowSpan=[1,1];
    closeButton.ColSpan=[5,5];
    closeButton.Tag='close';
    closeButton.DialogRefresh=true;
    closeButton.Visible=isFinalized||isBrokeOnCompat;
    closeButton.ObjectMethod='closeButton';
    closeButton.MethodArgs={'%dialog'};
    closeButton.ArgDataTypes={'handle'};

    analyzeStatus.Type='pushbutton';
    analyzeStatus.RowSpan=[1,1];
    analyzeStatus.ColSpan=[4,4];
    analyzeStatus.Tag='analyzeStatus';
    analyzeStatus.DialogRefresh=true;
    analyzeStatus.Visible=~h.hasInfoPanel||isBrokeOnCompat;




    if~isempty(h.testComp)&&isa(h.testComp,'SlAvt.TestComponent')&&ishandle(h.testComp)

        analyzeMode=h.testComp.activeSettings.Mode;
        if strcmp(analyzeMode,'TestGeneration')
            analyzeStatus.Name=DAStudio.message('Sldv:dialog:sldvDVOptionGenTests');
        elseif strcmp(analyzeMode,'PropertyProving')
            analyzeStatus.Name=DAStudio.message('Sldv:dialog:sldvDVOptionProveProps');
        else
            analyzeStatus.Name=DAStudio.message('Sldv:dialog:sldvDVOptionDetectErrs');
        end

        h.AnalysisMode=analyzeStatus.Name;

        if strcmp(h.testComp.activeSettings.RequirementsTableAnalysis,'on')



            analyzeStatus.Visible=false;
        end



        compatFlag=strcmp(h.testComp.compatStatus,'DV_COMPAT_COMPATIBLE')||...
        strcmp(h.testComp.compatStatus,'DV_COMPAT_PARTIALLY_SUPPORTED');
    else
        analyzeStatus.Name=h.AnalysisMode;
        compatFlag=false;
    end




    analyzeStatus.Enabled=compatFlag&&~isStopped;
    analyzeStatus.ObjectMethod='analyzeCallback';
    analyzeStatus.MethodArgs={'%dialog'};
    analyzeStatus.ArgDataTypes={'handle'};

    bottom.Name=' ';
    bottom.Type='panel';
    bottom.Items={bottomtext,bottomtext2,highlightStatus,analyzeStatus,aborter,...
    saveButton,closeButton};
    bottom.LayoutGrid=[1,5];
    bottom.ColStretch=[1,1,1,0,0];
    bottom.RowStretch=0;
    bottom.RowSpan=[3,3];
    bottom.ColSpan=[1,1];
    if runningMdlAdvDesignErrDetection()
        bottom.Visible=false;
    end

    panel.Name='';
    panel.Type='panel';
    panel.Items={info,logDisp,bottom};
    panel.LayoutGrid=[3,1];
    panel.RowSpan=[1,3];
    panel.ColSpan=[1,1];
    panel.RowStretch=[0,1,0];
    panel.ColStretch=1;
    panel.Alignment=0;

    if~isempty(h.testComp)&&ishandle(h.testComp)
        if~strcmp(h.testComp.label,'DefaultBlockDiagram')
            modelIdent=[': ',h.testComp.label];
        elseif~isempty(h.modelName)
            modelIdent=[': ',h.modelName];
        else
            modelIdent='';
        end
    else
        modelIdent='';
    end
    resSummary=getString(message('Sldv:SldvresultsSummary:sldvResultsSummary'));
    titlestr=[resSummary,modelIdent];
    dlgstruct.DialogTitle=titlestr;
    dlgstruct.DialogTag='SLDV_RESULT_DIALOG';
    dlgstruct.LayoutGrid=[3,1];
    dlgstruct.Items={panel};
    dlgstruct.StandaloneButtonSet={''};
    dlgstruct.CloseMethod='destroyLogarea';
    dlgstruct.CloseMethodArgs={'%dialog'};
    dlgstruct.CloseMethodArgsDT={'handle'};









    function out=runningMdlAdvDesignErrDetection()
        out=false;
        if~ModelAdvisor.isRunning
            return;
        end
        mdlAdv=Simulink.ModelAdvisor.getActiveModelAdvisorObj();
        check=mdlAdv.getActiveCheck();
        out=contains(check,'mathworks.sldv.')&&...
        ~strcmp(check,'mathworks.sldv.compatibility');
