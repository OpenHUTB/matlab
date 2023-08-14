


























classdef Session<handle

    properties


        HighlightStatusFlag=false;
    end

    properties(Access=private)
        mShowUI=false;
        mSldvOpts=[];
        mSldvToken=[];
        mTestComp=[];
        mCsLock=[];
        mModelH=[];
        mBlockH=[];
        mBlockPathObj=[];
        mInitCovData=[];
        mState=Sldv.SessionState.None;
        mEnabledGoals=[];
        mSldvAnalyzer=[];
        mAnalysisStrategy=[];
        mSLOutputStage=[];
        mSldvExecDiagStage=[];
        mTaskManager=[];
        mAnalysisTask=[];
        mResProcessorTask=[];
        mValidatorTask=[];
        mHighlighterTask=[];
        mProgressUITask=[];
        mMatlabTaskDispatcherTask=[];
        mAnalysisTasksDone=false;
        mSessionTerminating=false;
        mStandaloneCompat=false;
        mMdlPathInSldvOuputs='';
        mMockResultsFullFileName='';
        mIncompatObserverMdlHs=[];
        mObserverTranslationInfo=[];
        mClient=Sldv.SessionClient.Unknown;










        mSldvChecksumMode=Sldv.ChecksumMode.SLDV_CHECKSUM_UNKNOWN;
        mProximityDataFile='';
        mProximityDataReadyFile='';
    end

    events
