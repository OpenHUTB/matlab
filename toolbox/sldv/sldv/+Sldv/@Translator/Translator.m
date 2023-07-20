




classdef Translator<handle

    properties(Access=private)

mSuccessStatus
mErrorMsg
mfullCovAlreadyAcheived


mRootModelH
mBlockH
mCacheFileName
mCacheDirFullPath
mOptions
mShowUI
mStartCov
mTestComp
        mCompatDataInfo Sldv.CompatDataInfo
mCustomEnhancedMCDCOpts


        mCompatStatus Sldv.CompatStatus
mFilterExistingCov
mIsXIL
mExtractedModelH
mModelToCheckCompatH
mModelToCheckCompatName
mModelToReportCompatibilityName
mSettingsCache
mBlkHs
mBlkTypes
mStartupBlkHs
mStartupParams
mStubsfcns
mCompatObserverModelHs
mIsTranslatorForComponent



mSID_2_Blk_Hdl_ID
mBlk_Hdl_SfId_2_SID


mInterceptorScopeDefiner


mTranslationState
mSkipTranslation
mReuseTranslationCache
mCompatibilityData


mAnalysisPhase






mExtractionFailed






        mCacheHandler Sldv.Compatibility.CacheHandler
    end


    methods(Access=private)
        function status=initialize(obj)





            testgenTarget=obj.mOptions.TestGenTarget;
            modelBasedTestGen=strcmp(testgenTarget,'Model');
            parameterConfigSetting=obj.mOptions.ParameterConfiguration;














            if modelBasedTestGen||...
                strcmp(parameterConfigSetting,'UseParameterTable')||...
                strcmp(parameterConfigSetting,'UseParameterConfigFile')
                sldvshareprivate('parameters','setParameterConfiguration',...
                obj.mModelToCheckCompatH,obj.mStartupParams,obj.mStartupBlkHs);
            end




            if sldvprivate('isReuseTranslationON',obj.mTestComp.activeSettings)
                obj.readTranslationDataFromCache();
            end



            logMsgID='readTranslationDataFromCache';
            logMsg=sprintf(':mReuseTranslationCache:Value:%s',string(obj.mReuseTranslationCache));
            obj.logReuseTranslationMessages(logMsgID,logMsg);





            if ispc()
                isPathLenError=obj.checkWindowsPathLengthViolations();
                if isPathLenError


                    sldvshareprivate('avtcgirunsupcollect','push',obj.mRootModelH,...
                    'sldv_warning',getString(message('Sldv:Setup:LongPathLength')),...
                    'Sldv:Setup:LongPathLength');
                    obj.clearDiagnosticInterceptor();
                    obj.mErrorMsg=sldvshareprivate('avtcgirunsupdialog',obj.mRootModelH);
                    obj.setDiagnosticInterceptor();
                end
            end



            simStatus=get_param(obj.mRootModelH,'SimulationStatus');
            if~strcmpi(simStatus,'stopped')
                obj.mCompatStatus=Sldv.CompatStatus.DV_COMPAT_INCOMPATIBLE;
                modelName=get_param(obj.mRootModelH,'Name');
                msg=getString(message('Sldv:Compatibility:UnsupportedSimulationMode',modelName));
                sldvshareprivate('avtcgirunsupcollect','push',obj.mRootModelH,'sldv',msg,'Sldv:Compatibility:UnsupportedSimulationMode');
                obj.clearDiagnosticInterceptor();
                obj.mErrorMsg=sldvshareprivate('avtcgirunsupdialog',obj.mRootModelH);
                obj.setDiagnosticInterceptor();
                status=false;
                return;
            end

            status=true;





            obj.mAnalysisPhase=Sldv.AnalysisPhase.Extraction;


            obj.mTestComp.profileStage('Extraction');
            obj.mTestComp.getMainProfileLogger().openPhase('Extraction');

            status=status&&obj.extractExportFcnModel();




            status=status&&obj.extractSubsystem();





            if slfeature('SLDVAutosarBSWCallersSupport')
                status=status&&obj.extractSLFunctionServices();
            end


            obj.mTestComp.profileStage('end');
            obj.mTestComp.getMainProfileLogger().closePhase('Extraction');

            if~status&&obj.mShowUI
                obj.mTestComp.progressUI.finalized=true;
                obj.mTestComp.progressUI.refreshLogArea;
            end
            if~status||obj.checkForUserStopRequest()
                obj.setOutputOnAbnormalTermination();
                status=false;
                return;
            end

            obj.mAnalysisPhase=Sldv.AnalysisPhase.Compatibility;




            try
                status=obj.resolveSettings();
            catch Mex


                rethrow(Mex);
            end

            status=obj.addSldvOutputsFolderToPath(status);

            if~status||obj.checkForUserStopRequest()
                obj.setOutputOnAbnormalTermination();
                status=false;
                return;
            end












            status=obj.checkWorkSpaceAccess();
            if~status||obj.checkForUserStopRequest()
                obj.setOutputOnAbnormalTermination();
                status=false;
                return;
            end





            if~obj.mSkipTranslation&&...
                Sldv.CompatStatus.DV_COMPAT_INCOMPATIBLE~=obj.mCompatStatus
                obj.mCompatStatus=Sldv.CompatStatus.DV_COMPAT_UNKNOWN;
                compatStatus=sldvprivate('mdl_check_hardware_consistency',...
                obj.mExtractedModelH,obj.mCompatStatus.char);
                obj.mCompatStatus=Sldv.CompatStatus(compatStatus);
            end



            if~obj.mSkipTranslation
                obj.logSome(sprintf('\n%s',datestr(now)));
            end

            obj.mAnalysisPhase=Sldv.AnalysisPhase.BlockReplacement;



            obj.mTestComp.profileStage('BlockReplacement');
            obj.mTestComp.getMainProfileLogger().openPhase('BlockReplacement');

            status=obj.executeBlockReplacements();


            obj.mTestComp.profileStage('end');
            obj.mTestComp.getMainProfileLogger().closePhase('BlockReplacement');

            if~status||obj.checkForUserStopRequest()
                obj.setOutputOnAbnormalTermination();
                status=false;
                return;
            else

                obj.mAnalysisPhase=Sldv.AnalysisPhase.Compatibility;
                if~obj.mSkipTranslation
                    switch obj.mTestComp.activeSettings.Mode
                    case 'TestGeneration'
                        actMsg=getString(message('Sldv:Setup:CheckingTestGenerationCompatibility'));
                    case 'DesignErrorDetection'
                        actMsg=getString(message('Sldv:Setup:CheckingDesignErrorDetectionCompatibility'));
                    case 'PropertyProving'
                        actMsg=getString(message('Sldv:Setup:CheckingPropertyProvingCompatibility'));
                    otherwise
                        InUse=false;%#ok<NASGU>
                        error(message('Sldv:Setup:UnknownActivity'));
                    end
                    if obj.mTestComp.activeSettings.RequirementsTableAnalysis=="on"
                        actMsg=getString(message('Sldv:Setup:CheckingReqTableCompatibility'));
                    end
                    if obj.mIsXIL&&~isempty(obj.mTestComp.analysisInfo.analyzedSubsystemH)
                        obj.logAll(sprintf('\n%s ''%s''\n',actMsg,...
                        getfullname(obj.mTestComp.analysisInfo.analyzedSubsystemH)));
                    else
                        obj.logAll(sprintf('\n%s ''%s''\n',actMsg,obj.mModelToReportCompatibilityName));
                    end
                end
            end



            if~obj.mSkipTranslation
                analysisModelH=obj.mTestComp.analysisInfo.analyzedModelH;
                designModelH=obj.mTestComp.analysisInfo.designModelH;






                if~isequal(designModelH,analysisModelH)
                    try
                        save_system(analysisModelH);
                    catch
                    end
                end
            end







            obj.getObserverModelHs(obj.mModelToCheckCompatH);

            [obj.mBlkHs,obj.mBlkTypes]=obj.getBlockHsAndBlockTypes(obj.mModelToCheckCompatH);

            obj.mStartupBlkHs=obj.getStartupVariantBlkHs();

            obj.mStartupParams=obj.getStartupVariantParams();






            sldvprivate('initializeCovMapForIteratorBlocks',obj.mBlkHs,obj.mBlkTypes,obj.mTestComp);


            obj.mTestComp.verifSubsys=sldvprivate('getAllVerificationSubsystems',obj.mBlkHs,obj.mBlkTypes);

            if(Sldv.CompatStatus.DV_COMPAT_INCOMPATIBLE~=obj.mCompatStatus)

                sldvshareprivate('avtcgirunsupcollect','clear');

                status=obj.blockCompatibilityChecks();
            end

            if~status||obj.checkForUserStopRequest()
                obj.setOutputOnAbnormalTermination();
                status=false;
                return;
            end




            obj.setUpXILMode();

            if Sldv.CompatStatus.DV_COMPAT_INCOMPATIBLE~=obj.mCompatStatus
                status=sldvshareprivate('parameters','setParameterConfiguration',...
                obj.mModelToCheckCompatH,obj.mStartupParams,obj.mStartupBlkHs);
            else


                status=false;
            end
            if~status
                obj.reportInitErrors();
            end

            if~status||obj.checkForUserStopRequest()
                obj.setOutputOnAbnormalTermination();
                status=false;
                return;
            end
        end

        function postTranslation(obj)



            obj.clearDiagnosticInterceptor();






            ignoredModelNames=obj.mTestComp.deleteIgnoredDesignIRs();
            if~isempty(ignoredModelNames)
                session=sldvprivate('sldvGetActiveSession',obj.mRootModelH);
                for nameIdx=1:length(ignoredModelNames)
                    obsMdlH=get_param(ignoredModelNames{nameIdx},'handle');
                    errMsg=getString(message('Sldv:Observer:IgnoreIncompatObs',getfullname(obsMdlH)));
                    sldvshareprivate('avtcgirunsupcollect','push',obj.mRootModelH,'sldv_warning',errMsg,...
                    'Sldv:Observer:IgnoreIncompatObs');
                    session.addToIncompatObserverList(obsMdlH);
                    obj.mCompatObserverModelHs(obj.mCompatObserverModelHs==obsMdlH)=[];
                end
            end

            [status,res,obj.mErrorMsg]=obj.generateCompatibilityResults();
            obj.mSuccessStatus=status;




            sldvprivate('settings_handler',obj.mModelToCheckCompatH,...
            'restore',obj.mSettingsCache,obj.mTestComp);






            timeStamp=datestr(now);
            if obj.mSkipTranslation
                obj.mTestComp.compatTimestamp=obj.mCompatibilityData.compatTimestamp;
            else
                obj.mTestComp.compatTimestamp=timeStamp;
            end
            obj.logSome(sprintf('\n%s\n',timeStamp));






            if~obj.mSkipTranslation
                try
                    tStatus=obj.saveCompatData();
                catch
                    tStatus=false;
                end
                if~tStatus
                    obj.clearCacheDIR();
                    tMsgID='Sldv:Compatibility:CachingModelRepresentationFailed';
                    tMsg=getString(message('Sldv:Setup:CachingModelRepresentationFailed'));
                    sldvshareprivate('avtcgirunsupcollect','push',...
                    obj.mTestComp.analysisInfo.analyzedModelH,'sldv_warning',tMsg,tMsgID);
                end
            end


            wasTargetOutOfDate=~obj.mSkipTranslation||~isempty(obj.mCompatObserverModelHs);
            if sldvprivate('isReuseTranslationON',obj.mTestComp.activeSettings)&&...
                slfeature('SLDVCacheInSLXC')>0&&obj.mSuccessStatus


                [tStatus,tMsg,tMsgID]=obj.mCacheHandler.packCacheToSLXC(wasTargetOutOfDate);
                if~tStatus
                    sldvshareprivate('avtcgirunsupcollect','push',...
                    obj.mTestComp.analysisInfo.analyzedModelH,'sldv_warning',tMsg,tMsgID);
                end
            end



            obj.displayCompatibilityResults(res);








            if obj.mShowUI
                CurrOpts=obj.mTestComp.activeSettings;
                obj.mTestComp.activeSettings=CurrOpts.deepCopy;


                obj.mTestComp.activeSettings.ObservabilityCustomization=CurrOpts.ObservabilityCustomization;
                obj.mTestComp.activeSettings.DetectDSMAccessViolations=CurrOpts.DetectDSMAccessViolations;
                obj.mTestComp.activeSettings.DetectBlockInputRangeViolations=CurrOpts.DetectBlockInputRangeViolations;
            end
        end

        function compiledSldvData=saveCompatSldvData(obj)
            compiledSldvData=Sldv.DataUtils.save_compat_data(...
            obj.mTestComp.analysisInfo.analyzedModelH,obj.mTestComp,obj.mSuccessStatus);
        end
    end

    methods(Access=public)
        function[status,msg,fullCovAlreadyAcheived,sldvData]=translate(obj)
            sldvData=[];
            sldvshareprivate('avtcgirunsupcollect','clear');




            try
                status=obj.initialize();
            catch MEx



                rethrow(MEx);
            end

            if~status
                [status,msg,fullCovAlreadyAcheived]=obj.getResults();
                return;
            end










            if~obj.mSkipTranslation
                obj.genCacheDirectory();
            end




            status=obj.setInputCovDataAndFilter();
            if~status
                obj.mCompatStatus=Sldv.CompatStatus.DV_COMPAT_INCOMPATIBLE;
                obj.mTestComp.compatStatus=obj.mCompatStatus.char;
            end
            if~status||obj.checkForUserStopRequest()
                obj.setOutputOnAbnormalTermination();
                [status,msg,fullCovAlreadyAcheived]=obj.getResults();
                return;
            end



            if Sldv.CompatStatus.DV_COMPAT_INCOMPATIBLE~=obj.mCompatStatus
                if isequal(obj.mOptions.AnalyzeAllStartUpVariants,'on')
                    startupBlkHs=[];
                else
                    startupBlkHs=obj.mStartupBlkHs;
                end

                obj.mSettingsCache=sldvprivate('settings_handler',...
                obj.mModelToCheckCompatH,'store',[],obj.mTestComp,startupBlkHs);
                obj.mSettingsCache=sldvprivate('settings_handler',...
                obj.mModelToCheckCompatH,'init_coverage',obj.mSettingsCache,obj.mTestComp);
                if~obj.mSkipTranslation
                    obj.logAll(getString(message('Sldv:Setup:CompilingModel')));
                end
                obj.initCoverage();
                if~obj.mSkipTranslation
                    obj.logAll(sprintf('%s\n',getString(message('Sldv:Setup:Done'))));
                end
                if~(Sldv.CompatStatus.DV_COMPAT_INCOMPATIBLE==obj.mCompatStatus)&&obj.mFilterExistingCov
                    isFullCoverageAcheived=obj.fullCoverageAcheived;
                    if isFullCoverageAcheived
                        obj.mCompatStatus=Sldv.CompatStatus.DV_COMPAT_INCOMPATIBLE;
                        obj.mTestComp.compatStatus=obj.mCompatStatus.char;
                        obj.setOutputOnAbnormalTermination();
                        [status,msg,fullCovAlreadyAcheived]=obj.getResults();
                        sldvprivate('settings_handler',obj.mModelToCheckCompatH,...
                        'restore',obj.mSettingsCache,obj.mTestComp);
                        return;
                    end
                end
            else
                obj.mSettingsCache=[];
            end
            if obj.mSkipTranslation
                if~isempty(obj.mBlockH)
                    modelFilePath=get_param(obj.mExtractedModelH,'FileName');
                    str=getString(message('Sldv:Setup:UsingExtractedModel',modelFilePath));
                    obj.logNewLines(str);
                elseif strcmp(get_param(obj.mRootModelH,'IsExportFunctionModel'),'on')
                    modelFilePath=get_param(obj.mExtractedModelH,'FileName');
                    str=getString(message('Sldv:Setup:UsingExportFunctionModel',modelFilePath));
                    obj.logNewLines(str);
                end
            end

            if obj.checkForUserStopRequest()
                obj.setOutputOnAbnormalTermination();


                sldvprivate('settings_handler',obj.mModelToCheckCompatH,...
                'restore',obj.mSettingsCache,obj.mTestComp);
                [status,msg,fullCovAlreadyAcheived]=obj.getResults();
                return;
            end





            if Sldv.CompatStatus.DV_COMPAT_INCOMPATIBLE==obj.mCompatStatus||...
                sldvprivate('mdl_has_unsupported_items',obj.mModelToCheckCompatH)
                obj.mCompatStatus=Sldv.CompatStatus.DV_COMPAT_INCOMPATIBLE;
            else







                if~obj.mSkipTranslation
                    if strcmp(obj.mTestComp.activeSettings.Mode,'TestGeneration')
                        [~,obj.mTestComp.forcedTurnOnRelationalBoundary]=...
                        sldvprivate('createNetworkSpec',obj.mModelToCheckCompatH,...
                        obj.mTestComp,obj.mCustomEnhancedMCDCOpts);
                    else
                        obj.mTestComp.forcedTurnOnRelationalBoundary=false;
                    end
                end






                obj.mTestComp.profileStage('Translation');
                obj.mTestComp.getMainProfileLogger().openPhase('Translation');

                obj.translateAndCheckCompat();


                obj.mTestComp.profileStage('end');
                obj.mTestComp.getMainProfileLogger().closePhase('Translation');





                obj.logAll(sprintf('%s\n',getString(message('Sldv:Setup:Done'))));
            end

            if obj.mCompatStatus==Sldv.CompatStatus.DV_COMPAT_UNKNOWN
                obj.mCompatStatus=Sldv.CompatStatus.DV_COMPAT_COMPATIBLE;
                obj.mTestComp.compatStatus=obj.mCompatStatus.char;
            end




            obj.mSuccessStatus=status;
            if nargout>3
                sldvData=obj.saveCompatSldvData();
            end



            obj.postTranslation();

            if~sldvprivate('isObserverSupportON',obj.mTestComp.activeSettings)
                obsRefBlks=Simulink.observer.internal.getObserverRefBlocksInBD(obj.mModelToCheckCompatH);
                if numel(obsRefBlks)>0
                    errMsg=getString(message('Sldv:Observer:UnsupObsForDED'));
                    sldvshareprivate('avtcgirunsupcollect','push',obj.mModelToCheckCompatH,'sldv_warning',errMsg,...
                    'Sldv:Observer:UnsupObsForDED');
                end
            end

            [status,msg,fullCovAlreadyAcheived]=obj.getResults();
        end

        function[status,msg,fullCovAlreadyAcheived]=getResults(obj)
            if obj.mSuccessStatus
                status=true;
            else
                status=false;
            end


            msg=obj.mErrorMsg;




            fullCovAlreadyAcheived=obj.mfullCovAlreadyAcheived;
        end

        function compatStatus=getCompatStatus(obj)
            compatStatus=obj.mCompatStatus;
        end

        function status=hasExtractionFailed(obj)
            status=obj.mExtractionFailed;
        end

        function analysisPhase=getAnalysisPhase(obj)
            analysisPhase=obj.mAnalysisPhase;
        end
    end


    methods(Access=public)
        function obj=Translator(...
            originalModelH,...
            blockH,...
            opts,...
            showUI,...
            startCov,...
            testComp,...
            filterExistingCov,...
            reuseTranslationCache,...
customEnhancedMCDCOpts...
            )


            assert(~isempty(testComp)&&...
            isa(testComp,'SlAvt.TestComponent')&&...
            ishandle(testComp),...
            'Invalid Arguments');


            if(nargin<9)
                customEnhancedMCDCOpts=[];
            end

            if(nargin<8)
                obj.mReuseTranslationCache=true;
            else
                obj.mReuseTranslationCache=reuseTranslationCache;
            end

            if(nargin<7)
                filterExistingCov=true;
            end



            obj.setDiagnosticInterceptor();


            try
                obj.setArguments(originalModelH,blockH,opts,showUI,startCov,...
                testComp,filterExistingCov,customEnhancedMCDCOpts);
            catch MEx

                obj.setOutputOnAbnormalTermination(MEx.message);
                rethrow(MEx);
            end


            obj.setDefaults();
        end

        function delete(obj)
            obj.clearDiagnosticInterceptor();
        end
    end


    methods(Access=private)
        function setArguments(obj,originalModelH,blockH,opts,showUI,...
            startCov,testComp,filterExistingCov,customEnhancedMCDCOpts)

            if ischar(originalModelH)||isstring(originalModelH)
                obj.mRootModelH=get_param(originalModelH,'Handle');
            elseif isnumeric(originalModelH)
                obj.mRootModelH=originalModelH;
            else
                ME=MException('SldvCompatibility:InvalidArguments','Invalid Arguments');
                throw(ME);
            end


            if isempty(blockH)
                obj.mBlockH=[];
            elseif ischar(blockH)||isstring(blockH)
                obj.mBlockH=get_param(blockH,'Handle');
            elseif isnumeric(blockH)
                obj.mBlockH=blockH;
            else
                ME=MException('SldvCompatibility:InvalidArguments','Invalid Arguments');
                throw(ME);
            end


            obj.mOptions=opts;


            obj.mShowUI=showUI;


            obj.mStartCov=startCov;


            obj.mTestComp=testComp;

            obj.mFilterExistingCov=filterExistingCov;


            obj.mCompatDataInfo=Sldv.CompatDataInfo();







            obj.setTestComponentSimulationMode();


            [obj.mCacheDirFullPath,obj.mCacheFileName]=sldvprivate('getSldvCacheDIR',...
            obj.mRootModelH,obj.mBlockH,obj.mTestComp.activeSettings.Mode,obj.mIsXIL);


            obj.mCustomEnhancedMCDCOpts=customEnhancedMCDCOpts;
        end

        function setDefaults(obj)
            obj.mErrorMsg='';
            obj.mSuccessStatus=false;
            obj.mfullCovAlreadyAcheived=false;
            obj.mCompatStatus=Sldv.CompatStatus.DV_COMPAT_UNKNOWN;
            obj.mExtractedModelH=obj.mRootModelH;
            obj.mExtractionFailed=false;
            obj.mSkipTranslation=false;
            obj.mCompatibilityData=[];
            obj.mCacheHandler=Sldv.Compatibility.CacheHandler(obj.mRootModelH,obj.mBlockH,obj.mTestComp.activeSettings.Mode,obj.mIsXIL);
            obj.mModelToCheckCompatH=obj.mExtractedModelH;
            obj.mModelToCheckCompatName=get_param(obj.mModelToCheckCompatH,'Name');
            obj.mModelToReportCompatibilityName=Sldv.Translator.modelToLogCompatibility(obj.mModelToCheckCompatName,obj.mTestComp);
            obj.mBlkHs=[];
            obj.mBlkTypes={};
            obj.mStartupBlkHs=[];
            obj.mStartupParams={};
            obj.mIsTranslatorForComponent=false;
            obj.mAnalysisPhase=Sldv.AnalysisPhase.Compatibility;
        end

        function setDiagnosticInterceptor(obj)
            obj.mInterceptorScopeDefiner=Simulink.output.registerProcessor(redirectInterceptor());
        end

        function clearDiagnosticInterceptor(obj)
            obj.mInterceptorScopeDefiner=[];
        end
    end


    methods(Access=private)
        status=designModelCompatibilityChecks(obj)

        status=blockCompatibilityChecks(obj)

        status=observerCompileTimeCompatChecks(obj);

        status=checkWorkSpaceAccess(obj)

        status=executeBlockReplacements(obj)

        status=extractSubsystem(obj)

        [status,msg]=createHarnessForXIL(obj);

        status=extractExportFcnModel(obj)

        status=extractSLFunctionServices(obj)

        status=setInputCovDataAndFilter(obj)

        status=setInputCovData(obj);

        status=setCovFilter(obj);

        status=fullCoverageAcheived(obj)

        [status,res,msg]=generateCompatibilityResults(obj)

        initCoverage(obj)

        status=resolveSettings(obj)

        setTestComponentSimulationMode(obj)

        setUpXILMode(obj)

        translateAndCheckCompat(obj,isMdlRefTranslation,buildArgs)

        ignoreObserversWithinModelRefs(obj)
    end



    methods(Access=private)
        function setOutputOnAbnormalTermination(obj,errMsg)
            if nargin>1&&~isempty(errMsg)
                obj.mErrorMsg=errMsg;
            end
            obj.mSuccessStatus=false;
        end

        function status=checkForUserStopRequest(obj)
            status=obj.stopRequested();
            if status
                obj.mCompatStatus=Sldv.CompatStatus.DV_COMPAT_UNKNOWN;
                obj.mSuccessStatus=false;
                obj.mfullCovAlreadyAcheived=false;

                obj.cleanUpOnHalt();
            end
        end

        function stopped=stopRequested(obj)
            stopped=false;
            if obj.mShowUI


                drawnow();



                if isempty(obj.mTestComp)||~ishandle(obj.mTestComp)


                    MEx=MException('Sldv:TestComponent:invalidObj',...
                    'SLDV TestComponent is no longer valid');
                    throw(MEx);
                end



                try
                    if~isempty(obj.mTestComp)&&~isempty(obj.mTestComp.progressUI)
                        stopped=obj.mTestComp.progressUI.stopped;
                    end
                catch
                    stopped=true;
                end

                obj.mErrorMsg='Stopped by user';
            end
        end

        function cleanUpOnHalt(obj)
            if obj.mShowUI
                try
                    obj.logNewLines(getString(message('Sldv:Setup:DesignVerifierStopped')));
                    obj.mTestComp.progressUI.finalized=true;
                    obj.mTestComp.progressUI.refreshLogArea;
                    obj.mTestComp.progressUI.showLogArea;
                catch
                end
            end
        end

        function errorHalt(obj,forceShow)
            obj.logNewLines(getString(message('Sldv:Setup:DesignVerifierFailed')));

            if obj.mShowUI
                testcomp=obj.mTestComp;
                if~isempty(testcomp)
                    testcomp.progressUI.finalized=true;
                    testcomp.progressUI.refreshLogArea;
                    if forceShow
                        testcomp.progressUI.showLogArea;
                    end
                end
            end
        end

        function warnHalt(obj,forceShow)
            if obj.mShowUI
                if~isempty(obj.mTestComp)
                    obj.mTestComp.progressUI.finalized=true;
                    obj.mTestComp.progressUI.refreshLogArea;
                    if forceShow
                        obj.mTestComp.progressUI.showLogArea;
                    end
                end
            end
        end

        function genVarDimError(~,modelH)
            msg=sprintf('%s',getString(message('Sldv:Compatibility:HasVariableSizeSignals',get_param(modelH,'Name'))));
            sldvshareprivate('avtcgirunsupcollect','push',modelH,'sldv',msg,'Sldv:Compatibility:HasVariableSizeSignals');
        end

        function genBusSfunStubError(~,sfunBlk)
            msg=getString(message('Sldv:Compatibility:SFunctionWithBusIO'));
            sldvshareprivate('avtcgirunsupcollect','push',sfunBlk,'sldv',msg,'Sldv:Compatibility:SFunctionWithBusIO');
        end

        function status=checkWindowsPathLengthViolations(obj)










            status=false;
            modelName=Simulink.ID.getFullName(obj.mRootModelH);
            [sldv_outputFolder,modelFolder]=fileparts(obj.mOptions.OutputDir);

            if~isfolder(fullfile(pwd,sldv_outputFolder))&&isfolder(sldv_outputFolder)



                sldv_out_dir=fullfile(sldv_outputFolder,modelName);
            elseif strcmp(modelFolder,'$ModelName$')&&~isempty(sldv_outputFolder)


                sldv_out_dir=fullfile(pwd,sldv_outputFolder,modelName);
            else

                sldv_out_dir=fullfile(pwd,modelFolder);
            end
            buffer=30;
            win64threshHold=260;

            sldvDataFile=[modelName,'_sldvData','.mat'];





            if(strlength(sldv_out_dir)+strlength(sldvDataFile)+buffer)>win64threshHold
                status=true;
            end
        end
    end



    methods(Access=private)
        function logNewLines(obj,str)
            obj.logAll(sprintf('\n%s\n',str));
        end

        function logAll(obj,str)

            obj.logger(true,str);
        end

        function logSome(obj,str)

            obj.logger(false,str);
        end

        function logger(obj,logAll,str)

            if sldvshareprivate('util_is_analyzing_for_fixpt_tool')
                return;
            end

            if obj.mShowUI
                if~isempty(obj.mTestComp)&&isa(obj.mTestComp,'SlAvt.TestComponent')


                    try
                        obj.mTestComp.progressUI.appendToLog(str);
                    catch
                    end
                else
                    if logAll&&~ModelAdvisor.isRunning
                        str=sldvshareprivate('util_remove_html',str);
                        fprintf(1,'%s',str);
                    end
                end
            else
                if logAll&&~ModelAdvisor.isRunning
                    str=sldvshareprivate('util_remove_html',str);
                    fprintf(1,'%s',str);
                end
            end
        end

        function out=html_green(~,in)
            out=['<font color="green"><b>',in,'</b></font>'];
        end

        function out=html_orange(~,in)
            out=['<font color="orange"><b>',in,'</b></font>'];
        end

        function out=html_red(~,in)
            out=['<font color="red"><b>',in,'</b></font>'];
        end

        function msg=compatibleMsg(obj)
            compatStr=getString(message('Sldv:Setup:Compatible'));

            if obj.mShowUI
                compatStr=obj.html_green(compatStr);
            end

            msg=obj.compatibilityMsg(compatStr);
        end

        function msg=partiallySupportedMsg(obj)
            modelH=obj.mModelToCheckCompatH;
            compatStr=getString(message('Sldv:Setup:PartiallyCompatible'));
            if obj.mShowUI
                compatStr=obj.html_orange(compatStr);
            end

            [msg,preStr]=obj.compatibilityMsg(compatStr);
            isAutoStubOn=strcmp(obj.mTestComp.activeSettings.AutomaticStubbing,'on');
            if isAutoStubOn
                advice=sprintf(getString(message('Sldv:Setup:UnsupportedToBeStubbed',preStr)));
            else
                advice=sprintf(getString(message('Sldv:Setup:HasUnsupportedNeedsStubbing',preStr)));
            end
            msg=sprintf('%s\n%s\n',msg,advice);
            sldvshareprivate('avtcgirunsupcollect','push',modelH,'sldv_stubbed',...
            sprintf('%s',getString(message('Sldv:Setup:IsOnlyPartialSupport',preStr,msg))),...
            'SLDV:Compatibility:PartiallyCompatible');
        end

        function[msg,preStr]=unsupportedMsg(obj)
            compatStr=getString(message('Sldv:Setup:Incompatible'));
            if obj.mShowUI
                compatStr=obj.html_red(compatStr);
            end
            [msg,preStr]=obj.compatibilityMsg(compatStr);
        end

        function[msg,preStr]=compatibilityMsg(obj,compatStr)

            switch obj.mTestComp.activeSettings.Mode
            case 'TestGeneration'
                mode=getString(message('Sldv:Setup:TestGeneration'));
            case 'DesignErrorDetection'
                mode=getString(message('Sldv:Setup:DesignErrorDetection'));
            case 'PropertyProving'
                mode=getString(message('Sldv:Setup:PropertyProving'));
            otherwise
                error(message('Sldv:Setup:UnknownActivity'));
            end

            if strcmp(obj.mTestComp.activeSettings.RequirementsTableAnalysis,'on')
                mode=getString(message('Sldv:Setup:ReqTableAnalysis'));
            end
            compatStr=[compatStr,' ',mode];

            if sldvprivate('mdl_iscreated_for_subsystem_analysis',obj.mTestComp)
                blockH=sldvprivate('mdl_resolve_analyzed_subsystem',obj.mTestComp);
                mdlName=getfullname(blockH);
                preStr='Subsystem';
            else
                mdlName=get_param(obj.modelToReportH(),'Name');
                if SlCov.CovMode.isXIL(obj.mTestComp.simMode)
                    preStr='code';
                else
                    preStr='model';
                end
            end
            if sldvshareprivate('util_is_analyzing_for_fixpt_tool')
                msg=sprintf('%s',getString(message('Sldv:Setup:IsWithFixedPointToolRangeDerivation',mdlName,compatStr)));
            else
                msg=sprintf('%s',getString(message('Sldv:Setup:IsWithSimulinkDesignVerifier',mdlName,compatStr)));
            end
        end

        function modelToLogH=modelToReportH(obj)
            modelToLogH=obj.mModelToCheckCompatH;
            if~isempty(obj.mTestComp)
                analysisInfo=obj.mTestComp.analysisInfo;
                if analysisInfo.replacementInfo.replacementsApplied&&...
                    analysisInfo.replacementInfo.tempReplacement
                    modelToLogH=analysisInfo.analyzedModelH;
                end
            end
        end

        function displayCompatibilityResults(obj,res)

            if sldvshareprivate('util_is_analyzing_for_fixpt_tool')
                return;
            end

            res=strrep(res,'$PRODUCT$','Simulink Design Verifier');

            if obj.mShowUI
                try
                    obj.mTestComp.progressUI.appendToLog(sprintf('%s\n',res));
                    obj.mTestComp.progressUI.showLogArea();
                catch
                end
            elseif~ModelAdvisor.isRunning
                fprintf('\n%s',res);
            end
        end

        function status=addSldvOutputsFolderToPath(obj,status)
            if status

                try
                    session=sldvprivate('sldvGetActiveSession',obj.mTestComp.analysisInfo.designModelH);
                    sldvOuputsPath=sldvprivate('mdl_get_output_dir',obj.mTestComp);
                    session.setSldvOuputsPath(sldvOuputsPath);
                catch Mex %#ok<NASGU>
                    status=false;
                end
            end
        end

        function reportExtractionFailure(obj,errorMsg)






            obj.mExtractionFailed=true;


            obj.logNewLines(errorMsg);

            if obj.mShowUI
                obj.logNewLines(getString(message('Sldv:Setup:ReferDiagnosticsWindow')));
            end
        end
    end

    methods(Static,Hidden)
        xilUtils(action,varargin)

        transOpts=getTranslationOptions(sldvOpts,modelH)

        isConsistent=checksumConsistencyCheck(CachedChecksum,CurrentChecksum)

        check=anyChangeInTranslationOptions(cachedTranslationOptions,currentTranslationOptions)
    end

    methods(Static,Access=private)
        function mode=getReuseTranslationMode(sldvOpts)
            val=sldvOpts.RebuildModelRepresentation;
            switch val
            case "Always"
                mode=Sldv.ReuseTranslationMode.Never;
            case "IfChangeIsDetected"
                mode=Sldv.ReuseTranslationMode.OnlyWhenCacheIsValid;
            otherwise
                mode=Sldv.ReuseTranslationMode.Never;
            end
        end

        function out=modelToLogCompatibility(mdlName,testcomp)
            out=mdlName;
            analysisInfo=testcomp.analysisInfo;
            if analysisInfo.replacementInfo.replacementsApplied&&...
                analysisInfo.replacementInfo.tempReplacement
                out=get_param(analysisInfo.analyzedModelH,'Name');
            end
        end

        function logReuseTranslationMessages(msgIdentifier,logMsg)
            LoggerId='sldv::reuseTranslation';
            logStr=sprintf('Sldv::Translator::%s::%s',msgIdentifier,logMsg);
            sldvprivate('SLDV_LOG_DEBUG',LoggerId,logStr);
        end
    end


    methods(Access=private)
        [blkSID,sfSID,hdl2sid]=convertToSIDs(obj,blockH,sfId)

        [blkH,sfId,sid2hdl]=convertToHdlOrSfId(obj,blockSID,sfObjSID)

        function initializeSIDMaps(obj)


            obj.mSID_2_Blk_Hdl_ID=containers.Map('keyType','char','valueType','double');
            obj.mBlk_Hdl_SfId_2_SID=containers.Map('keyType','double','valueType','char');
        end

        function readTranslationDataFromCache(obj)
            obj.initializeSIDMaps();


            obj.mTranslationState.TranslationOptions=...
            Sldv.Translator.getTranslationOptions(obj.mTestComp.activeSettings,obj.mRootModelH);




            obj.computeComponentChecksum();



            if slfeature('SLDVCacheInSLXC')>0
                [tStatus,tMsg,tMsgID]=obj.mCacheHandler.unpackCacheFromSLXC();
                if~tStatus
                    obj.clearCacheDIR();
                    sldvshareprivate('avtcgirunsupcollect','push',...
                    obj.mTestComp.analysisInfo.analyzedModelH,'sldv_warning',tMsg,tMsgID);







                    obj.clearDiagnosticInterceptor();
                    sldvshareprivate('avtcgirunsupdialog',obj.mTestComp.analysisInfo.analyzedModelH,obj.mShowUI);
                    obj.setDiagnosticInterceptor();



                    sldvshareprivate('avtcgirunsupcollect','clear');
                end
            end

            if obj.mReuseTranslationCache
                ReuseMode=Sldv.Translator.getReuseTranslationMode(obj.mTestComp.activeSettings);


                if(ReuseMode==Sldv.ReuseTranslationMode.OnlyWhenCacheIsValid)


                    if obj.mIsXIL&&~isempty(obj.mBlockH)&&...
                        strcmpi(get_param(obj.mBlockH,'blockType'),'Subsystem')
                        str=getString(message('Sldv:Setup:UnsupportedModelTranslationXILSubsystem'));
                        obj.logAll(sprintf('%s\n',str));
                        obj.mSkipTranslation=false;
                    else
                        obj.tryToFetchTranslationDataFromCache();
                    end
                end


                if~(obj.mIsXIL&&~isempty(obj.mBlockH)&&...
                    strcmpi(get_param(obj.mBlockH,'blockType'),'Subsystem'))
                    obj.mSkipTranslation=obj.mCompatDataInfo.isValid();
                end

                if obj.mSkipTranslation
                    obj.mCompatibilityData=load(obj.mCompatDataInfo.sldvCachePath);


                    if(ReuseMode==Sldv.ReuseTranslationMode.OnlyWhenCacheIsValid)
                        obj.logSome(sprintf('\n%s',datestr(now)));
                        str=getString(message('Sldv:Setup:ValidatingModelRepresentationCache',obj.mCompatibilityData.compatTimestamp));
                        obj.logAll(sprintf('\n%s',str));
                        obj.mSkipTranslation=obj.isCacheReusable();
                        if~obj.mSkipTranslation
                            str=getString(message('Sldv:Setup:ChangeDetected'));
                            obj.logAll(sprintf('%s\n',str));
                        end
                    end
                end
            else
                obj.mSkipTranslation=false;
            end


            extractedModelH=[];
            replacementModelH=[];
            defaultReplacementInfo=obj.mTestComp.analysisInfo.replacementInfo;

            if obj.mSkipTranslation
                try

                    [status,extractedModelH]=obj.tryToFetchExtractionModelFromCache();%#ok


                    [status,replacementModelH]=obj.tryToFetchReplacementModelFromCache();
                catch
                    status=false;
                end

                if~status
                    obj.mSkipTranslation=false;
                    str=getString(message('Sldv:Setup:BuildingModelRepresentationFromCacheFailed'));
                    obj.logAll(sprintf('%s\n',str));
                end
            end


            if obj.mSkipTranslation
                [obj.mBlkHs,obj.mBlkTypes]=obj.getBlockHsAndBlockTypes(obj.mModelToCheckCompatH);
                if obj.modelHasMLSysBlk



                    str=getString(message('Sldv:Setup:DiscardCacheDueToMLSysBlk'));
                    obj.logAll(sprintf('%s\n',str));
                    obj.mSkipTranslation=false;


                    tMsgID='Sldv:Compatibility:WarnNoReuseTranslationForMLSysBlk';
                    tMsg=getString(message('Sldv:Setup:WarnNoReuseTranslationForMLSysBlk'));
                    sldvshareprivate('avtcgirunsupcollect','push',...
                    obj.mTestComp.analysisInfo.analyzedModelH,'sldv_warning',tMsg,tMsgID);
                    obj.clearDiagnosticInterceptor;
                    sldvshareprivate('avtcgirunsupdialog',obj.mTestComp.analysisInfo.analyzedModelH,obj.mShowUI);
                    obj.setDiagnosticInterceptor;
                    sldvshareprivate('avtcgirunsupcollect','clear');
                end
            end


            if obj.mSkipTranslation
                try
                    status=loadCompatData(obj);
                catch
                    status=false;
                end

                if~status
                    obj.mSkipTranslation=false;
                    str=getString(message('Sldv:Setup:BuildingModelRepresentationFromCacheFailed'));
                    obj.logAll(sprintf('%s\n',str));
                end
            end




            if~obj.mSkipTranslation
                if~isempty(extractedModelH)&&...
                    bdIsLoaded(get_param(extractedModelH,'Name'))
                    close_system(extractedModelH,0);
                    obj.restoreExtractedMdlDetails();
                end

                if~isempty(replacementModelH)&&...
                    bdIsLoaded(get_param(replacementModelH,'Name'))
                    close_system(replacementModelH,0);
                    obj.restoreReplacementMdlDetails(defaultReplacementInfo);
                end

                obj.resetBlockHsAndBlockTypes;
            end





            if obj.mSkipTranslation




                Sldv.utils.switchObsMdlsToStandaloneMode(obj.mRootModelH);
            end















            if obj.mSkipTranslation&&~isempty(replacementModelH)...
                &&obj.isCustomBlockReplacement()
                tMsg=getString(message('Sldv:Setup:WarnReuseTranslationForCustomBlockReplacement'));
                tMsgID='Sldv:Compatibility:WarnReuseTranslationForCustomBlockReplacement';
                sldvshareprivate('avtcgirunsupcollect','push',...
                replacementModelH,'sldv_warning',tMsg,tMsgID);






                obj.clearDiagnosticInterceptor();
                sldvshareprivate('avtcgirunsupdialog',replacementModelH,obj.mShowUI);
                obj.setDiagnosticInterceptor();



                sldvshareprivate('avtcgirunsupcollect','clear');
            end




            obj.mTestComp.analysisInfo.useTranslationCache=obj.mSkipTranslation;
        end

        function flag=modelHasMLSysBlk(obj)
            mlSysBlks=obj.mBlkHs(strcmp(obj.mBlkTypes,'MATLABSystem'));
            flag=~isempty(mlSysBlks);
        end





        function resetBlockHsAndBlockTypes(obj)
            obj.mBlkHs=[];
            obj.mBlkTypes={};
        end

        function status=isCustomBlockReplacement(obj)
            opts=obj.mTestComp.activeSettings;
            status=false;
            if strcmpi('on',opts.BlockReplacement)
                status=Sldv.xform.BlkReplacer.hasCustomRules(opts.BlockReplacementRulesList);
            end
        end

        function restoreExtractedMdlDetails(obj)
            obj.mTestComp.analysisInfo.analyzedModelH=obj.mTestComp.analysisInfo.designModelH;
            obj.mTestComp.analysisInfo.extractedModelH=obj.mTestComp.analysisInfo.designModelH;
            obj.mTestComp.analysisInfo.analyzedSubsystemH=[];
            obj.mTestComp.analysisInfo.analyzedAtomicSubchartWithParam=0;

            obj.mTestComp.analysisInfo.blockDiagramExtract=0;
        end

        function restoreReplacementMdlDetails(obj,defaultReplacementInfo)
            obj.mTestComp.analysisInfo.analyzedModelH=obj.mTestComp.analysisInfo.designModelH;
            obj.mTestComp.analysisInfo.extractedModelH=obj.mTestComp.analysisInfo.designModelH;
            obj.mTestComp.analysisInfo.replacementInfo=defaultReplacementInfo;
        end

        function[status,extractedModelH]=tryToFetchExtractionModelFromCache(obj)
            extractedModelH=[];
            if isempty(obj.mBlockH)
                isExportFcnModel=strcmp(get_param(obj.mRootModelH,'IsExportFunctionModel'),'on');
                isSLDVStub=sldvshareprivate('mdl_has_missing_slfunction_defs',obj.mRootModelH);
                if~isExportFcnModel&&~isSLDVStub
                    status=true;
                    return;
                end
            end

            ext='.slx';
            analysisInfo=obj.mCompatibilityData.analysisInfo;
            extractedModel=[analysisInfo.extractedModel,ext];
            extractedModel=fullfile(obj.mCacheDirFullPath,extractedModel);

            if isfile(extractedModel)

                dstExtractedModelName=deriveExtractedModelName(...
                analysisInfo.extractedModel,...
                extractedModel,...
                obj.mTestComp.activeSettings,...
                obj.mShowUI);
                if bdIsLoaded(analysisInfo.extractedModel)
                    close_system(analysisInfo.extractedModel,0);
                end
                copyfile(extractedModel,dstExtractedModelName);

                obj.mExtractedModelH=load_system(dstExtractedModelName);
                extractedModelH=obj.mExtractedModelH;
                obj.mTestComp.analysisInfo.analyzedModelH=obj.mExtractedModelH;
                obj.mTestComp.analysisInfo.extractedModelH=obj.mExtractedModelH;


                obj.mTestComp.analysisInfo.analyzedSubsystemH=Simulink.ID.getHandle(analysisInfo.analyzedSubsystem);
                obj.mTestComp.analysisInfo.analyzedAtomicSubchartWithParam=analysisInfo.analyzedAtomicSubchartWithParam;


                obj.mTestComp.analysisInfo.blockDiagramExtract=analysisInfo.blockDiagramExtract;
                obj.mTestComp.analysisInfo.exportFcnGroupsInfo=analysisInfo.exportFcnGroupsInfo;
                obj.mTestComp.analysisInfo.stubbedSimulinkFcnInfo=analysisInfo.stubbedSimulinkFcnInfo;
            end

            status=Sldv.SubSystemExtract.copyCoverageAndSldvFilterFiles(obj.mRootModelH,...
            obj.mTestComp.activeSettings,...
            obj.mBlockH,...
            obj.mExtractedModelH,...
            dstExtractedModelName);

            function extractedModelFullPath=deriveExtractedModelName(extractedModelName,extractedModelPath,opts,showUI)
                MakeOutputFilesUnique='off';

                extractedModelFullPath=Sldv.utils.settingsFilename(extractedModelName,MakeOutputFilesUnique,...
                '$ModelExt$',extractedModelPath,showUI,true,opts);

                [path,~,ext]=fileparts(extractedModelFullPath);
                extractedModelFullPath=[fullfile(path,extractedModelName),ext];
            end
        end

        function[status,repMdlHdl]=tryToFetchReplacementModelFromCache(obj)
            repMdlHdl=[];
            status=false;

            analysisInfo=obj.mCompatibilityData.analysisInfo;

            if~isfield(analysisInfo.replacementInfo,'replacementModelName')
                obj.mModelToCheckCompatH=obj.mExtractedModelH;
                obj.mModelToCheckCompatName=get_param(obj.mModelToCheckCompatH,'Name');
                obj.mModelToReportCompatibilityName=Sldv.Translator.modelToLogCompatibility(obj.mModelToCheckCompatName,obj.mTestComp);
                status=true;
                return;
            end

            srcMdl=which(get_param(obj.mExtractedModelH,'Name'));
            [~,~,ext]=fileparts(srcMdl);

            replacementModel=[analysisInfo.replacementInfo.replacementModelName,ext];
            replacementModel=fullfile(obj.mCacheDirFullPath,replacementModel);

            if isfile(replacementModel)

                dstReplacementModelName=deriveReplacementModelName(...
                analysisInfo.replacementInfo.replacementModelName,...
                obj.mExtractedModelH,...
                obj.mTestComp.activeSettings,...
                obj.mShowUI);

                if bdIsLoaded(analysisInfo.replacementInfo.replacementModelName)
                    close_system(analysisInfo.replacementInfo.replacementModelName,0);
                end
                copyfile(replacementModel,dstReplacementModelName);

                analysisInfo.replacementInfo=rmfield(analysisInfo.replacementInfo,'replacementModelName');


                repMdlHdl=load_system(dstReplacementModelName);
                obj.mModelToCheckCompatH=repMdlHdl;
                obj.mTestComp.analysisInfo.analyzedModelH=repMdlHdl;
                analysisInfo.replacementInfo.replacementTable=replacePathWithHdls(analysisInfo.replacementInfo.replacementTable);
                analysisInfo.replacementInfo.notReplacedBlksTable=replacePathWithHdls(analysisInfo.replacementInfo.notReplacedBlksTable);


                analysisInfo.replacementInfo.replacementModelH=repMdlHdl;
                obj.mTestComp.analysisInfo.replacementInfo=analysisInfo.replacementInfo;


                obj.mModelToCheckCompatName=get_param(obj.mModelToCheckCompatH,'Name');
                obj.mModelToReportCompatibilityName=Sldv.Translator.modelToLogCompatibility(obj.mModelToCheckCompatName,obj.mTestComp);

                status=true;
            end

            function new_map=replacePathWithHdls(old_map)
                new_map=containers.Map('KeyType','double','ValueType','any');
                for k=old_map.keys
                    new_map(get_param(k{1},'Handle'))=old_map(k{1});
                end
            end

            function replacementModelFullPath=deriveReplacementModelName(replacementModelName,modelH,opts,showUI)
                MakeOutputFilesUnique='off';

                replacementModelFullPath=Sldv.utils.settingsFilename(replacementModelName,MakeOutputFilesUnique,...
                '$ModelExt$',modelH,showUI,true,opts);

                [path,~,ext]=fileparts(replacementModelFullPath);
                replacementModelFullPath=[fullfile(path,replacementModelName),ext];
            end
        end

        function status=isCustomCodeInfoChanged(obj)
            status=false;
            if isfield(obj.mCompatibilityData.translationState','CustomCodeChecksum')
                cachedCustomCodeInfo=obj.mCompatibilityData.translationState.CustomCodeChecksum;
                status=~isequal(obj.mTranslationState.CustomCodeChecksum,cachedCustomCodeInfo);
            end
        end

        function status=hasXILInfoChanged(obj)
            status=false;
            if~isempty(obj.mCompatibilityData)&&...
                isfield(obj.mCompatibilityData.translationState','XILChecksum')
                cachedXILInfo=obj.mCompatibilityData.translationState.XILChecksum;
                status=~isequal(obj.mTranslationState.XILChecksum,cachedXILInfo);
            end
        end

        isReusable=isCacheReusable(obj)

        tryToFetchTranslationDataFromCache(obj);

        function status=genCacheDirectory(obj)


            if~sldvprivate('isReuseTranslationON',obj.mTestComp.activeSettings)
                status=true;
                return;
            end



            assert(~obj.mIsTranslatorForComponent);







            status=obj.clearCache();

            if~isfolder(obj.mCacheDirFullPath)
                status=mkdir(obj.mCacheDirFullPath);
            end

            if~status
                tMsgID='Sldv:Compatibility:GeneratingCacheDirFailed';
                tMsg=getString(message('Sldv:Setup:GeneratingCacheDirFailed'));
                sldvshareprivate('avtcgirunsupcollect','push',...
                obj.mTestComp.analysisInfo.analyzedModelH,'sldv_warning',tMsg,tMsgID);
            end
        end

        function[status,msg,msgID]=clearCacheDIR(obj)


            assert(~obj.mIsTranslatorForComponent);
            status=true;
            msg='';
            msgID='';
            if isfolder(obj.mCacheDirFullPath)
                [status,msg,msgID]=rmdir(obj.mCacheDirFullPath,'s');
            end
        end

        function status=clearCache(obj)






            status=true;
            try
                [dataFileName,fileExt]=obj.getTranslationDataFileName();
                dataFileName=fullfile(obj.mCacheDirFullPath,[dataFileName,fileExt]);
                if isfile(dataFileName)
                    delete(dataFileName);
                end
                [dvoFileName,fileExt]=obj.getTranslationDvoFileName();
                dvoFileName=fullfile(obj.mCacheDirFullPath,[dvoFileName,fileExt]);
                if isfile(dvoFileName)
                    delete(dvoFileName);
                end
            catch
                status=false;
            end
        end

        computeComponentChecksum(obj)
        status=loadCompatData(obj)
    end


    methods(Access=private)
        function[compatStatusStr,stubsfcns]=genericCompatibilityChecks(obj,modelH,blkHs,blkTypes)
            compatStatusStr=obj.mCompatStatus.char;




            [compatStatusStr,stubsfcns]=sldvprivate('mdl_check_initial_property',...
            compatStatusStr,modelH,obj.mTestComp,obj.mOptions,blkHs,blkTypes);





            compatStatusStr=sldvprivate('mdl_check_logic_expr_depth',modelH,compatStatusStr);
        end
    end


    methods(Access=private)
        function getObserverModelHs(obj,modelH)




            if~sldvprivate('isObserverSupportON',obj.mTestComp.activeSettings)||...
                (obj.mModelToCheckCompatH==modelH&&~isempty(obj.mCompatObserverModelHs))||...
                obj.mSkipTranslation


                return;
            end


            obj.mCompatObserverModelHs=Simulink.observer.internal.getObserverModelsForBD(modelH);
        end

        function initIncompatObserverList(obj,linkSpec)
            obj.mCompatObserverModelHs=Simulink.observer.internal.getObserverModelsForBD(obj.mRootModelH);

            if isequal(0,numel(linkSpec))
                return;
            end

            sldvSession=sldvprivate('sldvGetActiveSession',obj.mRootModelH);

            for idx=1:numel(linkSpec)
                linkSpecInfo=linkSpec(idx).LinkSpecInfo;
                obsH=get_param(linkSpecInfo.ModelName,'handle');

                if strcmp(linkSpecInfo.compatStatus,'InCompatible')
                    sldvSession.addToIncompatObserverList(obsH);
                    obj.mCompatObserverModelHs(obj.mCompatObserverModelHs==obsH)=[];
                end
            end
        end

        function[mBlkHs,mBlkTypes]=getBlockHsAndBlockTypes(obj,modelH)
            if obj.mModelToCheckCompatH==modelH&&~isempty(obj.mBlkHs)
                mBlkHs=obj.mBlkHs;
                mBlkTypes=obj.mBlkTypes;
                return;
            end



            fsOpts={'FollowLinks','on','LookUnderMasks','all',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices};
            mBlkHs=find_system(modelH,fsOpts{:});
            mBlkHs(1)=[];
            mBlkTypes=get_param(mBlkHs,'BlockType');
        end

        function simFunBlks=getSimulinkFunctionBlocks(obj)




            simFunBlks=[];
            subsysBlks=obj.mBlkHs(strcmp('SubSystem',obj.mBlkTypes));
            if~isempty(subsysBlks)
                simFunBlks=subsysBlks(strcmp('on',get_param(subsysBlks,'IsSimulinkFunction')));
            end
        end

        function preLookupBlks=getPreLookupBlocks(obj)




            preLookupBlks=obj.mBlkHs(strcmp('PreLookup',obj.mBlkTypes));
        end

        function reportInitErrors(obj)
            obj.clearDiagnosticInterceptor();

            timeStamp=datestr(now);

            obj.logSome(sprintf('\n%s\n',timeStamp));

            [~,res,obj.mErrorMsg]=obj.generateCompatibilityResults();
            obj.displayCompatibilityResults(res);

            obj.setDiagnosticInterceptor();
        end

        function startupParams=getStartupVariantParams(obj)
            startupParams={};
            if isempty(obj.mStartupBlkHs)
                return;
            end

            startupParamsMap=containers.Map('KeyType','char','ValueType','logical');

            dataAccessor=Simulink.data.DataAccessor.create(obj.mModelToCheckCompatH);

            for idx=1:numel(obj.mStartupBlkHs)
                vParams=slvariants.internal.manager.core.getVariantControlVarsForBlock(obj.mStartupBlkHs(idx));

                for pIdx=1:numel(vParams)
                    vParam=vParams{pIdx};

                    vID=dataAccessor.identifyByName(vParam);
                    vParamObj=dataAccessor.getVariable(vID);
                    if isempty(vParamObj)||~isa(vParamObj,'Simulink.Parameter')


















                        startupParams={};
                        return;
                    end



                    if~isKey(startupParamsMap,vParam)
                        startupParamsMap(vParam)=true;
                        startupParams{end+1}=vParam;%#ok<AGROW> 
                    end
                end

            end

        end

        function startupBlkHs=getStartupVariantBlkHs(obj)
            startupBlkHs=[];
            if isempty(obj.mBlkHs)
                return;
            end

            for idx=1:numel(obj.mBlkHs)
                blkH=obj.mBlkHs(idx);

                if Sldv.utils.checkIfStartUpVariantBlock(blkH)
                    startupBlkHs=[startupBlkHs,blkH];%#ok<AGROW> 
                end
            end
        end
    end


    methods(Access=private)
        function[fName,fExt]=getTranslationDataFileName(obj)
            fName=[obj.mCacheFileName,'_translationData'];
            fExt='.mat';
        end

        function[fName,fExt]=getTranslationDvoFileName(obj)
            fName=[obj.mCacheFileName,'_translationDvo'];
            fExt='.dvo';
        end
    end








    methods(Access=public)
        function testLoadCompatData(obj,compatDataInfo)










            obj.mCompatDataInfo=compatDataInfo;


            obj.initializeSIDMaps();

            obj.mCompatibilityData=load(obj.mCompatDataInfo.sldvCachePath);

            [~,~]=obj.tryToFetchExtractionModelFromCache();

            [~,~]=obj.tryToFetchReplacementModelFromCache();


            obj.loadCompatData();
        end
    end
end



