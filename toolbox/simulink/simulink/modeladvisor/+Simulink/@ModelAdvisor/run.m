function run(this,varargin)















    PerfTools.Tracer.logMATLABData('MAGroup','Simulink.ModelAdvisor.run',true);
    this.stage='createFramework';

    if ModelAdvisor.isRunning
        this.displayExplorer;
        warning('Model Advisor is running in background. Please wait for it to finish');
        return;
    end


    if~ishandle(this.SystemHandle)
        this.SystemHandle=get_param(this.SystemName,'Handle');
    end



    if~strcmp(this.SystemName,getfullname(this.SystemHandle))
        if~strcmp(this.CustomTARootID,'com.mathworks.FPCA.FixedPointConversionTask')
            if strcmp(this.CustomTARootID,Simulink.ModelReference.Conversion.ModelRefAdvisorFactory.AdvisorMainGroupId)



                this.SystemName=getfullname(this.SystemHandle);
            else
                DAStudio.error('ModelAdvisor:engine:MASystemRenamed',this.SystemName,getfullname(this.SystemHandle),getfullname(this.SystemHandle));
            end
        else
            DAStudio.error('ModelAdvisor:engine:FPASystemRenamed',this.SystemName,getfullname(this.SystemHandle),getfullname(this.SystemHandle));
        end
    end


    cmdLineRun=this.CmdLine;

    this.updateExclusion;
    Simulink.ModelAdvisor.checkEnvironment(this.System);


    [hasActiveTestHarness,activeTestHarness]=Advisor.Utils.Simulink.modelHasActiveTestHarness(bdroot(this.SystemName));

    mp=ModelAdvisor.Preferences;

    if hasActiveTestHarness
        if this.CmdLine
            DAStudio.error('ModelAdvisor:engine:MAActiveTestHarnessErrorMSG2');



        elseif~strcmp(this.Stage,'init')
            ButtonName=questdlg(DAStudio.message('ModelAdvisor:engine:MAActiveTestHarnessMSG'),...
            DAStudio.message('ModelAdvisor:engine:AccordionMAName'),...
            DAStudio.message('ModelAdvisor:engine:CmdAPIWarningDialogContinue'),...
            DAStudio.message('Simulink:tools:MACancel'),...
            DAStudio.message('ModelAdvisor:engine:CmdAPIWarningDialogContinue'));

            if strcmp(ButtonName,DAStudio.message('Simulink:tools:MACancel'))
                return;
            else


                Simulink.harness.close(activeTestHarness.ownerFullPath,...
                activeTestHarness.name);
            end
        else



        end
    end



    try
        model=getfullname(this.System);
    catch E
        disp(E.message);
        errordlg(DAStudio.message('Simulink:tools:MAUnableOpenModel'));
    end









    if nargin>2
        rerunMode=true;
        overwriteHTML=varargin{2};
        rerunTaskID=varargin{1};
        if ischar(rerunTaskID)||isnumeric(rerunTaskID)
            rerunTaskID={rerunTaskID};
        end
        fromTaskAdvisorNode=varargin{3};
    else
        rerunMode=false;
        overwriteHTML=true;
        rerunTaskID={};
        fromTaskAdvisorNode=[];
    end
    if this.StartTime~=0
        this.RunTime=this.StartTime;
    else
        this.RunTime=now;
    end


    if cmdLineRun==false
        modeladvisorprivate('modeladvisorutil2','CloseResultGUICallback');
    end

    cr=newline;

    div_start=modeladvisorprivate('modeladvisorutil2','CreateIgnorePortion','<div class="subsection">');
    div_end=modeladvisorprivate('modeladvisorutil2','CreateIgnorePortion','</div>');


    this.AtticData.ActionObjects={};


    if~exist(this.AtticData.WorkDir,'dir')
        this.AtticData.WorkDir=this.getWorkDir;
    end

    NeedSupportLib=this.IsLibrary&&modeladvisorprivate('modeladvisorutil2','FeatureControl','SupportLibrary');


    if~this.MultiMode
        this.stage='createRightPane';
        rightFrame=this.AtticData.DiagnoseRightFrame;
        if overwriteHTML
            f=fopen(rightFrame,'w','n','utf-8');
            if f==-1
                DAStudio.error('Simulink:tools:MAUnableCreateFilesInDirectory',pwd);

            end
        end


        htmlSource=modeladvisorprivate('modeladvisorutil2','createReportHeaderSection',...
        this,rerunMode,fromTaskAdvisorNode,this.RunTime);
    else

        htmlSource='';
    end




    compileerrormsg='';
    NoCheckHasBeenRun=true;
    numCheckRuns=0;
    numCheckPassed=0;
    numCheckFailed=0;
    CGIRFailed=false;
    CompileFailed=false;
    SLDVCompileFailed=false;
    CovCompileStatus=0;
    this.UserCancel=false;



    ServiceQueue={};


    [orderedCheckIndex,orderedTaskIndex,orderedCheckIndexCGIR,orderedCheckIndexSLDV]=this.getExecutionOrder(rerunTaskID,rerunMode,fromTaskAdvisorNode);




    RunnedChecksArray=[];

    if~this.MultiMode
        IDList=cell(1,length(orderedCheckIndexCGIR));
        for cgirIdx=1:length(IDList)
            IDList{cgirIdx}=this.checkCellArray{orderedCheckIndexCGIR{cgirIdx}}.ID;
        end
        Advisor.RegisterCGIRInspectors.getInstance.addInspectors(IDList);


        IDList=cell(1,length(orderedCheckIndexSLDV));
        for idx=1:numel(IDList)
            IDList{idx}=this.checkCellArray{orderedCheckIndexSLDV{idx}}.ID;
        end
        if~isempty(IDList)
            Advisor.SLDVCompileService.getInstance.registerSLDVChecks(IDList);
        end
    end
    PerfTools.Tracer.logMATLABData('MAGroup','Waitbar Creation',true);
    if~cmdLineRun&&desktop('-inuse')&&this.ShowProgressbar
        if~slfeature('AdvisorWebUI')
            if length(orderedCheckIndex)>1
                hWait=waitbar(0,['                                                                       ',DAStudio.message('Simulink:tools:MAProcessCallbacks'),'                                                                       '],'Name',DAStudio.message('Simulink:tools:MAPleaseWait'),'CreateCancelBtn','modeladvisorprivate(''modeladvisorutil2'',''WaitbarCancelBtnCallback'')');
            else
                hWait=waitbar(0,['                                                                       ',DAStudio.message('Simulink:tools:MAProcessCallbacks'),'                                                                       '],'Name',DAStudio.message('Simulink:tools:MAPleaseWait'));
            end



            this.Waitbar=hWait;
        else
            hWait=-1;
            this.Waitbar=-1;
        end
    end
    PerfTools.Tracer.logMATLABData('MAGroup','Waitbar Creation',false);
    waitbarIncrements=length(orderedCheckIndex);
    waitbarLength=0;

    this.stage='ExecuteCheckCallback';
    sess=Simulink.CMI.EIAdapter(1001);



    addCGIRRefMdlMsg=false;
    if~isempty(orderedCheckIndexCGIR)


        if Simulink.internal.useFindSystemVariantsMatchFilter()
            refMdls=find_mdlrefs(bdroot(this.SystemName),...
            'MatchFilter',@Simulink.match.activeVariants);
        else
            refMdls=find_mdlrefs(bdroot(this.SystemName),'Variants','ActiveVariants');
        end

        if length(refMdls)>1
            for n=1:length(refMdls)
                if bdIsLoaded(refMdls{n})
                    value=get_param(refMdls{n},'UpdateModelReferenceTargets');

                    if~strcmp(value,'Force')
                        addCGIRRefMdlMsg=true;
                        break;
                    end
                end
            end
        end
    end


    checkIDsSelectedForExecution={};

    edittimeConfigNode={};
    for i=1:length(orderedCheckIndex)

        checkObj=this.CheckCellArray{orderedCheckIndex{i}};
        checkIDsSelectedForExecution{end+1}=checkObj.ID;%#ok<AGROW>


        if isempty(checkObj.Callback)
            am=Advisor.Manager.getInstance;
            am.loadCachedFcnHandle(checkObj);
        end

        if checkObj.SupportsCppCodeReuse

            if isa(fromTaskAdvisorNode,'ModelAdvisor.Node')
                TaskObj=this.TaskAdvisorCellArray{orderedTaskIndex{i}};
                nodeObj=TaskObj;
            else
                nodeObj=checkObj;
            end

            edittimeConfigNode{end+1}=Advisor.Utils.createEdittimeCheckData(nodeObj);
        end

    end


    if~isempty(edittimeConfigNode)

        configuration=Advisor.Utils.createJSONfromStruct(edittimeConfigNode);
        configManager=slcheck.ConfigurationManagerInterface();
        configManager.clear();
        configManager.setRTConfigForStateflowETEngine(configuration);

        sfManObj=slcheck.MASFEditTimeManager.getInstance();
        sfManObj.clearCache();
    end



    this.AtticData.CheckIDsSelectedForExecution=checkIDsSelectedForExecution;

    this.lookForDeprecatedChecks(false);




    cgirCompileErrorMsg='';
    sldvCompileErrorMsg='';

    for i=1:length(orderedCheckIndex)

        if this.parallel
            pInfo=this.Database.loadData('ParallelInfo');
            if~isempty(pInfo)&&isfield(pInfo,'cancel')&&~isempty(pInfo.cancel)&&(pInfo.cancel==1)
                this.UserCancel=true;
            end
        end


        if this.UserCancel
            break;
        end


        if~isempty(orderedTaskIndex)
            this.TaskAdvisorCellArray{orderedTaskIndex{i}}.RunTime=this.RunTime;
            this.LatestRunID=this.TaskAdvisorCellArray{orderedTaskIndex{i}}.ID;
        end

        recordCounter=orderedCheckIndex{i};

        if rerunMode&&isa(fromTaskAdvisorNode,'ModelAdvisor.Node')


            checkHasNotRun=true;
            TaskObj=this.TaskAdvisorCellArray{orderedTaskIndex{i}};
            CheckObj=TaskObj.Check;
            CheckObj.TaskID=TaskObj.ID;



            PerfTools.Tracer.logMATLABData('MAGroup','Update maObj.CheckCellArray{pointer}',true);
            this.CheckCellArray{recordCounter}=[];
            this.CheckCellArray{recordCounter}=CheckObj;
            PerfTools.Tracer.logMATLABData('MAGroup','Update maObj.CheckCellArray{pointer}',false);
            this.FastCheckAccessTable(recordCounter)=orderedTaskIndex{i};

        else



            if isempty(find(RunnedChecksArray==recordCounter,1))
                RunnedChecksArray(end+1)=recordCounter;%#ok<AGROW>
                checkHasNotRun=true;
            else
                checkHasNotRun=false;
            end
            TaskObj=[];
            CheckObj=this.CheckCellArray{recordCounter};
            CheckObj.TaskID=CheckObj.ID;
        end

        this.ActiveCheck=CheckObj;




        enableCheck=true;
        if strcmp(this.CustomTARootID,'_modeladvisor_')...
            &&~isempty(CheckObj)&&any(strcmp(CheckObj.CallbackContext,{'SLDV','CGIR'}))


            if isa(fromTaskAdvisorNode,'ModelAdvisor.Group')
                enableCheck=fromTaskAdvisorNode.ExtensiveAnalysis;
            end
        end

        if~enableCheck
            continue;
        end



        if this.GlobalTimeOut
            this.TaskAdvisorCellArray{orderedTaskIndex{i}}.updateStates(ModelAdvisor.CheckStatus.Failed,'fastmode');
            this.TaskAdvisorCellArray{orderedTaskIndex{i}}.failed=1;
            this.setCheckErrorSeverity(10);
            this.setActionEnable(false);
            msg=DAStudio.message('SimulinkPerformanceAdvisor:advisor:GlobalTimeOutException');
            CheckObj.ResultInHTML=msg;
            break;
        end


        numCheckRuns=numCheckRuns+1;
        waitbarLength=waitbarLength+1/waitbarIncrements;

        if~isempty(orderedTaskIndex)
            ShowTitleMsg=this.TaskAdvisorCellArray{orderedTaskIndex{i}}.DisplayName;
        elseif recordCounter>0
            ShowTitleMsg=this.CheckCellArray{recordCounter}.Title;
        else
            ShowTitleMsg='unknown';
        end





        waitbarTitle=strrep(ShowTitleMsg,'_','\_');
        if~cmdLineRun&&slfeature('AdvisorWebUI')&&~isempty(this.AdvisorWindow)
            this.AdvisorWindow.publishToUI('Advisor::ProgressBar',struct('Message',waitbarTitle,'Value',round(waitbarLength*100)));
        else
            if~cmdLineRun&&desktop('-inuse')&&this.ShowProgressbar&&ishandle(hWait)
                waitbar(waitbarLength,hWait,[DAStudio.message('Simulink:tools:MAProcessing'),': ',waitbarTitle]);
            end
        end



        if this.parallel
            this.Database.overwriteLatestData('ParallelInfo','index',int32(i),...
            'orderedTaskIndex',int32(length(orderedTaskIndex)),...
            'status',{''});
        end

        this.ActiveCheckID=recordCounter;

        if recordCounter>0&&checkHasNotRun

            CheckObj.Result={};
            if isa(CheckObj,'ModelAdvisor.Check')
                if isa(CheckObj.Action,'ModelAdvisor.Action')
                    CheckObj.Action.ResultInHTML='';
                    CheckObj.Action.Success=false;
                end
                CheckObj.Success=false;






                CheckObj.ErrorSeverity=CheckObj.DefaultErrorSeverity;
                CheckObj.setStatus(ModelAdvisor.CheckStatus.NotRun);
            end
            CheckObj.RunComplete=true;

            CheckObj.ListViewParameters={};
            CheckObj.FoundObjects={};
            CheckObj.ProjectResultData={};


            if slfeature('AdvisorIntegrationEditTimeCheck2')&&...
                (isa(CheckObj,'ModelAdvisor.slEdittimeCheck')||...
                isa(CheckObj,'ModelAdvisor.slsfEdittimeCheck'))
                CheckObjHasNoEdittimeResults=true;
                resultsCollection=ModelAdvisor.ResultDetail.empty;
                for ii=1:numel(edittimeResults)
                    if strcmp(edittimeResults(ii).CheckID,CheckObj.ID)
                        resultsCollection(end+1)=edittimeResults(ii);
                        CheckObjHasNoEdittimeResults=false;
                    end
                end
                if CheckObjHasNoEdittimeResults
                    CheckObj.Success=true;
                    CheckObj.setLegacyCheckStatus();
                end
                CheckObj.setResultDetails(resultsCollection);
            else
                CheckObj.setResultDetails([]);
            end
            CheckObj.setCacheResultInHTMLForNewCheckStyle({});
        end

        if~this.MultiMode
            if NoCheckHasBeenRun


                htmlSource=[htmlSource,'<!-- Overall check running Status Flag -->'];%#ok<AGROW>
                htmlSource=[htmlSource,'<!-- Compile Status Flag -->'];%#ok<AGROW>
                htmlSource=[htmlSource,'<!-- Service Status Flag -->'];%#ok<AGROW>
                NoCheckHasBeenRun=false;
            end


            if~rerunMode||~isa(fromTaskAdvisorNode,'ModelAdvisor.Node')

                htmlOut=createCheckOuputHeader(this,i==1,recordCounter);
                htmlSource=[htmlSource,htmlOut];%#ok<AGROW>
            end
        end


        if recordCounter>0&&checkHasNotRun
            try




                if isempty(CheckObj.Callback)
                    am=Advisor.Manager.getInstance;
                    am.loadCachedFcnHandle(CheckObj);
                end



                if~this.MultiMode&&~strcmpi(CheckObj.CallbackContext,'None')

                    [CompileFailed,CGIRFailed,CovCompileStatus,SLDVCompileFailed,compileerrormsg]=...
                    this.handleModelCompileForCheck(CheckObj,...
                    CompileFailed,CGIRFailed,CovCompileStatus,SLDVCompileFailed,...
                    waitbarLength);
                    if CGIRFailed&&strcmpi(CheckObj.CallbackContext,'CGIR')
                        if strcmp(compileerrormsg,'')
                            compileerrormsg=cgirCompileErrorMsg;
                        else
                            cgirCompileErrorMsg=compileerrormsg;
                        end
                    end
                    if SLDVCompileFailed&&strcmpi(CheckObj.CallbackContext,'SLDV')
                        if strcmp(compileerrormsg,'')
                            compileerrormsg=sldvCompileErrorMsg;
                        else
                            sldvCompileErrorMsg=compileerrormsg;
                        end
                    end
                end




                [ServiceQueue,ServiceSuccess,ServiceMessage]=PushService(ServiceQueue,CheckObj,model);




                [preRequMet,ResultDescription,ResultHandles,htmlSource]=...
                this.verifyCheckPrerequisits(CheckObj,NeedSupportLib,...
                ServiceSuccess,ServiceMessage,compileerrormsg,...
                CovCompileStatus,SLDVCompileFailed,htmlSource);



                if preRequMet

                    PerfTools.Tracer.logMATLABData('MAGroup','Execute Check Callback',true);
                    if mp.ShowProfiler
                        PerfTools.Tracer.logSimulinkData('MAGroup',CheckObj.ID,CheckObj.Title,['Execute ''',CheckObj.Title,''''],true);
                    end

                    notify(this,'CheckExecutionStart',Advisor.CheckExecutionStartEventDataClass(CheckObj.ID,CheckObj.Title,this.SystemName));
                    [ResultDescription,ResultHandles,htmlOut]=...
                    this.executeCheckCallbackFct(CheckObj,model,TaskObj);

                    if mp.ShowProfiler
                        PerfTools.Tracer.logSimulinkData('MAGroup',CheckObj.ID,CheckObj.Title,['Execute ''',CheckObj.Title,''''],false);
                    end
                    PerfTools.Tracer.logMATLABData('MAGroup','Execute Check Callback',false);

                    if~this.MultiMode
                        htmlSource=[htmlSource,htmlOut];%#ok<AGROW>
                    end

                    CheckObj.setLegacyCheckStatus();


                    if isa(fromTaskAdvisorNode,'ModelAdvisor.Node')&&(strcmpi(TaskObj.Severity,'Required'))&&...
                        (CheckObj.status==ModelAdvisor.CheckStatus.Warning)
                        CheckObj.setStatus(ModelAdvisor.CheckStatus.Failed);
                    end


                    PerfTools.Tracer.logMATLABData('MAGroup','Format Check Output',true);
                    ExecFunctionReturnInHTML=this.formatCheckCallbackOutput(CheckObj,ResultHandles,ResultDescription,recordCounter,addCGIRRefMdlMsg,TaskObj);
                    PerfTools.Tracer.logMATLABData('MAGroup','Format Check Output',false);
                else
                    CheckObj.setLegacyCheckStatus();
                    ExecFunctionReturnInHTML=this.formatCheckCallbackOutput(CheckObj,ResultHandles,ResultDescription,recordCounter,false);
                end


                if CheckObj.Success
                    numCheckPassed=numCheckPassed+1;
                else
                    numCheckFailed=numCheckFailed+1;
                end

                if(~CheckObj.IsCustomCheck)
                    Simulink.DDUX.logData('CHECK_ID','checkid',CheckObj.ID);
                end

            catch E

                PerfTools.Tracer.logMATLABData('MAGroup','Execute Check Callback',false);
                PerfTools.Tracer.logMATLABData('MAGroup','Format Check Output',false);

                numCheckFailed=numCheckFailed+1;
                errmsg=Simulink.ModelAdvisor.getErrorMessage(E);

                ExecFunctionReturnInHTML=['<p />',ModelAdvisor.Text([DAStudio.message('Simulink:tools:MAAbnormalExit'),' ',errmsg],{'fail'}).emitHTML];

                if isa(CheckObj,'ModelAdvisor.Check')
                    CheckObj.Success=false;
                    CheckObj.Status=ModelAdvisor.CheckStatus.Incomplete;
                    CheckObj.setLegacyCheckStatus()

                    if(~checkObj.IsCustomCheck)
                        Simulink.DDUX.logData('CHECK_ID','checkid',CheckObj.ID,'checkerrored',CheckObj.ID)
                    end
                end
                CheckObj.RunComplete=false;
                disp(errmsg);
            end


            CheckObj.ResultInHTML=ExecFunctionReturnInHTML;

            if~strcmp(CheckObj.CallbackStyle,'DetailStyle')

                if~isempty(CheckObj.ProjectResultData)&&isempty(CheckObj.ResultDetails)&&slfeature('ModelAdvisorAutoConvertNewStyleViewUsingProjectResultData')
                    Advisor.Utils.convertProjectResultDataIntoResultDetailObjs(CheckObj,TaskObj);
                end

                if~isempty(CheckObj.ResultDetails)
                    CheckObj.setCacheResultInHTMLForNewCheckStyle(CheckObj.ResultInHTML);
                    if~ismember('ModelAdvisor.Report.DefaultStyle',CheckObj.SupportedReportStyles)
                        CheckObj.setSupportedReportStyles(['ModelAdvisor.Report.DefaultStyle',CheckObj.SupportedReportStyles]);
                        CheckObj.setReportStyle('ModelAdvisor.Report.DefaultStyle');
                    else
                        reportObj=ModelAdvisor.Report.StyleFactory.creator(CheckObj.ReportStyle);
                        fts=reportObj.generateReport(CheckObj);
                        if ischar(fts)
                            htmlOut=fts;
                        else
                            htmlOut='';
                            for ftCounter=1:length(fts)
                                htmlOut=[htmlOut,modeladvisorprivate('modeladvisorutil2','emitHTMLforMAElements',fts{ftCounter})];%#ok<AGROW>
                            end
                        end
                        CheckObj.ResultInHTML=htmlOut;
                    end
                end
            else
                if~isempty(CheckObj.CallbackHandle)&&nargout(CheckObj.CallbackHandle)>0
                    if~strcmp(CheckObj.ReportStyle,'ModelAdvisor.Report.DefaultStyle')&&~ischar(CheckObj.CallbackHandle)
                        CheckDirectOutputInHTML=this.formatCheckCallbackOutput(CheckObj,CheckObj.CacheResultInHTMLForNewCheckStyle,ResultDescription,recordCounter,addCGIRRefMdlMsg,TaskObj);
                    else
                        CheckDirectOutputInHTML=CheckObj.ResultInHTML;
                    end

                    CheckObj.setCacheResultInHTMLForNewCheckStyle(CheckDirectOutputInHTML);
                end
            end

        elseif recordCounter<0

            numCheckFailed=numCheckFailed+1;
            ExecFunctionReturnInHTML=['<p />',ModelAdvisor.Text(DAStudio.message('Simulink:tools:MAMissCorrespondCheck',this.CheckCellArray{orderedCheckIndex{i}}.ID),{'fail'}).emitHTML];
            ExecFunctionReturnInHTML=[div_start,ExecFunctionReturnInHTML,div_end];%#ok<AGROW>

        elseif~checkHasNotRun


            if isa(CheckObj,'ModelAdvisor.informer')||CheckObj.Success
                numCheckPassed=numCheckPassed+1;
            else
                numCheckFailed=numCheckFailed+1;
            end
            ExecFunctionReturnInHTML=CheckObj.ResultInHTML;
        end


        if~this.MultiMode
            if~rerunMode||~isa(fromTaskAdvisorNode,'ModelAdvisor.Node')


                if recordCounter>0

                    imageName=modeladvisorprivate('modeladvisorutil2','GetIconForModelAdvisorCheck',CheckObj);
                    imageLink=['<img border="0" src="',imageName,'" />&#160;'];
                    if strcmp(imageName,'task_warning.png')
                        filterId='Warning Check';
                        filterClass='WarningCheck';
                    elseif strcmp(imageName,'task_failed.png')
                        filterId='Failed Check';
                        filterClass='FailedCheck';
                    else
                        filterId='Passed Check';
                        filterClass='PassedCheck';
                    end
                    if cmdLineRun

                        divStr=['<div name = "',filterId,'"  id = "',filterId,'" class = "',filterClass,'">'];
                    else
                        divStr='';
                    end
                    htmlSource=strrep(htmlSource,'<!-- Model Advisor Image Link Placeholder -->',modeladvisorprivate('modeladvisorutil2','CreateIgnorePortion',...
                    imageLink));
                    htmlSource=strrep(htmlSource,'<!-- Model Advisor Check Content div placeholder -->',divStr);



                    htmlSource=[htmlSource,ExecFunctionReturnInHTML,'<p><hr /></p>',cr];%#ok<AGROW>

                    if cmdLineRun

                        htmlSource=[htmlSource,modeladvisorprivate('modeladvisorutil2','CreateIgnorePortion','</div>'),cr];%#ok<AGROW>
                    end
                else
                    imageLink=['<img src="',modeladvisorprivate('modeladvisorutil2','GetIconForModelAdvisorCheck',-1),'" />&#160;'];
                    if cmdLineRun

                        divStr='<div name = "Failed Check"  id = "Failed Check" class = "FailedCheck">';
                    else
                        divStr='';
                    end
                    htmlSource=strrep(htmlSource,'<!-- Model Advisor Image Link Placeholder -->',modeladvisorprivate('modeladvisorutil2','CreateIgnorePortion',...
                    imageLink));
                    htmlSource=strrep(htmlSource,'<!-- Model Advisor Check Content div placeholder -->',divStr);
                    htmlSource=[htmlSource,ExecFunctionReturnInHTML,'<p><hr /></p>',cr];%#ok<AGROW>

                    if cmdLineRun

                        htmlSource=[htmlSource,modeladvisorprivate('modeladvisorutil2','CreateIgnorePortion','</div>'),cr];%#ok<AGROW>
                    end
                end
            end
        end


        PerfTools.Tracer.logMATLABData('MAGroup','Update Task Node Status',true);
        if~isempty(orderedTaskIndex)
            if recordCounter<0
                this.TaskAdvisorCellArray{orderedTaskIndex{i}}.updateStates(ModelAdvisor.CheckStatus.NotRun,'fastmode');
            elseif isa(CheckObj,'ModelAdvisor.Check')
                this.TaskAdvisorCellArray{orderedTaskIndex{i}}.updateStates(CheckObj.status,'fastmode');

            else
                this.TaskAdvisorCellArray{orderedTaskIndex{i}}.updateStates(CheckObj.status,'fastmode');





            end
        else
            this.CheckCellArray{recordCounter}.setStatus(CheckObj.status);
        end

        PerfTools.Tracer.logMATLABData('MAGroup','Update Task Node Status',false);


        if this.R2FMode
            if recordCounter<0||~isempty(orderedTaskIndex)&&modeladvisorprivate('modeladvisorutil2','shallWeStopatFailOntheNode',this.TaskAdvisorCellArray{orderedTaskIndex{i}},CheckObj)
                this.R2FStop=this.TaskAdvisorCellArray{orderedTaskIndex{i}};

                break
            end
        end









    end

    this.stage='CleanupCheckCallback';

    delete(sess);

    PerfTools.Tracer.logMATLABData('MAGroup','Waitbar Close',true);
    if~cmdLineRun&&desktop('-inuse')&&this.ShowProgressbar&&ishandle(hWait)
        delete(hWait);
    end
    PerfTools.Tracer.logMATLABData('MAGroup','Waitbar Close',false);
    PopService(ServiceQueue,model);

    if~this.MultiMode&&(this.HasCompiled||this.HasCompiledForCodegen)&&~this.R2FMode
        compileErrMsg=modeladvisorprivate('modeladvisorutil2','TerminateModelCompile',this);
        if~isempty(compileErrMsg)
            htmlSource=strrep(htmlSource,'<!-- Compile Status Flag -->',...
            ['<font color="#FF0000">',DAStudio.message('Simulink:tools:MAErrorOccurredCompile')...
            ,'</font><br /><br />',compileErrMsg]);
            disp(compileErrMsg);
        end
    end

    if~this.MultiMode&&this.HasCGIRed&&~this.R2FMode
        modeladvisorprivate('modeladvisorutil2','TermCGIRModelCompile',this);
    end

    if~this.MultiMode&&this.HasSLDVCompiled&&~this.R2FMode
        this.HasSLDVCompiled=false;
    end


    if~this.MultiMode

        passCt=0;
        failCt=0;
        warnCt=0;
        nrunCt=0;
        allCt=0;
        if rerunMode&&isa(fromTaskAdvisorNode,'ModelAdvisor.Node')
            PerfTools.Tracer.logMATLABData('MAGroup','Calculate Task Node Summary Info',true);
            [counterStructure,summaryTable]=modeladvisorprivate('modeladvisorutil2','getNodeSummaryInfo',fromTaskAdvisorNode);
            PerfTools.Tracer.logMATLABData('MAGroup','Calculate Task Node Summary Info',false);
            passCt=counterStructure.passCt;
            failCt=counterStructure.failCt;
            warnCt=counterStructure.warnCt;
            nrunCt=counterStructure.nrunCt;
            allCt=counterStructure.allCt;


            htmlSource=strrep(htmlSource,'<!-- Overall check running Status Flag -->',summaryTable);
        else
            if numCheckRuns>0

                [counterStructure,summaryTable]=modeladvisorprivate('modeladvisorutil2','getNodeSummaryInfo',fromTaskAdvisorNode,this.CheckCellArray,orderedCheckIndex);
                htmlSource=strrep(htmlSource,'<!-- Overall check running Status Flag -->',summaryTable);
            end
        end

        if NoCheckHasBeenRun
            htmlSource=[htmlSource,'<h4>',DAStudio.message('Simulink:tools:MAReportEmpty',DAStudio.message('Simulink:tools:MARunSelectedChecks')),'</h4>'];
        else
            if rerunMode&&isa(fromTaskAdvisorNode,'ModelAdvisor.Node')

                PerfTools.Tracer.logMATLABData('MAGroup','Emit HTML from Task Node',true);
                htmlSource=[htmlSource,cr,modeladvisorprivate('modeladvisorutil2','emitHTMLforTaskNode',fromTaskAdvisorNode,this.CheckCellArray),cr];
                PerfTools.Tracer.logMATLABData('MAGroup','Emit HTML from Task Node',false);
            end
        end


        htmlSource=modeladvisorprivate('modeladvisorutil2','embedImagesInHTML',htmlSource);



        htmlSource=[htmlSource,...
        '<!-- mdladv_ignore_start -->',cr,'</div><!-- mdladv_ignore_finish -->',...
        '<!-- mdladv_ignore_start -->',cr,'</div><!-- mdladv_ignore_finish -->'];


        htmlSource=[htmlSource,cr,'</body>  '];
        htmlSource=[htmlSource,cr,'</html>  '];

        if overwriteHTML
            fprintf(f,'%s',htmlSource);
            fclose(f);
        end


        if~this.MultiMode&&rerunMode&&isa(fromTaskAdvisorNode,'ModelAdvisor.Node')&&overwriteHTML
            reportFileName=['report_',num2str(fromTaskAdvisorNode.Index),'.html'];
            reportForTaskNodeName=[this.getWorkDir,filesep,reportFileName];
            counterStructure.reportName=reportFileName;

            if fromTaskAdvisorNode.Index>=0
                copyfile(this.AtticData.DiagnoseRightFrame,reportForTaskNodeName);
                if this.parallel
                    this.Database.saveMAReportData(counterStructure);
                else
                    this.AtticData.saveMAReportData=counterStructure;
                end
            end
        end
    end


    this.stage='ExecuteProcessCallback_processResult';
    cm=DAStudio.CustomizationManager;
    processCallBackFunList=cm.getModelAdvisorProcessFcns;
    if~isempty(processCallBackFunList)
        [this.CheckCellArray,this.TaskCellArray]=processCallBackFunList{1}('process_results',model,this.CheckCellArray,this.TaskCellArray);
    end





    if~this.MultiMode

        Advisor.RegisterCGIRInspectors.getInstance.clearInspectors;
        Advisor.RegisterCGIRInspectorResults.getInstance.clearResults;
        Advisor.SLDVCompileService.getInstance.term;
    end

    if this.parallel
        this.Database.saveMASessionData;
    end

    if~this.MultiMode&&overwriteHTML
        if isa(fromTaskAdvisorNode,'ModelAdvisor.Node')
            genNodeName=fromTaskAdvisorNode.DisplayName;
        else
            genNodeName='';
        end
        if this.parallel
            modeladvisorprivate('modeladvisorutil2','SaveGenerateInfo',this,genNodeName,this.RunTime,passCt,failCt,warnCt,nrunCt,allCt);
        else
            this.AtticData.saveMAGeninfoData={genNodeName,this.RunTime,passCt,failCt,warnCt,nrunCt,allCt};
        end
    end
    this.StartInTaskPage=false;
    PerfTools.Tracer.logMATLABData('MAGroup','Simulink.ModelAdvisor.run',false);


    if evalin('base','exist(''MAHook'')')
        storeModelAdvisorMetrics(this.SystemName,counterStructure);
    end






    function[ServiceQueue,success,message]=PushService(ServiceQueue,checkObj,System)
        success=true;
        message='';
        if~isempty(checkObj.PreCallbackHandle)
            serviceStarted=false;
            for i=1:length(ServiceQueue)
                if loc_compare_functionHandle(ServiceQueue{i}.precallback,checkObj.PreCallbackHandle)
                    success=ServiceQueue{i}.success;
                    message=ServiceQueue{i}.message;
                    return
                end
            end
            if~serviceStarted
                try

                    if nargout(checkObj.PreCallbackHandle)==1
                        success=checkObj.PreCallbackHandle(System);
                    else
                        [success,message]=checkObj.PreCallbackHandle(System);
                    end
                catch E
                    success=false;
                    message=E.message;
                    disp(message);
                end
                ServiceQueue{end+1}.precallback=checkObj.PreCallbackHandle;
                ServiceQueue{end}.postcallback=checkObj.PostCallbackHandle;
                ServiceQueue{end}.success=success;
                ServiceQueue{end}.message=message;
            end
        end

        function ServiceQueue=PopService(ServiceQueue,system)
            for i=length(ServiceQueue):-1:1
                if ServiceQueue{i}.success&&~isempty(ServiceQueue{i}.postcallback)
                    message='';
                    try
                        if nargout(ServiceQueue{i}.postcallback)==1
                            success=ServiceQueue{i}.postcallback(system);
                        else
                            [success,message]=ServiceQueue{i}.postcallback(system);
                        end
                    catch E
                        success=false;
                        message=E.message;
                        disp(message);
                    end
                    ServiceQueue{i}.postsuccess=success;
                    ServiceQueue{i}.postmessage=message;
                end
            end

            function handleEqual=loc_compare_functionHandle(func1,func2)
                func1Info=functions(func1);
                func2Info=functions(func2);
                if strcmp(func1Info.function,func2Info.function)&&strcmp(func1Info.file,func2Info.file)
                    handleEqual=true;
                else
                    handleEqual=false;
                end
















