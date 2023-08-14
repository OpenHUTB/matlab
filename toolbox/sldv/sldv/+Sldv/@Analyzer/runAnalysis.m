




function[status,msg,resultFileNames]=runAnalysis(obj,analysisInput)
    assert(~isempty(obj.mTestComp));




    if nargin<2
        analysisInput=[];
    end

    status=1;
    obj.mAnalysisErrorMsg=[];
    msg=obj.mAnalysisErrorMsg;
    resultFileNames=Sldv.Utils.initDVResultStruct();


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


    obj.waitForAnalysisDone();


    status=obj.getAnalysisStatus();
    msg=obj.mAnalysisErrorMsg;
    resultFileNames=obj.mResultFileNames;

    return;
end
