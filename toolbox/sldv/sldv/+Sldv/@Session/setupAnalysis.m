



function[status,msg,stopped]=setupAnalysis(obj,testStrategyName)
    status=1;
    msg='';
    stopped=false;

    if nargin<2
        testStrategyName=[];
    end

    if obj.mStandaloneCompat
        addpath(obj.mMdlPathInSldvOuputs);
        obj.mStandaloneCompat=false;
    end

    testComp=obj.mTestComp;



    Simulink.observer.internal.loadObserverModelsForBD(testComp.analysisInfo.analyzedModelH);



    if(Sldv.SessionState.AnalysisSuccess==obj.mState)||...
        (Sldv.SessionState.AnalysisFailure==obj.mState)||...
        (Sldv.SessionState.ResultsSuccess==obj.mState)||...
        (Sldv.SessionState.ResultsFailure==obj.mState)

        [~,reset]=evalc('testComp.resetAnalysisResults()');

        if~reset
            error('Sldv:Session:setupAnalysis','Failed to reset Analysis results');
        end



        obj.mState=Sldv.SessionState.MdlCompSuccess;

        if obj.mShowUI
            hideAnalysisPannel=false;
            sldvprivate('sldvCreateUI',obj.mModelH,testComp,hideAnalysisPannel,...
            get_param(obj.mModelH,'Name'));
        end

    end



    if(Sldv.SessionState.MdlCompSuccess~=obj.mState)
        status=0;
        return;
    end








    if obj.mShowUI
        analysisProgressUI=testComp.progressUI;
        if~isempty(analysisProgressUI)&&ishandle(analysisProgressUI)&&...
            ishandle(analysisProgressUI.dialogH)

            if~analysisProgressUI.hasInfoPanel
                analysisProgressUI.hasInfoPanel=true;
                analysisProgressUI.finalized=false;
                analysisProgressUI.refreshLogArea();
                analysisProgressUI.showLogArea();
            end
        else
            hideAnalysisPannel=false;
            sldvprivate('sldvCreateUI',obj.mModelH,testComp,hideAnalysisPannel,...
            get_param(obj.mModelH,'Name'));
        end
    end



    obj.mSldvToken.setTestComponent(testComp);


    sldvshareprivate('avtcgirunsupcollect','clear',obj.mModelH);



    stopped=obj.handleStopRequest('Sldv:SldvRun:DVWasStopped');
    if stopped
        return
    end

    obj.throwWarningsForDeprecatedOptions();

    obj.mSldvAnalyzer=Sldv.Analyzer(obj.mModelH,obj.mBlockH,obj.mBlockPathObj,obj.mSldvOpts,...
    obj.mShowUI,obj.mInitCovData,testComp);


    [status,msg]=obj.mSldvAnalyzer.loadExistingTestCases();
    if~status



        if obj.mShowUI
            testComp.progressUI.finalized=true;
            testComp.progressUI.refreshLogArea();
            testComp.progressUI.showLogArea();
        end
        return;
    end

    stopped=obj.handleStopRequest('Sldv:SldvRun:DVWasStopped');
    if stopped
        return;
    end

    obj.mAnalysisStrategy=obj.createAnalysisStrategy(testStrategyName);


    obj.setupAnalysisTasks();
end
