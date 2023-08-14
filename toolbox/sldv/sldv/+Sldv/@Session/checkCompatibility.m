














function[status,newModelH,msg,fullCovAlreadyAchieved,sldvData]=checkCompatibility(obj,...
    filterExistingCov,reuseTranslationCache,customEnhancedMCDCOpts,standaloneCompat)

    newModelH=[];
    msg='';
    fullCovAlreadyAchieved=false;
    sldvData=[];

    if nargin<2
        filterExistingCov=true;
    end

    if nargin<3
        reuseTranslationCache=true;
    end

    if nargin<4
        customEnhancedMCDCOpts=[];
    end

    if nargin==5
        obj.mStandaloneCompat=standaloneCompat;
    end

    if(isempty(obj.mModelH))
        status=false;
        return;
    end


    [~,~,errMsg]=Simulink.observer.internal.loadObserverModelsForBD(obj.mModelH);
    if~isempty(errMsg)
        status=false;
        msg=errMsg;
        obj.reportError('Sldv:Observer:CtxMdlAlreadyOpenInAnotherContext',msg);
        return;
    end


    slOutputStage=...
    Simulink.output.Stage(message('Sldv:Setup:SLDV_COMPAT_STAGE_NAME').getString(),...
    'ModelName',get_param(obj.mModelH,'Name'),'UIMode',obj.mShowUI);%#ok<NASGU>



    status=~((Sldv.SessionState.None==obj.mState)||...
    (Sldv.SessionState.Terminated==obj.mState));
    if~status

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

    testComp=obj.mTestComp;


    [~,msg]=sldvprivate('checkSldvOptions',testComp.activeSettings,...
    true,obj.mModelH,obj.mBlockH,obj.mShowUI);
    if~isempty(msg)
        obj.reportError('Sldv:Setup:Options',msg);
        obj.resetTestComponent(obj.mModelH,obj.mBlockH,obj.mSldvOpts);
        return;
    end



    obj.mSldvToken.setTestComponent(testComp);

    if obj.mShowUI
        compatibilityUI=true;
        sldvprivate('sldvCreateUI',obj.mModelH,testComp,compatibilityUI,...
        get_param(obj.mModelH,'Name'));
    end


    testComp.profileStage('Design Verifier: Preprocessing');
    testComp.getMainProfileLogger().openPhase('Design Verifier: Preprocessing');




    csLock=Sldv.ConfigSetLock(obj.mModelH);%#ok<NASGU>



    obj.logSetupData;

    try
        sldvTranslator=Sldv.Translator(obj.mModelH,...
        obj.mBlockH,...
        obj.mSldvOpts,...
        obj.mShowUI,...
        obj.mInitCovData,...
        testComp,...
        filterExistingCov,...
        reuseTranslationCache,...
        customEnhancedMCDCOpts);


        if nargout>4
            [status,msg,fullCovAlreadyAchieved,sldvData]=sldvTranslator.translate();
        else
            [status,msg,fullCovAlreadyAchieved]=sldvTranslator.translate();
        end

    catch MEx
        if~isvalid(obj)

            MEx=MException('Sldv:Session:invalidObj',...
            'SLDV Session is no longer valid');
            throw(MEx);
        end
        testComp.profileStage('end');
        testComp.getMainProfileLogger.closePhase('Design Verifier: Preprocessing');

        obj.resetTestComponent(obj.mModelH,obj.mBlockH,obj.mSldvOpts);
        rethrow(MEx);
    end

    if isstruct(msg)&&isfield(msg,'msgid')







        obj.logDiagnostics(sldvTranslator.getAnalysisPhase(),msg);
    end


    if obj.mShowUI
        testComp.progressUI.finalized=true;
        testComp.progressUI.refreshLogArea();
    end



    if true==status||strcmp(testComp.compatStatus,'DV_COMPAT_PARTIALLY_SUPPORTED')
        obj.mState=Sldv.SessionState.MdlCompSuccess;
    else
        obj.mState=Sldv.SessionState.MdlCompFailure;
        testComp.profileStage('end');
        testComp.getMainProfileLogger.closePhase('Design Verifier: Preprocessing');


        if~Sldv.utils.Options.isTestgenTargetForModel(obj.mTestComp.activeSettings)
            obj.deleteATSHarness();
        end

        obj.resetTestComponent(obj.mModelH,obj.mBlockH,obj.mSldvOpts);
        return;
    end

    if testComp.analysisInfo.designModelH~=...
        testComp.analysisInfo.extractedModelH
        newModelH=testComp.analysisInfo.extractedModelH;
    end

    testComp.profileStage('end');
    testComp.getMainProfileLogger.closePhase('Design Verifier: Preprocessing');

    return;
end
