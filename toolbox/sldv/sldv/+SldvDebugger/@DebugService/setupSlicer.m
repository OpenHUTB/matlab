






function setupSlicer(obj,SID,objectiveId)


    progressBar=Sldv.Utils.ScopedProgressIndicator('Sldv:DebugUsingSlicer:ProgressIndicatorSettingUp');
    cleanupObj=onCleanup(@()delete(progressBar));


    obj.isSldvAnalysisHighlightActive=obj.getSldvModelHighlightStatus;

    assert(length(objectiveId)==1);


    if obj.isExtractionWorkflow

        extractedModelName=obj.sldvData.ModelInformation.ExtractedModel;
        if~exist(extractedModelName)
            msgId='Sldv:DebugUsingSlicer:ExtractionModelNotFound';
            msgstr=getString(message(msgId,obj.model));
            ex=MException(msgId,'%s',msgstr);
            modelslicerprivate('MessageHandler','open',obj.designMdl);
            modelslicerprivate('MessageHandler','error',ex);
            return;
        end
        open_system(extractedModelName);
        SID=obj.updateSIDForExtractionReplacementWorkflow(SID);
    end


    obj.DebugCtx.curObjId=objectiveId;

    handles=Simulink.ID.getHandle(SID);
    if iscell(handles)

        handles=cell2mat(handles);
    end
    SID=string(Simulink.ID.getSID(handles));
    SID=SlicerApplication.DebugService.updateSidForStateflowObjects(SID);
    obj.DebugCtx.curBlkSid=SID;




    if~get_param(obj.model,'ModelSlicerActive')
        obj.backUpModelParameters;




        fundamentalSampleTime=sldvshareprivate('mdl_derive_sampletime_for_sldvdata',obj.sldvData.AnalysisInformation.SampleTimes);
        obj.DebugCtx.setStepSize(fundamentalSampleTime)

        obj.DebugCtx.preInitModelSetup;
    end

    progressBar.updateTitle(obj.getProgressIndicatorToLoadTestCase);

    obj.stopCurrentSim;


    simInputValues=getSimulationInputValues(obj,objectiveId);
    obj.DebugCtx.loadSimInputValues(simInputValues,obj.getTimeOfObservation);

    progressBar.updateTitle('Sldv:DebugUsingSlicer:ProgressIndicatorConfigureSlicer');
    try

        dlgSrc=obj.setupSlicerDialog;
    catch Mex
        rethrow(Mex);
    end

    if isempty(dlgSrc)
        return;
    end

    progressBar.updateTitle('Sldv:DebugUsingSlicer:ProgressIndicatorAddStartingPoint');
    slicerConfig=dlgSrc.Model;

    slicerConfig.unhighlightCriteria();
    obj.setupSlicerConfiguration(dlgSrc,objectiveId)

    progressBar.updateTitle(obj.getProgressIndicatorStepToTime);


    timeOfObservation=obj.getTimeOfObservation;


    try
        obj.simulateForCoverage(timeOfObservation);
    catch ex
        obj.closeSlicer;
        Mex=MException('Sldv:DebugUsingSlicer:modelSimFailure',...
        getString(message('Sldv:DebugUsingSlicer:modelSimFailure')));
        Mex=Mex.addCause(ex);
        modelslicerprivate('MessageHandler','open',obj.designMdl);
        modelslicerprivate('MessageHandler','error',Mex);
        return;
    end

    if obj.isFastRestartSupported

        obj.simAndPause(timeOfObservation);
    end

    for i=1:length(slicerConfig.allDisplayed)
        idx=slicerConfig.allDisplayed(i);
        slicerConfig.sliceCriteria(idx).refresh;
    end


    notify(obj,'eventSetupComplete');


    obj.switchToSimulationTab;

    obj.displayBannerMessage;


    obj.setIsDebugSessionActive(true);
end