HighlightChanged
AsyncAnalysisLaunched
AnalysisWrap
AsyncAnalysisDone
    end


    methods(Access=public)











        [status,newModelH,msg,fullCovAlreadyAchieved,sldvData]=...
        checkCompatibility(obj,filterExistingCov,reuseTranslationCache,customEnhancedMCDCOpts,standaloneCompat);



        validatedSldvData=validateTestCases(obj,sldvData,useParallel);

        [status,msg]=generateIR(obj,obsMdlH,isMdlRef,buildArgs);











        function registerObserver(obj,observerBlockH,observerMap)
        end














        function createSldvExecutionDiagStage(obj)
            assert(isempty(obj.mSldvExecDiagStage));
            obj.mSldvExecDiagStage=...
            Simulink.output.Stage(message('Sldv:SldvRun:SLDV_RUN_STAGE_NAME').getString(),...
            'ModelName',get_param(obj.mModelH,'Name'),'UIMode',obj.mShowUI);
        end







        function destroySldvExecutionDiagStage(obj)
            obj.mSldvExecDiagStage=[];
        end

        function generateProfileReport(obj)
            testComp=obj.mTestComp;



            if~isempty(testComp)
                goalIdToObjectiveIdMap=[];
                if~isempty(obj.mSldvAnalyzer)
                    [~,~,goalIdToObjectiveIdMap,~]=obj.mSldvAnalyzer.getStaticSldvData();
                end

                if~isempty(goalIdToObjectiveIdMap)
                    sldvprivate('profile_terminate',testComp,'goalIdToObjectiveIdMap',goalIdToObjectiveIdMap);
                else
                    sldvprivate('profile_terminate',testComp);
                end
            end
        end

        function terminateProfileThread(obj,thread)
            testComp=obj.mTestComp;

            switch(thread)
            case 'Main'
                testComp.getMainProfileLogger().logTerminateThread();
            case 'Analysis'

                testComp.replayBackendProfile();
                testComp.getAnalysisProfileLogger().logTerminateThread();
            case 'Validation'
                testComp.getValidationProfileLogger().logTerminateThread();
            otherwise
            end
        end






        function analysisMode=getAnalysisMode(obj)
            analysisMode=obj.mTestComp.activeSettings.Mode;

            return;
        end





        [status,newModelH,errStr,fullCovAlreadyAchieved,resultFileNames]=...
        extractAndRunCompatibility(obj,preExtract,customEMCDCOpts);


        function compatStatus=getCompatibilityStatus(obj)
            compatStatus='DV_COMPAT_UNKNOWN';
            testComp=obj.mTestComp;

            if~isempty(testComp)
                compatStatus=testComp.compatStatus;
            end
        end


        function status=isCompatibilityRunning(obj)
            status=false;

            if(Sldv.SessionState.CompatibilityRunning==obj.mState)
                status=true;

                assert(true==obj.isSldvTokenInUse());
            else
                status=false;
            end

            return;
        end


        function status=isCompilationSuccess(obj)
            status=false;

            if(Sldv.SessionState.MdlCompSuccess==obj.mState)
                status=true;
            else
                status=false;
            end

            return;
        end


        function status=isCompilationFailure(obj)
            status=false;

            if(Sldv.SessionState.MdlCompFailure==obj.mState)
                status=true;
            else
                status=false;
            end

            return;
        end



        function status=isAnalysisRunning(obj)
            status=false;

            if(Sldv.SessionState.AsyncAnalysisRunning==obj.mState)
                status=true;


                assert(true==obj.isSldvTokenInUse());
            else
                status=false;
            end

            return;
        end


        function status=isAnalysisSuccess(obj)
            status=false;

            if(Sldv.SessionState.AnalysisSuccess==obj.mState)
                status=true;
            else
                status=false;
            end

            return;
        end


        function status=isAnalysisFailure(obj)
            status=false;

            if(Sldv.SessionState.AnalysisFailure==obj.mState)
                status=true;
            else
                status=false;
            end

            return;
        end


        function status=isGeneratingResults(obj)
            status=false;

            if(Sldv.SessionState.GeneratingResults==obj.mState)
                status=true;
            else
                status=false;
            end

            return;
        end


        function status=isResultsSuccess(obj)
            status=false;

            if(Sldv.SessionState.ResultsSuccess==obj.mState)
                status=true;
            else
                status=false;
            end

            return;
        end


        function status=isResultsFailure(obj)
            status=false;

            if(Sldv.SessionState.ResultsFailure==obj.mState)
                status=true;
            else
                status=false;
            end

            return;
        end

        [status,msg]=launchAnalysis(obj);

        function[status,msg,fileNames]=analyze(obj,reset)

            assert(~isempty(obj.mTestComp));
            assert(~isempty(obj.mModelH));

            status=1;
            msg='';
            fileNames=Sldv.Utils.initDVResultStruct();

            if nargin<2

                reset=true;
            end


            status=(Sldv.SessionState.MdlCompSuccess==obj.mState)||...
            (Sldv.SessionState.AnalysisSuccess==obj.mState)||...
            (Sldv.SessionState.AnalysisFailure==obj.mState)||...
            (Sldv.SessionState.ResultsSuccess==obj.mState)||...
            (Sldv.SessionState.ResultsFailure==obj.mState);
            if~status

                return;
            end

            if reset


                [~,status]=evalc('obj.mTestComp.rebuildParamConstraints()');
                if~status
                    error('Sldv:Session:analyze','Failed to rebuild Parameter Constraints');
                end
            end

            [status,msg,fileNames]=obj.runAnalysis();

            return;
        end

        [status,msg,fileNames]=runAnalysis(obj,testStrategyName);


        function stopped=handleStopRequest(obj,msgID)
            stopped=false;
            testComp=obj.mTestComp;




            if isempty(testComp)||isempty(testComp.progressUI)
                return;
            end

            if obj.mShowUI


                drawnow();





                if~isvalid(obj)
                    stopped=true;
                    obj.logNewLines(getString(message(msgID)));
                    MEx=MException('Sldv:Session:invalidObj',...
                    'SLDV Session is no longer valid');
                    throw(MEx);
                end







                try
                    stopped=testComp.progressUI.stopped;
                    if stopped
                        obj.logNewLines(getString(message(msgID)));
                    end

                    if stopped&&~testComp.progressUI.finalized
                        testComp.progressUI.finalized=true;
                        testComp.progressUI.refreshLogArea();
                        testComp.progressUI.showLogArea();
                    end
                catch
                    stopped=true;
                    obj.logNewLines(getString(message(msgID)));
                end
            end
        end






        function stopped=clearStopRequest(obj,processEvents)
            if nargin<2
                processEvents=true;
            end

            stopped=false;
            testComp=obj.mTestComp;




            if isempty(testComp)||isempty(testComp.progressUI)
                return;
            end

            if obj.mShowUI
                if processEvents


                    drawnow();





                    if~isvalid(obj)
                        stopped=true;
                        MEx=MException('Sldv:Session:invalidSession',...
                        'SLDV Session is no longer valid');
                        throw(MEx);
                    end
                end







                try
                    stopped=testComp.progressUI.stopped;

                    testComp.progressUI.stopped=false;
                    testComp.progressUI.abortSignal=false;
                    testComp.progressUI.refreshLogArea();
                catch
                    stopped=true;
                end
            end

            return;
        end


        function deleteATSHarness(obj)
            if~isempty(obj.mBlockH)&&strcmp(get_param(obj.mBlockH,'blockType'),'SubSystem')
                dirtyStatus=get_param(obj.mTestComp.analysisInfo.designModelH,'Dirty');
                subSystemFullName=getfullname(obj.mBlockH);
                harnessModelName=regexprep([get_param(obj.mBlockH,'Name'),'_harness_SubsystemSIL'],'\s+','');
                harnesslist=Simulink.harness.internal.find(subSystemFullName,'Name',harnessModelName);
                if~isempty(harnesslist)
                    if harnesslist.isOpen
                        set_param(harnessModelName,'Dirty','off');
                        Simulink.harness.internal.close(obj.mBlockH,harnessModelName);
                    end
                    Simulink.harness.internal.delete(obj.mBlockH,harnessModelName);
                    set_param(get_param(obj.mTestComp.analysisInfo.designModelH,'Name'),'Dirty',dirtyStatus);
                end
            end
        end

        function terminate(obj)







            obj.mSessionTerminating=true;



            if~isempty(obj.mTaskManager)&&...
                (obj.mTaskManager.isRunning()||(obj.mTaskManager.isIdle()))

                obj.mTaskManager.terminate('DV_CAUSE_INTERRUPTED');
            end


            obj.terminateProfileThread('Main');
            obj.generateProfileReport();


            obj.cleanup();


            obj.mState=Sldv.SessionState.Terminated;

            return;
        end












        function reset(obj,blockH,sldvOpts,showUI,initCovData,client,blockPathObj)
            if nargin<7
                blockPathObj=[];
            end

            if nargin<6

                client=Sldv.SessionClient.DVCommandLine;
            end


            obj.cleanup();



            obj.init(blockH,sldvOpts,showUI,initCovData,client,blockPathObj);

            return;
        end


































        function terminateAnalysis(obj)
            if isempty(obj.mTaskManager)
                return;
            end

            if obj.mTaskManager.isAborted()||obj.mTaskManager.isDone()
                return;
            end

            obj.mTaskManager.tryTerminate();



        end


        function closeReplacementModel(obj)
            testComp=obj.mTestComp;

            if~isempty(testComp)&&~isempty(testComp.analysisInfo)
                analysisInfo=testComp.analysisInfo;
                if analysisInfo.replacementInfo.replacementsApplied&&...
                    analysisInfo.replacementInfo.tempReplacement

                    replInfo=analysisInfo.replacementInfo;


                    try
                        Sldv.xform.silentCloseModels(replInfo.mdlsLoadedForMdlRefTree);
                    catch MEx
                    end







                    try
                        Sldv.close_system(replInfo.replacementModelH,0,'SkipCloseFcn',true);
                    catch MEx
                    end
                end
            end
        end

        function closeExtractedModel(obj)
            testComp=obj.mTestComp;
            if~isempty(testComp)&&~isempty(testComp.analysisInfo)
                analysisInfo=testComp.analysisInfo;
                if~isempty(analysisInfo.extractedModelH)&&...
                    ~isequal(analysisInfo.extractedModelH,analysisInfo.designModelH)







                    try
                        Sldv.close_system(analysisInfo.extractedModelH,0,'SkipCloseFcn',true);
                    catch
                    end
                end
            end
        end

        function toggleHighlighting(this,toHighlight)

            modelH=this.mModelH;
            avtH=get_param(modelH,'AutoVerifyData');

            if nargin==1
                toHighlight=~this.HighlightStatusFlag;
            end


            this.HighlightStatusFlag=toHighlight;




            this.notifyHighlightViewListeners(this.HighlightStatusFlag);





            if~isfield(avtH,'modelView')||~avtH.modelView.isvalid
                return;
            end

            modelView=avtH.modelView;

            try

                if toHighlight
                    if~modelView.isHighlighted
                        modelView.initializeHighlighting;
                    end

                    modelView.view();
                    modelView.refresh();
                else

                    modelView.removeHighlightingPreservingData();
                end
            catch Mex

                this.HighlightStatusFlag=false;


                this.notifyHighlightViewListeners(this.HighlightStatusFlag);

                warning('Sldv:SldvresultsSummary:ErrorHighlight',...
                [getString(message('Sldv:SldvresultsSummary:ErrorHighlight')),': ',Mex.message]);

                for MexId=1:length(Mex.stack)
                    disp(Mex.stack(MexId));
                end
            end

        end

        function notifyHighlightViewListeners(this,HighlightStatusFlag)

            if HighlightStatusFlag
                highlightChangeEventData=Sldv.HighlightChangeEventData('Highlight Added',struct('modelH',this.mModelH));
            else
                highlightChangeEventData=Sldv.HighlightChangeEventData('Highlight Removed',struct('modelH',this.mModelH));
            end
            this.notify('HighlightChanged',highlightChangeEventData);






            if this.isAnalysisRunning()



                if~isempty(this.mTestComp.progressUI)&&ishandle(this.mTestComp.progressUI.dialogH)
                    this.mTestComp.progressUI.dialogH.refresh;
                end
            end
        end
    end




    methods(Access=public,Hidden)



        function modelMappingInfo=getCompiledData(obj)
            modelMappingInfo=obj.mTestComp.getModelMappingInfo();
        end






        function[status,msg]=emitAnalysisDvo(obj)
            status=false;
            testComp=obj.mTestComp;
            if strcmp(testComp.compatStatus,'DV_COMPAT_COMPATIBLE')||...
                strcmp(testComp.compatStatus,'DV_COMPAT_PARTIALLY_SUPPORTED')
                if isempty(testComp.blocks)

                    testComp.createAnalysisContext();
                end

                sldvprivate('naive_objective_selection',testComp);
                [msg,status]=evalc('testComp.emitDvo()');
            else
                msg='Can Emit DVO only after successful compatibility check';
            end
        end

        function[status,msg,fileNames]=testRunAnalysis(obj,analysisInput)
            assert(~isempty(obj.mTestComp));

            status=1;
            msg=[];
            fileNames=Sldv.Utils.initDVResultStruct();

            obj.mTestComp.setInternalStrategy(analysisInput.strategyName);

            [status,msg,fileNames]=obj.runAnalysis();

            return;
        end


        function status=isAsyncAnalysisDone(obj)
            status=obj.mSldvAnalyzer.isAsyncAnalysisDone();

            return;
        end


        function status=isAsyncAnalysisFinished(obj)
            status=obj.mSldvAnalyzer.isAsyncAnalysisFinished();

            return;
        end
    end

    methods(Access=public)
        function obj=Session(modelH,blockH,sldvOpts,showUI,initCovData,client,blockPathObj)
            if nargin<7
                blockPathObj=[];
            end

            if nargin<6
                client=Sldv.SessionClient.DVCommandLine;
            end

            obj.mModelH=modelH;




            avDataHandle=get_param(obj.mModelH,'AutoVerifyData');
            avDataHandle.sldvSession=obj;
            set_param(obj.mModelH,'AutoVerifyData',avDataHandle);

            obj.init(blockH,sldvOpts,showUI,initCovData,client,blockPathObj);
        end

        function delete(obj)








            cleanup(obj);





            obj.mModelH=[];
        end

        function[totalCovData,sldvTcIds]=getCovData(obj,sldvDataTestCase)






            if~isempty(obj.mTestComp)
                testCases=sldvprivate('sldv_datamodel_get_testcases',obj.mTestComp);
            else


                testCases=[];
            end
            totalCovData=[];
            sldvTcIds=[];

            if~isempty(testCases)
                for idx=1:numel(sldvDataTestCase)
                    tc=testCases(sldvDataTestCase(idx).testCaseId);
                    if~isempty(tc.covData)
                        sldvTcIds(end+1)=idx;
                        if isempty(totalCovData)
                            totalCovData=tc.covData;
                        else
                            totalCovData=totalCovData+tc.covData;
                        end
                    end
                end
            end
        end
    end

    methods(Access=private)
        function init(obj,blockH,sldvOpts,showUI,initCovData,client,blockPathObj)
            obj.mBlockH=blockH;

            if isempty(blockPathObj)
                obj.mBlockPathObj=Simulink.BlockPath(getfullname(blockH));
            else


                blockPathObj.validate;


                leafLevel=blockPathObj.getLength;
                leafBlock=blockPathObj.getBlock(leafLevel);
                leafBlockH=get_param(leafBlock,'handle');
                if blockH~=leafBlockH
                    errorId='Sldv:Setup:InvalidBlockPathObject';
                    badBPMex=MException(errorId,getString(message(errorId)));
                    throw(badBPMex);
                end
                obj.mBlockPathObj=blockPathObj;
            end





            obj.mSldvOpts=sldvOpts;
            obj.mShowUI=showUI;
            obj.mInitCovData=initCovData;
            obj.HighlightStatusFlag=false;


            sldvshareprivate('avtcgirunsupcollect','clear',obj.mModelH);

            obj.mState=Sldv.SessionState.Initialized;




            if slavteng('feature','LogSLDVDDUX')
                obj.setClient(client);
                sldv.ddux.Logger.getInstance().resetSession();
            end
        end

        function cleanup(obj)














            if~isempty(obj.mSldvToken)
                obj.releaseSldvToken();
            end






            Sldv.utils.manageAliasTypeCache('clear');




            obj.removeSldvOutputsFromPath();
            if slavteng('feature','ProximityTableCal')==1


                if~isempty(obj.mProximityDataReadyFile)&&isfile(obj.mProximityDataReadyFile)
                    delete(obj.mProximityDataReadyFile);
                end
                if~isempty(obj.mProximityDataFile)&&isfile(obj.mProximityDataFile)
                    delete(obj.mProximityDataFile);
                end
            end





            if~isempty(obj.mCsLock)
                obj.unlockConfigSet();
            end

            obj.deleteTestComponent();
            if~isempty(obj.mTaskManager)
                assert(isvalid(obj.mTaskManager));
                assert(obj.mTaskManager.isDone()||(obj.mTaskManager.isAborted()));
                delete(obj.mTaskManager);
                obj.mTaskManager=[];
            end


            obj.mSldvToken=[];
            obj.mTestComp=[];
            obj.mCsLock=[];
            obj.mBlockH=[];
            obj.mSldvOpts=[];
            obj.mShowUI=false;
            obj.mInitCovData=[];
            obj.mState=Sldv.SessionState.None;
            obj.mSldvAnalyzer=[];
            obj.mAnalysisStrategy=[];
            obj.mSLOutputStage=[];
            obj.mSldvExecDiagStage=[];
            obj.mTaskManager=[];
            obj.mResProcessorTask=[];
            obj.mValidatorTask=[];
            obj.mHighlighterTask=[];
            obj.mProgressUITask=[];
            obj.mMatlabTaskDispatcherTask=[];
            obj.mAnalysisTasksDone=false;
            obj.mSessionTerminating=false;
            obj.mIncompatObserverMdlHs=[];
            obj.mObserverTranslationInfo=[];
            obj.mClient=Sldv.SessionClient.Unknown;

            return;
        end

        function status=acquireSldvToken(obj)
            status=true;
            obj.mSldvToken=Sldv.Token.get();
            tokenOwned=obj.mSldvToken.use();

            if~tokenOwned
                obj.mSldvToken=[];
                status=false;
                return;
            end

            assert(true==obj.isSldvTokenInUse());
            return;
        end

        function releaseSldvToken(obj)
            if(true==obj.isSldvTokenInUse())


                obj.mSldvToken.setTestComponent([]);
                obj.mSldvToken.release();
                obj.mSldvToken=[];
            end

            assert(isempty(obj.mSldvToken));
            return;
        end

        function status=isSldvTokenInUse(obj)
            status=false;

            if(~isempty(obj.mSldvToken)&&isvalid(obj.mSldvToken)&&(true==obj.mSldvToken.isInUse))
                status=true;
            end

            return;
        end

        function[status,msg]=createTestComponent(obj,modelH,blockH,sldvOpts)
            status=true;

            [obj.mTestComp,msg]=sldvprivate('eng_attach_testcomponent',modelH,blockH,sldvOpts);

            if~isempty(msg)

                assert(isempty(obj.mTestComp));
                status=false;
            else































































                obj.mTestComp.acquireExternalReference();
                status=true;
            end

            return;
        end


        function postEventToTaskManager(obj,src,event)

            assert(~isempty(obj.mTaskManager)&&isvalid(obj.mTaskManager));

            switch event.EventName
            case 'AnalysisInit'
                obj.mTaskManager.broadcastEvent(Sldv.Tasking.SldvEvents.AnalysisInit);
            case 'AsyncAnalysisLaunched'
                obj.mTaskManager.broadcastEvent(Sldv.Tasking.SldvEvents.AsyncAnalysisLaunched);
            case 'AsyncAnalysisUpdate'
                obj.mTaskManager.broadcastEvent(Sldv.Tasking.SldvEvents.AsyncAnalysisUpdate);
            case 'AsyncAnalysisDone'
                obj.mTaskManager.broadcastEvent(Sldv.Tasking.SldvEvents.AsyncAnalysisDone);
            case 'TerminateAsyncAnalysis'
                obj.mTaskManager.broadcastEvent(Sldv.Tasking.SldvEvents.TerminateAsyncAnalysis);
            case 'AnalysisWrap'
                obj.mTaskManager.broadcastEvent(Sldv.Tasking.SldvEvents.AnalysisWrap);
            case 'CheckForMatlabTask'
                obj.mTaskManager.broadcastEvent(Sldv.Tasking.SldvEvents.CheckForMatlabTask);
            otherwise
                assert(0,'Invalid event to be posted to TaskManager');
            end
        end

        function[status,msg]=resetTestComponent(obj,modelH,blockH,sldvOpts)
            obj.deleteTestComponent();
            [status,msg]=obj.createTestComponent(modelH,blockH,sldvOpts);
        end
        function deleteTestComponent(obj)
            if(~isempty(obj.mTestComp)&&ishandle(obj.mTestComp))

                obj.closeReplacementModel();
                obj.closeExtractedModel();

                obj.mTestComp.destroy;


                obj.mTestComp.releaseExternalReference();
                delete(obj.mTestComp);
                obj.mTestComp=[];
            end

            assert(isempty(obj.mTestComp));
            return;
        end

        function status=lockConfigSet(obj)
            status=true;


            obj.mCsLock=Sldv.ConfigSetLock(obj.mModelH);

            return;
        end

        function unlockConfigSet(obj)
            if(~isempty(obj.mCsLock)&&isvalid(obj.mCsLock))
                delete(obj.mCsLock);
                obj.mCsLock=[];
            end

            assert(isempty(obj.mCsLock));
            return;
        end


        function onSyncAnalysisTasksDone(obj)



            assert(true==obj.mTaskManager.isDone()||true==obj.mTaskManager.isAborted());


            analysisStatus=Sldv.AnalysisStatus.None;
            obj.mSldvAnalyzer.wrapAnalysis(analysisStatus);

            obj.cleanupAnalysisTasks();

            obj.terminateProfileThread('Analysis');

            return;
        end


        function onSyncAnalysisTasksTerminate(obj)



            assert(true==obj.mTaskManager.isAborted());




            if obj.mTaskManager.hasTimedOut()
                analysisStatus=Sldv.AnalysisStatus.Timeout;
            else
                analysisStatus=Sldv.AnalysisStatus.Terminated;
            end


            obj.mSldvAnalyzer.wrapAnalysis(analysisStatus);

            obj.cleanupAnalysisTasks();

            obj.terminateProfileThread('Analysis');

            return;
        end


        function onAsyncAnalysisTasksDone(obj)



            assert(true==obj.mTaskManager.isDone());








            analysisStatus=Sldv.AnalysisStatus.None;
            obj.mSldvAnalyzer.wrapAnalysis(analysisStatus);

            obj.cleanupAnalysisTasks();

            obj.postAsyncAnalysis();
        end


        function onAsyncAnalysisTasksTerminate(obj)
            assert(obj.mTaskManager.isAborted(),'Invalid TaskManager State');




            if obj.mTaskManager.hasTimedOut()
                analysisStatus=Sldv.AnalysisStatus.Timeout;
            else
                analysisStatus=Sldv.AnalysisStatus.Terminated;
            end


            obj.mSldvAnalyzer.wrapAnalysis(analysisStatus);


            obj.cleanupAnalysisTasks();

            obj.postAsyncAnalysis();
        end

        function status=abortDialogWindow(obj)

            questTxt=getString(message('Sldv:SldvRun:WantProduceResults'));
            questTitle=getString(message('Sldv:SldvRun:AnalysisAborted'));
            answer=questdlg(questTxt,questTitle,'Yes','No','Yes');

            status=true;





            if~isvalid(obj)
                status=false;
                MEx=MException('Sldv:Session:invalidObj',...
                'SLDV Session is no longer valid');
                throw(MEx);
            end

            if(isempty(answer)||~strcmpi(answer,'yes'))
                status=false;
            else

                processEvents=false;
                obj.clearStopRequest(processEvents);
            end

            if~status
                obj.mTestComp.progressUI.finalized=true;
                obj.mTestComp.progressUI.refreshLogArea();


                [~,~,msgVect]=sldvshareprivate('avtcgirunsuppost');
                if obj.mTestComp.hasAnalysisErrs||obj.mTestComp.hasUnsatisfiableObjs||...
                    (~isempty(msgVect)&&(length(msgVect)~=1||any(~strcmpi(msgVect{1},getString(message('Sldv:SldvRun:NoInformation'))))))
                    sldvprivate('mdl_create_unsafe_cast_errors',obj.mTestComp);
                    sldvshareprivate('avtcgirunsupdialog',obj.mTestComp.analysisInfo.analyzedModelH,obj.mShowUI);
                end
            end

        end

        function postAsyncAnalysis(obj)
            assert(true==obj.isSldvTokenInUse());




            obj.terminateProfileThread('Analysis');



            analysisRunStatus=obj.mSldvAnalyzer.getAnalysisStatus();
            if((1==analysisRunStatus)||(-1==analysisRunStatus))
                obj.mState=Sldv.SessionState.AnalysisSuccess;
            else
                assert(0==analysisRunStatus);
                obj.mState=Sldv.SessionState.AnalysisFailure;
            end

            try



                if~obj.mSessionTerminating
                    obj.generateAnalysisResults(obj.mTestComp,analysisRunStatus);
                end



                obj.generateProfileReport();





                analysisMsg=obj.mSldvAnalyzer.getAnalysisErrorMsg;
                if isstruct(analysisMsg)&&isfield(analysisMsg,'msgid')
                    obj.logDiagnostics(Sldv.AnalysisPhase.Analysis,analysisMsg);
                end
            catch
                if~isvalid(obj)
                    return;
                end
            end


            delete(obj.mAnalysisStrategy);
            obj.mAnalysisStrategy=[];


            delete(obj.mSldvAnalyzer);
            obj.mSldvAnalyzer=[];


            Sldv.utils.manageAliasTypeCache('clear');


            obj.unlockConfigSet();


            obj.releaseSldvToken();


            obj.mSLOutputStage=[];
            obj.mSldvExecDiagStage=[];

            obj.removeSldvOutputsFromPath();


            obj.notify('AnalysisWrap');


            if~Sldv.utils.Options.isTestgenTargetForModel(obj.mTestComp.activeSettings)
                obj.deleteATSHarness();
            end

            return;
        end



        function status=updateAnalysisOptions(obj,sldvOptions)
            assert(strcmp(sldvOptions.Mode,obj.mSldvOpts.Mode));
            assert(~isempty(obj.mTestComp));

            status=true;

            if slfeature('SldvDeprecateDisplayUnsatisfiableObjectives')
                genAnalysisOptions={'MaxProcessTime',...
                'OutputDir'};
            else
                genAnalysisOptions={'MaxProcessTime',...
                'DisplayUnsatisfiableObjectives',...
                'OutputDir'};
            end

            testGenAnalysisOptions={'TestSuiteOptimization',...
            'MaxTestCaseSteps',...
'ExtendExistingTests'...
            ,'ExistingTestFile',...
            'IgnoreExistTestSatisfied',...
            'SaveExpectedOutput',...
            'RandomizeNoEffectData'};


            dedAnalysisOptions={};
            propProvingAnalysisOptions={'ProvingStrategy',...
            'MaxViolationSteps'};
            resultOptions={'SaveDataFile',...
            'DataFileName'};
            testGenResultOptions={'SaveHarnessModel',...
            'HarnessModelFileName',...
            'ModelReferenceHarness',...
            'SlTestFileName',...
            'SlTestHarnessName'};
            reportOptions={'SaveReport',...
            'ReportPDFFormat',...
            'ReportFileName',...
            'ReportIncludeGraphics',...
            'DisplayReport',...
            'DisplayResultsOnModel'};


            cellfun(@(opt)set(obj.mSldvOpts,opt,get(sldvOptions,opt)),genAnalysisOptions);
            cellfun(@(opt)set(obj.mTestComp.activeSettings,opt,get(sldvOptions,opt)),...
            genAnalysisOptions);


            if(strcmp('TestGeneration',obj.mSldvOpts.Mode))
                cellfun(@(opt)set(obj.mSldvOpts,opt,get(sldvOptions,opt)),...
                testGenAnalysisOptions);
                cellfun(@(opt)set(obj.mTestComp.activeSettings,opt,get(sldvOptions,opt)),...
                testGenAnalysisOptions);
                cellfun(@(opt)set(obj.mSldvOpts,opt,get(sldvOptions,opt)),...
                testGenResultOptions);
                cellfun(@(opt)set(obj.mTestComp.activeSettings,opt,get(sldvOptions,opt)),...
                testGenResultOptions);
            elseif(strcmp('DesignErrorDetection',obj.mSldvOpts.Mode))
                cellfun(@(opt)set(obj.mSldvOpts,opt,get(sldvOptions,opt)),...
                dedAnalysisOptions);
                cellfun(@(opt)set(obj.mTestComp.activeSettings,opt,get(sldvOptions,opt)),...
                dedAnalysisOptions);
            elseif(strcmp('PropertyProving',obj.mSldvOpts.Mode))
                cellfun(@(opt)set(obj.mSldvOpts,opt,get(sldvOptions,opt)),...
                propProvingAnalysisOptions);
                cellfun(@(opt)set(obj.mTestComp.activeSettings,opt,get(sldvOptions,opt)),...
                propProvingAnalysisOptions);
            end


            cellfun(@(opt)set(obj.mSldvOpts,opt,get(sldvOptions,opt)),resultOptions);
            cellfun(@(opt)set(obj.mTestComp.activeSettings,opt,get(sldvOptions,opt)),...
            resultOptions);


            cellfun(@(opt)set(obj.mSldvOpts,opt,get(sldvOptions,opt)),reportOptions);
            cellfun(@(opt)set(obj.mTestComp.activeSettings,opt,get(sldvOptions,opt)),...
            reportOptions);

            return;
        end

        function cleanupTranslationInfo(obj)

            delete(obj.mObserverTranslationInfo);
            obj.mObserverTranslationInfo=[];
        end



        function cleanupCompatibility(obj)






            if(~isvalid(obj))
                return;
            end


            obj.cleanupTranslationInfo();
            if obj.mStandaloneCompat||(obj.mState==Sldv.SessionState.MdlCompFailure)



                obj.removeSldvOutputsFromPath();
            end

            obj.generateProfileReport();


            Sldv.utils.manageAliasTypeCache('clear');


            obj.releaseSldvToken();

            return;
        end





        function cleanupAnalysis(obj)


            if(~isvalid(obj))
                return;
            end


            if(~isempty(obj.mTaskManager)&&...
                (obj.mTaskManager.isRunning()||obj.mTaskManager.isIdle()))

                try
                    obj.mTaskManager.terminate('DV_CAUSE_INTERRUPTED');
                catch MEx %#ok<NASGU> 

                end
                obj.mState=Sldv.SessionState.AnalysisFailure;
            end


            obj.generateProfileReport();

            if~isempty(obj.mAnalysisStrategy)
                delete(obj.mAnalysisStrategy);
                obj.mAnalysisStrategy=[];
            end


            if~isempty(obj.mSldvAnalyzer)
                delete(obj.mSldvAnalyzer);
                obj.mSldvAnalyzer=[];
            end


            Sldv.utils.manageAliasTypeCache('clear');


            obj.releaseSldvToken();

            return;
        end

        function setupAnalysisTasks(obj)

            if~isempty(obj.mTaskManager)
                assert(isvalid(obj.mTaskManager));
                assert(obj.mTaskManager.isDone()||(obj.mTaskManager.isAborted()));
                delete(obj.mTaskManager);
                obj.mTaskManager=[];
            end


            aPeriod=0.1;
            [~,~,aTimeOut]=sldvprivate('mdl_get_analysis_settings',obj.mTestComp);

            obj.mTaskManager=Sldv.Tasking.SldvTaskManager(aPeriod,aTimeOut);



            addlistener(obj.mSldvAnalyzer,'AnalysisInit',...
            @(src,event)obj.postEventToTaskManager(src,event));
            addlistener(obj.mSldvAnalyzer,'AsyncAnalysisLaunched',...
            @(src,event)obj.postEventToTaskManager(src,event));
            addlistener(obj.mSldvAnalyzer,'AsyncAnalysisUpdate',...
            @(src,event)obj.postEventToTaskManager(src,event));
            addlistener(obj.mSldvAnalyzer,'AsyncAnalysisDone',...
            @(src,event)obj.postEventToTaskManager(src,event));
            addlistener(obj.mSldvAnalyzer,'TerminateAsyncAnalysis',...
            @(src,event)obj.postEventToTaskManager(src,event));
            addlistener(obj.mSldvAnalyzer,'AnalysisWrap',...
            @(src,event)obj.postEventToTaskManager(src,event));
            addlistener(obj.mSldvAnalyzer,'AsyncAnalysisDone',...
            @(src,event)obj.notifyAsyncAnalysisDone(src,event));


            ready=false;
            obj.mAnalysisTask=Sldv.Tasking.AnalysisTask(obj.mTaskManager,ready,...
            obj.mAnalysisStrategy);


            ready=false;
            obj.mResProcessorTask=Sldv.Tasking.ResultsProcessorTask(obj.mTaskManager,...
            ready,obj.mSldvAnalyzer);

            isValidatorON=Sldv.Utils.isValidatorEnabled(obj.mTestComp.activeSettings,obj.mTestComp.simMode);
            if isValidatorON

                ready=false;
                obj.mValidatorTask=Sldv.Tasking.ValidatorTask(obj.mTaskManager,ready,...
                obj.mTestComp,obj.mSldvAnalyzer);
            end



            ready=false;
            obj.mProgressUITask=Sldv.Tasking.ProgressUITask(obj.mTaskManager,...
            ready,obj.mTestComp);

            if slavteng('feature','ProximityTableCal')==2






                obj.mMatlabTaskDispatcherTask=Sldv.Tasking.MatlabTaskDispatcherTask(obj.mTaskManager,...
                false,obj.mTestComp,obj.mSldvAnalyzer);
            end

            if slavteng('feature','IncrementalHighlighting')&&obj.mShowUI

                ready=false;
                obj.mHighlighterTask=Sldv.Tasking.HighlighterTask(obj.mTaskManager,...
                ready,obj.mSldvAnalyzer);
            end


            obj.mAnalysisTasksDone=false;

            return;
        end



        function analysisStrategy=createAnalysisStrategy(obj,testStrategyName)
            assert(~isempty(obj.mSldvAnalyzer));
            assert(~isempty(obj.mTestComp));

            if nargin<2||isempty(testStrategyName)
                strategyName=sldvprivate('sldv_get_strategy_name',obj.mTestComp);
            else
                strategyName=testStrategyName;
            end

            if(strcmp(strategyName,'IterativeStrategy'))
                analysisStrategy=Sldv.Analysis.IterativeStrategy(obj.mSldvAnalyzer,obj.mTestComp);
            elseif shouldRunProximity(obj,strategyName)
                analysisStrategy=Sldv.Analysis.CONE(obj.mSldvAnalyzer,obj.mTestComp);
            else


                analysisStrategy=Sldv.Analysis.SimpleStrategy(obj.mSldvAnalyzer);
            end
        end

        function cleanupAnalysisTasks(obj)

            if~isempty(obj.mAnalysisTask)
                delete(obj.mAnalysisTask);
                obj.mAnalysisTask=[];
            end
            if~isempty(obj.mResProcessorTask)
                delete(obj.mResProcessorTask);
                obj.mResProcessorTask=[];
            end
            if~isempty(obj.mValidatorTask)
                delete(obj.mValidatorTask);
                obj.mValidatorTask=[];
            end
            if~isempty(obj.mProgressUITask)
                delete(obj.mProgressUITask);
                obj.mProgressUITask=[];
            end
            if~isempty(obj.mHighlighterTask)
                delete(obj.mHighlighterTask);
                obj.mHighlighterTask=[];
            end
            if~isempty(obj.mMatlabTaskDispatcherTask)
                delete(obj.mMatlabTaskDispatcherTask);
                obj.mMatlabTaskDispatcherTask=[];
            end















            obj.mAnalysisTasksDone=true;

            return;
        end

        function result=shouldRunProximity(obj,strategyName)
            result=strcmp(strategyName,'Auto');
            result=result&&(slavteng('feature','CONEWithProximity')~=0);
            result=result&&(~slavteng('feature','AnalysisLevels')||...
            num2str(obj.mTestComp.activeSettings.AnalysisLevel)>=4);
        end

        function terminateAnalysisTasks(obj)
            obj.mTaskManager.terminate('DV_CAUSE_INTERRUPTED');
            obj.cleanupAnalysisTasks();

            return;
        end

        function waitForAnalysisTasksDone(obj)





            while(false==obj.mAnalysisTasksDone)
                drawnow();

            end

            return;
        end

        function reportError(obj,errorCode,errorMsg)
            if obj.mShowUI
                dialogTitle=getString(message('Sldv:SldvRun:SimulinkDesignVerifier'));
                errordlg(errorMsg,dialogTitle);
            else
                error(errorCode,errorMsg);
            end

            return;
        end

        function logNewLines(obj,str)
            obj.logAll(sprintf('\n%s\n',str));
        end

        function logAll(obj,str)

            obj.logger(obj.mTestComp,obj.mShowUI,true,str);
        end

        function logger(~,testcomp,showUI,logAll,str)

            if sldvshareprivate('util_is_analyzing_for_fixpt_tool')
                return;
            end

            if showUI
                if~isempty(testcomp)&&isa(testcomp,'SlAvt.TestComponent')


                    try
                        testcomp.progressUI.appendToLog(str);
                    catch Mex %#ok<NASGU>
                    end
                else
                    if logAll
                        str=sldvshareprivate('util_remove_html',str);
                        fprintf(1,str);
                    end
                end
            else
                if logAll
                    str=sldvshareprivate('util_remove_html',str);
                    fprintf(1,'%s',str);
                end
            end
        end







        function refreshInformer(obj)


            if Sldv.AnalysisStatus.Success==obj.mSldvAnalyzer.getCurrentAnalysisStatus()
                return;
            end

            if(obj.mShowUI&&~ModelAdvisor.isRunning)
                handles=get_param(obj.mModelH,'AutoVerifyData');
                if isfield(handles,'modelView')
                    modelView=handles.modelView;
                    if~isempty(obj.mTestComp)
                        modelView.updateAnalysisStatus(obj.mTestComp.analysisStatus);
                        modelView.view;
                    end
                end
            end
        end

        function removeSldvOutputsFromPath(obj)
            orig_state=warning('off','MATLAB:rmpath:DirNotFound');
            try
                rmpath(obj.mMdlPathInSldvOuputs);
                warning(orig_state);
            catch
                warning(orig_state);
            end
            if obj.mStandaloneCompat
                return;
            else
                obj.mMdlPathInSldvOuputs='';
            end
        end

        function setClient(obj,val)


            if ModelAdvisor.isRunning
                obj.mClient=Sldv.SessionClient.SimulinkCheck;
                return;
            end
            if strcmp(get_param(obj.mModelH,'InRangeAnalysisMode'),'on')
                obj.mClient=Sldv.SessionClient.FixedPoint;
                return;
            end

            obj.mClient=val;
        end

        logSetupData(obj);

        logDiagnostics(obj,AnalysisPhase,msg);

        logAnalysisResults(obj,sldvData);
    end


    methods(Access=public)




        function[constraintId]=addParamConstraint(obj,paramConstraint)

            if obj.mState~=Sldv.SessionState.MdlCompSuccess&&...
                obj.mState~=Sldv.SessionState.AnalysisSuccess&&...
                obj.mState~=Sldv.SessionState.AnalysisFailure&&...
                obj.mState~=Sldv.SessionState.ResultsSuccess&&...
                obj.mState~=Sldv.SessionState.ResultsFailure

                constraintId=-1;
                error('Sldv:Session:addParamConstraint','Cannot add parameter constraint. Either session is invalid or model is not successfully compiled yet.');
                return;
            end
            [~,constraintId]=evalc('obj.mTestComp.addParamConstraint(paramConstraint)');
        end

        function status=deleteParamConstraint(obj,constraintId)

            if obj.mState~=Sldv.SessionState.MdlCompSuccess&&...
                obj.mState~=Sldv.SessionState.AnalysisSuccess&&...
                obj.mState~=Sldv.SessionState.AnalysisFailure&&...
                obj.mState~=Sldv.SessionState.ResultsSuccess&&...
                obj.mState~=Sldv.SessionState.ResultsFailure

                status=false;
                error('Sldv:Session:deleteParamConstraint','Cannot delete parameter constraint. Either session is invalid or model is not successfully compiled yet.');
                return;
            end
            [~,status]=evalc('obj.mTestComp.deleteParamConstraint(constraintId)');
        end

        function status=enableParamConstraint(obj,constraintId)

            if obj.mState~=Sldv.SessionState.MdlCompSuccess&&...
                obj.mState~=Sldv.SessionState.AnalysisSuccess&&...
                obj.mState~=Sldv.SessionState.AnalysisFailure&&...
                obj.mState~=Sldv.SessionState.ResultsSuccess&&...
                obj.mState~=Sldv.SessionState.ResultsFailure

                status=false;
                error('Sldv:Session:enableParamConstraint','Cannot enable parameter constraint. Either session is invalid or model is not successfully compiled yet.');
                return;
            end
            [~,status]=evalc('obj.mTestComp.enableParamConstraint(constraintId)');
        end

        function status=disableParamConstraint(obj,constraintId)

            if obj.mState~=Sldv.SessionState.MdlCompSuccess&&...
                obj.mState~=Sldv.SessionState.AnalysisSuccess&&...
                obj.mState~=Sldv.SessionState.AnalysisFailure&&...
                obj.mState~=Sldv.SessionState.ResultsSuccess&&...
                obj.mState~=Sldv.SessionState.ResultsFailure

                status=false;
                error('Sldv:Session:disableParamConstraint','Cannot disable parameter constraint. Either session is invalid or model is not successfully compiled yet.');
                return;
            end
            [~,status]=evalc('obj.mTestComp.disableParamConstraint(constraintId)');
        end

        function listParamConstraints(obj)

            if obj.mState~=Sldv.SessionState.MdlCompSuccess&&...
                obj.mState~=Sldv.SessionState.AnalysisSuccess&&...
                obj.mState~=Sldv.SessionState.AnalysisFailure&&...
                obj.mState~=Sldv.SessionState.ResultsSuccess&&...
                obj.mState~=Sldv.SessionState.ResultsFailure

                error('Sldv:Session:listParamConstraints','Cannot list parameter constraints. Either session is invalid or model is not successfully compiled yet.');
                return;
            end
            obj.mTestComp.listParamConstraints();
        end
    end

    methods(Access=private)




        [status,msg,stopped]=setupAnalysis(obj,testStrategyName);
        [status,msg,fileNames]=generateAnalysisResults(obj,testComp,status,msg,fileNames);



        throwWarningsForDeprecatedOptions(obj);
    end

    methods(Access=public,Hidden)

        function tc=getTestComp(obj)
            tc=obj.mTestComp;
        end


        function releaseTestComp(obj)
            obj.deleteTestComponent();
        end


        function notifyAsyncAnalysisDone(obj,~,~)
            obj.notify('AsyncAnalysisDone');
        end

        function setSldvOuputsPath(obj,mdlPathInSldvOutputs)
            if contains(path(),mdlPathInSldvOutputs)


                return;
            end
            obj.mMdlPathInSldvOuputs=mdlPathInSldvOutputs;
            addpath(obj.mMdlPathInSldvOuputs);
        end
    end

    methods(Access=public,Hidden)
        function setSldvChecksumMode(obj,val)
            if isa(val,'Sldv.ChecksumMode')
                obj.mSldvChecksumMode=val;
            end
        end
        function check=getSldvChecksumMode(obj)
            check=obj.mSldvChecksumMode;
        end
        function setObserverTranslationInfo(obj,modelName,translationInfo)
            if isempty(obj.mObserverTranslationInfo)
                obj.mObserverTranslationInfo=containers.Map('KeyType','double','ValueType','any');
            end
            obj.mObserverTranslationInfo(modelName)=translationInfo;
        end
        function translationInfo=getObserverTranslationInfo(obj,modelH)
            assert(isKey(obj.mObserverTranslationInfo,modelH));
            translationInfo=obj.mObserverTranslationInfo(modelH);
        end
        function addToIncompatObserverList(obj,modelH)
            obj.mIncompatObserverMdlHs=[obj.mIncompatObserverMdlHs,modelH];
        end
        function status=checkIfObserverIsCompatible(obj,modelH)
            status=false;
            if~any(ismember(obj.mIncompatObserverMdlHs,modelH))
                status=true;
            end
        end
        function client=getClient(obj)
            client=obj.mClient;
        end
        function addStubbedSimulinkFcnInfo(obj,stubbedSimulinkFcnInfo)
            if~isempty(obj.mTestComp)


                obj.mTestComp.analysisInfo.stubbedSimulinkFcnInfo=stubbedSimulinkFcnInfo;
            end
        end
    end


    methods(Access=public,Hidden)
        function setMockLogPath(obj,LogPath)

            obj.mMockResultsFullFileName=LogPath;
        end

        function mockPath=getMockLogPath(obj)
            mockPath=obj.mMockResultsFullFileName;
        end
    end
end


