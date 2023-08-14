function runInfo=populateRunInfo(simInputs)
    tc=sltest.testmanager.TestCase([],simInputs.TestCaseId);
    runInfo.runId=simInputs.ResultUUID;
    runInfo.runName=simInputs.IterationName;
    if isempty(runInfo.runName)
        runInfo.runName=tc.Name;
    end


    if~isempty(simInputs.IterationId)&&(simInputs.IterationId>0)
        props=stm.internal.getTestIterationProperty(simInputs.IterationId);
        runInfo.testId=props.uuid;
    else
        runInfo.testId=tc.UUID;
    end
end