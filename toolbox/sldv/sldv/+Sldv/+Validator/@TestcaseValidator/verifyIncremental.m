




function validatedTestCases=verifyIncremental(obj,simData,testCases)
    validatedTestCases=[];%#ok<NASGU>
    testComp=obj.testComp;
    futureIdToTcIdxMap=obj.FutureIdMapForTestcases;

    if isa(simData,'Simulink.Simulation.Future')
        currTcIdxToProcess=values(futureIdToTcIdxMap,{simData.ID});
        tcObjIdx=obj.tcObjectiveIndices([currTcIdxToProcess{:}]);
    else
        currTcIdxToProcess=num2cell(obj.tcIdx);
        tcObjIdx=obj.tcObjectiveIndices;
    end

    [objectivesWithStatus,simOut,cvData]=obj.verifyTestCases(simData,tcObjIdx);
    for simNum=1:length(simData)
        testCases(currTcIdxToProcess{simNum}).simoutData=simOut{simNum};
        testCases(currTcIdxToProcess{simNum}).covData=cvData{simNum};

        currentObjectivesWithStatus=objectivesWithStatus{simNum};
        for objNum=1:length(currentObjectivesWithStatus)
            goal=obj.objectiveToGoalMap(currentObjectivesWithStatus(objNum).objective);
            goalId=goal.getGoalMapId();
            tcId=testCases(currTcIdxToProcess{simNum}).getId();

            goalResult=obj.testComp.getGoalResult(goalId,tcId);
            validateStatus=obj.updateStatus(currentObjectivesWithStatus(objNum),goalResult.status);
            force=false;
            testComp.updateValidatedGoals(goalId,string(validateStatus),force,tcId);
        end
    end

    validatedTestCases=testCases;

    return;
end
