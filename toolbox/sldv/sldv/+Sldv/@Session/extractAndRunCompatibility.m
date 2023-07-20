function[status,newModelH,errStr,fullCovAlreadyAchieved,resultFileNames]=extractAndRunCompatibility(obj,preExtract,customEnhancedMCDCOpts)





    if nargin<3
        customEnhancedMCDCOpts=[];
    end

    newModelH=[];
    errStr='';
    fullCovAlreadyAchieved=false;
    resultFileNames=Sldv.Utils.initDVResultStruct();


    if(~isempty(obj.mModelH))
        sldv_compat_stage=Simulink.output.Stage(message('Sldv:Setup:SLDV_COMPAT_STAGE_NAME').getString(),...
        'ModelName',get_param(obj.mModelH,'Name'),'UIMode',obj.mShowUI);%#ok<NASGU>
    end



    status=~((obj.mState==Sldv.SessionState.None)||...
    (obj.mState==Sldv.SessionState.Terminated));
    if~status

        return;
    end




    [~,~,errMsg]=Simulink.observer.internal.loadObserverModelsForBD(obj.mModelH);
    if~isempty(errMsg)
        status=false;
        msg=errMsg;
        obj.reportError('Sldv:Observer:CtxMdlAlreadyOpenInAnotherContext',msg);
        return;
    end



    status=obj.acquireSldvToken();
    if~status
        msg=getString(message('Sldv:Setup:OnlyOneAnalysisRun'));
        obj.reportError('Sldv:Setup:MultipleAnalysis',msg);
        return;
    end


    tokenCleanup=onCleanup(@()obj.cleanupCompatibility());


    obj.mState=Sldv.SessionState.CompatibilityRunning;


    [status,msg]=obj.resetTestComponent(obj.mModelH,obj.mBlockH,obj.mSldvOpts);
    if~status
        obj.reportError('Sldv:Setup:TestComp',msg);
        obj.resetTestComponent(obj.mModelH,obj.mBlockH,obj.mSldvOpts);
        return;
    end


    [status,errStr]=sldvprivate('checkSldvOptions',obj.mTestComp.activeSettings,...
    false,...
    obj.mModelH,...
    obj.mBlockH,...
    obj.mShowUI);
    if~isempty(errStr)
        obj.reportError('Sldv:SldvRun:Options',errStr);
        obj.resetTestComponent(obj.mModelH,obj.mBlockH,obj.mSldvOpts);
        return;
    end




    obj.mSldvToken.setTestComponent(obj.mTestComp);

    if obj.mShowUI
        sldvprivate('sldvCreateUI',obj.mModelH,obj.mTestComp,true,get_param(obj.mModelH,'Name'));
    end


    obj.mTestComp.profileStage('Design Verifier: Preprocessing');
    obj.mTestComp.getMainProfileLogger().openPhase('Design Verifier: Preprocessing');




    csLock=Sldv.ConfigSetLock(obj.mModelH);%#ok<NASGU>



    obj.logSetupData;

    modelH=obj.mModelH;

    blockH=obj.mBlockH;
    if~isempty(obj.mBlockH)&&~isempty(preExtract)




        extractedModelH=preExtract.extractH;
        AtomicSubChartWithParam=preExtract.AtomicSubChartWithParam;



        Sldv.SubSystemExtractBatch.setTestComp(extractedModelH,obj.mBlockH,AtomicSubChartWithParam);

        obj.logNewLines(getString(message('Sldv:SldvRun:NewModelFile',resultFileNames.ExtractedModel)));
        [solverChanged,errStr]=...
        Sldv.SubSystemExtract.createForcessDiscreteMsg(extractedModelH,obj.mModelH);
        if solverChanged
            obj.logAll(sprintf('%s\n',errStr));
        end
        modelH=obj.mTestComp.analysisInfo.analyzedModelH;
        blockH=[];
    end


    try
        stopped=obj.handleStopRequest('Sldv:Setup:DesignVerifierStopped');
        if stopped
            status=0;
            obj.mState=Sldv.SessionState.MdlCompFailure;
            obj.mTestComp.profileStage('end');
            obj.mTestComp.getMainProfileLogger.closePhase('Design Verifier: Preprocessing');
            obj.resetTestComponent(obj.mModelH,obj.mBlockH,obj.mSldvOpts);
            return;
        end
    catch MEx

        rethrow(MEx);
    end




    try
        filterExistingCov=true;
        reuseTranslationCache=true;
        sldvTranslator=Sldv.Translator(modelH,...
        blockH,...
        obj.mSldvOpts,...
        obj.mShowUI,...
        obj.mInitCovData,...
        obj.mTestComp,...
        filterExistingCov,...
        reuseTranslationCache,...
        customEnhancedMCDCOpts);

        [status,errStr,fullCovAlreadyAchieved]=sldvTranslator.translate();
    catch MEx
        if~isvalid(obj)

            MEx=MException('Sldv:Session:invalidObj',...
            'SLDV Session is no longer valid');
            throw(MEx);
        end
        rethrow(MEx);
    end

    if isstruct(errStr)&&isfield(errStr,'msgid')







        obj.logDiagnostics(sldvTranslator.getAnalysisPhase(),errStr);
    end

    if sldvTranslator.hasExtractionFailed()
        assert(false==status);















        if isempty(obj.mBlockH)
            cutH=obj.mModelH;
        else
            cutH=obj.mBlockH;
        end
        extractionFailedMsg.objH=cutH;
        blockName=get_param(cutH,'Name');
        blockName=strrep(blockName,newline,' ');
        extractionFailedMsg.source=blockName;
        extractionFailedMsg.sourceFullName=getfullname(obj.mBlockH);
        extractionFailedMsg.reportedBy='sldv';
        extractionFailedMsg.msg=getString(message('Sldv:Setup:ErrorExtractCUT',blockName));
        extractionFailedMsg.msgid='Sldv:EXTRACT:Failed';
        errStr=[extractionFailedMsg,errStr];

        obj.mState=Sldv.SessionState.MdlCompFailure;
        obj.mTestComp.profileStage('end');
        obj.mTestComp.getMainProfileLogger.closePhase('Design Verifier: Preprocessing');
        obj.resetTestComponent(obj.mModelH,obj.mBlockH,obj.mSldvOpts);
        return;
    end


    if~isempty(obj.mBlockH)
        if isempty(preExtract)
            resultFileNames.ExtractedModel=get_param(obj.mTestComp.analysisInfo.extractedModelH,'FileName');
        else
            resultFileNames.ExtractedModel=get_param(extractedModelH,'FileName');
        end
    end

    if obj.mTestComp.analysisInfo.blockDiagramExtract
        resultFileNames.ExtractedModel=get_param(obj.mTestComp.analysisInfo.extractedModelH,'FileName');
    end


    if obj.mShowUI
        obj.mTestComp.progressUI.finalized=true;
        obj.mTestComp.progressUI.refreshLogArea();
    end



    if true==status||strcmp(obj.mTestComp.compatStatus,'DV_COMPAT_PARTIALLY_SUPPORTED')
        obj.mState=Sldv.SessionState.MdlCompSuccess;
    else
        obj.mState=Sldv.SessionState.MdlCompFailure;
        obj.mTestComp.profileStage('end');
        obj.mTestComp.getMainProfileLogger.closePhase('Design Verifier: Preprocessing');


        if~Sldv.utils.Options.isTestgenTargetForModel(obj.mTestComp.activeSettings)
            obj.deleteATSHarness();
        end

        obj.resetTestComponent(obj.mModelH,obj.mBlockH,obj.mSldvOpts);
        return;
    end

    if obj.mTestComp.analysisInfo.designModelH~=...
        obj.mTestComp.analysisInfo.extractedModelH
        newModelH=obj.mTestComp.analysisInfo.extractedModelH;
    end

    if obj.mTestComp.analysisInfo.analyzedModelH~=obj.mTestComp.analysisInfo.designModelH
        sldvprivate('mdl_set_resolved_settings',obj.mTestComp,...
        'ExtractedModelFileName',...
        resultFileNames.ExtractedModel);
    end

    [replacedModelH,resultFileNames]=sldvprivate('resolve_blockreplacement_handle',obj.mTestComp.analysisInfo.analyzedModelH,...
    obj.mTestComp,...
    resultFileNames);

    obj.mTestComp.analysisInfo.analyzedModelH=replacedModelH;

    obj.mTestComp.profileStage('end');
    obj.mTestComp.getMainProfileLogger.closePhase('Design Verifier: Preprocessing');


    return;

end


