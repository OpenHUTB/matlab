function[status,msg]=preAnalysis(obj)






    assert(Sldv.AnalysisStatus.Running~=obj.mAnalysisStatus);

    status=1;
    msg=[];
    testComp=obj.mTestComp;



    if sldvprivate('isTaskingArchitectureEnabled')

        [obj.mStrategy,obj.mSearchDepth]=...
        sldvprivate('mdl_get_analysis_settings',testComp);
    else
        [obj.mStrategy,obj.mSearchDepth,obj.mTimeLimit]=...
        sldvprivate('mdl_get_analysis_settings',testComp);

    end


    testComp.profileStage(sldvprivate('sldv_get_strategy_name',testComp));
    testComp.getMainProfileLogger().openPhase(sldvprivate('sldv_get_strategy_name',testComp));
















    if(Sldv.AnalysisStatus.Init~=obj.mAnalysisStatus)
        if(strcmp(testComp.activeSettings.Mode,'TestGeneration')&&...
            strcmp(testComp.activeSettings.ExtendExistingTests,'on'))

            [status,mex]=obj.loadTestCases(testComp.activeSettings.ExistingTestFile);

            if~status
                return;
            end
        end
    end








    obj.mAsyncAnalysisDone=false;
    obj.mAsyncAnalysisFinished=false;
    obj.mAnalysisStatus=Sldv.AnalysisStatus.Running;





    obj.mTimeOutListener=event.listener(obj.mAnalysisTimer,'Executing',...
    @(timer,eventData)obj.analysisTimerCB(timer,eventData));

    start(obj.mAnalysisTimer);
    obj.mAnalysisStartTime=clock;

    return;

end
