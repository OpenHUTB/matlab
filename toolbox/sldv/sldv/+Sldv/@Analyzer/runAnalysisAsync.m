




function[status,msg]=runAnalysisAsync(obj,analysisInput)
    assert(~isempty(obj.mTestComp));




    if nargin<2
        analysisInput=[];
    end








    if isfield(analysisInput,'goals')
        enabledGoals=analysisInput.goals;
        enabledDvIds=arrayfun(@(goal)...
        double(obj.mGoalIdToDvIdMap(goal)),enabledGoals);
        analysisInput.goals=enabledDvIds;
    end

    status=1;
    obj.mAnalysisErrorMsg=[];
    msg=obj.mAnalysisErrorMsg;


    [status,msg]=obj.preAnalysis();
    if~status
        obj.mAnalysisStatus=Sldv.AnalysisStatus.Failure;
        obj.mAnalysisErrorMsg=msg;
        obj.postAnalysis();
        status=obj.getAnalysisStatus();
        return;
    end







    analysisListener=obj;
    launchStatus=obj.mTestComp.launchAnalysis(obj.mStrategy,obj.mSearchDepth,obj.mTimeLimit,...
    analysisInput,analysisListener);





    if~isempty(launchStatus)
        obj.mAnalysisStatus=obj.processBackendAnalysisStatus(launchStatus);
        obj.postAnalysis();
        status=obj.getAnalysisStatus();


        return;
    end

    obj.mAnalysisStatus=Sldv.AnalysisStatus.Running;


    notify(obj,'AsyncAnalysisLaunched');

    assert(Sldv.AnalysisStatus.Running==obj.mAnalysisStatus);
    return;
end
