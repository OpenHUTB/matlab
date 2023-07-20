



function assessmentSignals=getAssessmentSignals(simWatcher)
    assessmentSignals=[];
    try
        assessmentsID=stm.internal.getAssessmentsID(simWatcher.testCaseId);
    catch
        return;
    end
    if assessmentsID>=0
        assessmentsInfo=stm.internal.getAssessmentsInfo(assessmentsID);
        simIdx=stm.internal.util.getSimulationIndex(simWatcher);
        assessmentSignals=sltest.assessments.internal.getLoggedSignalsFromMappingInfo(...
        assessmentsInfo,simIdx,simWatcher.modelToRun);
    end
end
