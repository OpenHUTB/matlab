








function[status,msg]=initAnalysis(obj)
    try

        assert(Sldv.AnalysisStatus.Init~=obj.mAnalysisStatus);


        assert(~strcmp(obj.mTestComp.analysisStatus,'In progress'));

        testComp=obj.mTestComp;

        msg=[];
        testComp.profileStage('Design Verifier: Analysis');
        testComp.getMainProfileLogger().openPhase('Design Verifier: Analysis');






        obj.mAnalysisStatus=Sldv.AnalysisStatus.WaitingForInit;












        toTerminate=init(testComp.analysisInfo.analyzedModelH,testComp.analysisInfo.designModelH);


        obj.clearResults();


        testComp.printCBFcn=@slavteng_print_callback;
        testComp.resultsCBFcn=@slavteng_result_callback;
        testComp.progressCBFcn=@slavteng_activity_callback;
        testComp.progressPeriod=500;


        if slavteng('feature','IncrementalHighlighting')
            session=sldvprivate('sldvGetActiveSession',obj.mModelH);
            session.HighlightStatusFlag=true;
        end


        if obj.mShowUI&&(isempty(testComp.progressUI)||~ishandle(testComp.progressUI))
            hideAnalysisPannel=false;
            sldvprivate('sldvCreateUI',obj.mModelH,testComp,hideAnalysisPannel,get_param(obj.mModelH,'Name'));
        end


        blocks=sldvprivate('sldv_datamodel_get_modelobjects',testComp);
        if isempty(blocks)

            testComp.createAnalysisContext();
        end


        sldvprivate('naive_objective_selection',testComp);

        [msg,status]=evalc('testComp.emitDvo()');
        if~status
            obj.logAll(sprintf('%s',msg));
            obj.logAll(sprintf('\n\n'));
            return;
        end


        obj.verifyTestObjectives();


        [obj.mStrategy,obj.mSearchDepth,obj.mTimeLimit]=sldvprivate('mdl_get_analysis_settings',testComp);
        strategyName=sldvprivate('sldv_get_strategy_name',testComp);

        if(strcmp(strategyName,'FxpRangeComputation')...
            ||(testComp.recordDvirSim)...
            )
            slfeature('SldvTaskingArchitecture',0);
        end



        if(sldvprivate("isTaskingArchitectureEnabled"))
            obj.mTaskQueue=dv.tasking.TaskQueue();
            obj.mResultStream=dv.tasking.ResultStream();
        end
        analyzerObj=obj;





        opts=testComp.activeSettings;
        if strcmp(opts.Mode,'DesignErrorDetection')&&...
            strcmp(opts.DetectSubnormal,'on')
            slavteng('feature','BitPreciseAnalysis',1);
            slavteng('feature','FloatPtOvf',1);
            slavteng('feature','SubnormalChk',1);
        elseif strcmp(opts.Mode,'DesignErrorDetection')&&...
            (strcmp(opts.DetectInfNaN,'on')||strcmp(opts.DetectBlockInputRangeViolations,'on'))
            slavteng('feature','BitPreciseAnalysis',1);
            slavteng('feature','FloatPtOvf',1);
            slavteng('feature','SubnormalChk',0);
        elseif strcmp(opts.ReduceRationalApprox,'on')
            slavteng('feature','BitPreciseAnalysis',1);
            slavteng('feature','FloatPtOvf',0);
            slavteng('feature','SubnormalChk',0);
        else
            slavteng('feature','BitPreciseAnalysis',0);
            slavteng('feature','FloatPtOvf',0);
            slavteng('feature','SubnormalChk',0);
        end


        testComp.initAnalysis(obj.mTimeLimit,analyzerObj);

        testComp.analysisInfo.erroredObjectivesInfo=...
        containers.Map('KeyType','double','ValueType','any');

        testComp.analysisInfo.hasNotInterpretableStubbedElem=testComp.hasNonIntrinsicStub();

        testComp.analysisInfo.analysisTime=containers.Map('KeyType','double','ValueType','any');


        jnk=[];
        slavteng_activity_callback(testComp,jnk);


        obj.logCompatTimestamp();


        testComp.analysisStatus='In progress';
        if obj.mShowUI

            analysisInProgress=true;
            testComp.progressUI.setAnalysisStatus(analysisInProgress);

            testComp.progressUI.setElapsedTimerMode(analysisInProgress);

            testComp.progressUI.refreshLogArea();
        end





        testComp.activeSettings=obj.deepCopyAnalysisOptions();


        obj.cacheEnabledGoals();


        obj.cacheStaticSldvData();


        obj.initializeDefaultsAtUnusedInports();

        if toTerminate
            runEvalcCommand(testComp.analysisInfo.analyzedModelH,'term');
        end






        if testComp.analysisInfo.analyzedModelH~=testComp.analysisInfo.designModelH
            Sldv.utils.switchObsMdlsToStandaloneMode(testComp.analysisInfo.analyzedModelH);
        end


        Sldv.utils.getBusObjectFromName(-1);


        obj.mAnalysisStatus=Sldv.AnalysisStatus.Init;
        obj.mAnalysisErrorMsg=[];



        notify(obj,'AnalysisInit');
    catch MExc
        runEvalcCommand(testComp.analysisInfo.analyzedModelH,'term');
        Sldv.utils.switchObsMdlsToStandaloneMode(testComp.analysisInfo.analyzedModelH);
        status=0;

        extraInfoAboutErr=MExc.message;
        if strcmp(MExc.identifier,'Simulink:Commands:InvSimulinkObjHandle')
            extraInfoAboutErr=[extraInfoAboutErr,'.',newline,getString(message('Sldv:SldvRun:SelfModifyingMask'))];
        end

        msg=[getString(message('Sldv:SldvRun:ErrorInitAnalysis'))...
        ,': '...
        ,extraInfoAboutErr];
    end
end


function toTerminate=init(analysisModelH,designModelH)
    simStatus=get_param(analysisModelH,'SimulationStatus');
    isCompiled=strcmp(simStatus,'paused')||strcmp(simStatus,'initializing');
    toTerminate=false;
    if~isCompiled
        try
            if analysisModelH~=designModelH









                Sldv.utils.switchObsMdlsToStandaloneMode(analysisModelH);
            end
            runEvalcCommand(analysisModelH,'compile');
            toTerminate=true;
        catch MEx
            toTerminate=false;
        end
    end
end

function runEvalcCommand(ModelH,command)

    [prevMsg,prevMsgID]=lastwarn;
    warnStruct=warning;
    warning('off');
    oc1=onCleanup(@()warning(warnStruct));
    oc2=onCleanup(@()lastwarn(prevMsg,prevMsgID));


    evalc(sprintf('%s([], [], [], ''%s'')',get_param(ModelH,'Name'),command));
end
