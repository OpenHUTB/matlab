function msgList=configureSignalsForStreaming(modelToRun,simInputs,simWatcher)




    msgList={};


    try
        assessmentsFeature=slfeature('AssessmentRunInCustomCriteria');
    catch
        assessmentsFeature=false;
    end
    if assessmentsFeature
        assessmentsID=stm.internal.getAssessmentsID(simWatcher.testCaseId);
        assessmentsInfo=stm.internal.getAssessmentsInfo(assessmentsID);
        assessmentsSignals=sltest.assessments.internal.getLoggedSignalsFromMappingInfo(assessmentsInfo,stm.internal.util.getSimulationIndex(simWatcher),simWatcher.modelToRun);
    else
        assessmentsSignals=[];
    end


    bFromIteration=false;
    loggedSignalSetId=simInputs.LoggedSignalSetId;
    if(~isempty(simInputs.TestIteration.TestParameter.LoggedSignalSetId))
        loggedSignalSetId=simInputs.TestIteration.TestParameter.LoggedSignalSetId;
        bFromIteration=true;
    end

    loggedSignals=stm.internal.getLoggedSignals(loggedSignalSetId,true,true);


    loggedSignals=[loggedSignals,assessmentsSignals];
    if(isempty(loggedSignals))
        return;
    end

    msgList=stm.internal.RunTestConfiguration.configureSignalsForStreamingHelper(loggedSignals,...
    bFromIteration,modelToRun,simWatcher);
end

