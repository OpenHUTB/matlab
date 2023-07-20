



function[status,msg]=launchAnalysis(obj)

    assert(~isempty(obj.mTestComp));
    assert(~isempty(obj.mModelH));

    testComp=obj.mTestComp;


    assert(isempty(obj.mSLOutputStage));
    obj.mSLOutputStage=[];
    if(strcmp('TestGeneration',obj.mSldvOpts.Mode))
        obj.mSLOutputStage=Simulink.output.Stage(message('Sldv:SldvRun:SLDV_RUN_TEST_GENERATION_STAGE_NAME').getString(),...
        'ModelName',get_param(obj.mModelH,'Name'),'UIMode',obj.mShowUI);
    elseif(strcmp('DesignErrorDetection',obj.mSldvOpts.Mode))
        obj.mSLOutputStage=Simulink.output.Stage(message('Sldv:SldvRun:SLDV_RUN_DESIGN_ERROR_DETECTION_STAGE_NAME').getString(),...
        'ModelName',get_param(obj.mModelH,'Name'),'UIMode',obj.mShowUI);
    elseif(strcmp('PropertyProving',obj.mSldvOpts.Mode))
        obj.mSLOutputStage=Simulink.output.Stage(message('Sldv:SldvRun:SLDV_RUN_PROPERTY_PROVING_STAGE_NAME').getString(),...
        'ModelName',get_param(obj.mModelH,'Name'),'UIMode',obj.mShowUI);
    end

    statusToken=obj.acquireSldvToken();
    if~statusToken
        status=0;
        msg=getString(message('Sldv:SldvRun:OnlyOneAnalysis'));
        obj.reportError('Sldv:SldvRun:OnlyOneAnalysis',msg);
        return;
    end


    cleanup=onCleanup(@()cleanupLanucnhAnalysis(obj));


    [~,msg]=sldvprivate('checkSldvOptions',testComp.activeSettings,...
    false,obj.mModelH,obj.mBlockH,obj.mShowUI);
    if~isempty(msg)
        status=0;
        obj.reportError('Sldv:SldvRun:Options',msg);
        obj.releaseSldvToken();
        return;
    end

    [status,msg]=obj.setupAnalysis();
    if~status
        if isstruct(msg)&&isfield(msg,'msgid')




            obj.logDiagnostics(Sldv.AnalysisPhase.Analysis,msg);
        end
        obj.releaseSldvToken();
        return;
    end


    addlistener(obj.mTaskManager,'Done',@(~,~)obj.onAsyncAnalysisTasksDone());
    addlistener(obj.mTaskManager,'Terminate',@(~,~)obj.onAsyncAnalysisTasksTerminate());



    if slavteng('feature','ProximityTableCal')==0||slavteng('feature','ProximityTableCal')==2

        obj.mTaskManager.runAsync();
    end



    obj.lockConfigSet();

    [status,msg]=obj.mSldvAnalyzer.initAnalysis();
    if~status
        if~isempty(msg)
            obj.reportError('Sldv:SldvRun:ErrorInitAnalysis',msg);
        end
        obj.mTaskManager.terminate('DV_CAUSE_INTERRUPTED');
        obj.mState=Sldv.SessionState.AnalysisFailure;
        return;
    end



    if slavteng('feature','ProximityTableCal')==1&&(strcmp('TestGeneration',obj.mSldvOpts.Mode))
        obj.mTestComp.profileStage('SequentialProximityTableCalc');
        obj.mTestComp.getMainProfileLogger().openPhase('SequentialProximityTableCalc');

        [sldvData,~,~,~,goalIdToDvIdMap]=obj.mSldvAnalyzer.getStaticSldvData();
        proximityDataGenerator=Sldv.Analysis.ProximityData.ProximityDataGenerator(sldvData,goalIdToDvIdMap);
        undecidedObjs=1:length(sldvData.Objectives);
        try
            obj.mTestComp.profileStage('QuickProximityCheck');
            obj.mTestComp.getMainProfileLogger().openPhase('QuickProximityCheck');
            canRunProximity=false;
            try
                canRunProximity=proximityDataGenerator.canRunProximity();
            catch

            end
            obj.mTestComp.profileStage('end');
            obj.mTestComp.getMainProfileLogger().closePhase('QuickProximityCheck');

            if canRunProximity
                proximityDataGenerator.run(undecidedObjs);
            end
        catch MEx

        end
        outputDir=sldvprivate('mdl_get_output_dir',obj.mTestComp);
        [status,obj.mProximityDataFile,obj.mProximityDataReadyFile]=proximityDataGenerator.saveProximityData('proximitydata',outputDir);

        obj.mTestComp.profileStage('end');
        obj.mTestComp.getMainProfileLogger().closePhase('SequentialProximityTableCalc');
    end

    if slavteng('feature','ProximityTableCal')==1

        obj.mTaskManager.runAsync();
    end



    obj.mState=Sldv.SessionState.AsyncAnalysisRunning;


    assert(true==obj.isSldvTokenInUse());

    obj.notify('AsyncAnalysisLaunched');



    obj.toggleHighlighting(true);

end

function cleanupLanucnhAnalysis(obj)
    if obj.mState~=Sldv.SessionState.AsyncAnalysisRunning
        obj.releaseSldvToken();
    end
end


