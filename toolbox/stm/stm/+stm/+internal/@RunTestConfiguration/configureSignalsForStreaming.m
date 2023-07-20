




function msgList=configureSignalsForStreaming(obj,simWatcher)

    msgList={};
    assessmentsSignals=stm.internal.MRT.share.getAssessmentSignals(simWatcher);

    if isempty(obj.testSettings.signalLogging)&&isempty(assessmentsSignals)
        return;
    end

    if~isempty(obj.testSettings.signalLogging)
        bFromIteration=obj.testSettings.signalLogging.fromIteration;
        loggedSignals=obj.testSettings.signalLogging.loggedSignals;
    else
        bFromIteration=false;
        loggedSignals=[];
    end


    loggedSignals=[loggedSignals,assessmentsSignals];

    msgList=stm.internal.RunTestConfiguration.configureSignalsForStreamingHelper(loggedSignals,...
    bFromIteration,obj.modelToRun,simWatcher);
end
