function validatedSldvData=validate(obj,testCasestoValidate,useParallel)




    validatedSldvData=[];%#ok<NASGU>



    if~isfield(obj.sldvData,'TestCases')
        validatedSldvData=obj.sldvData;
        return;
    end

    if nargin<2
        testCasestoValidate=obj.sldvData.TestCases;
    end

    if nargin<3
        useParallel=false;
    end

    numTestCases=length(testCasestoValidate);



    objIndices=cell(1,numTestCases);

    try
        obj.initialize(useParallel);
    catch Mex %#ok<NASGU>


        validatedSldvData=obj.sldvData;
        return;
    end

    for testCaseId=1:numTestCases
        testCase=testCasestoValidate(testCaseId);
        objIndices{testCaseId}=[];

        for objNum=1:length([testCase.objectives])
            objectiveIdx=testCase.objectives(objNum).objectiveIdx;
            objIndices{testCaseId}=[objIndices{testCaseId},objectiveIdx];
        end
    end

    simData=obj.simulateTestCases(testCasestoValidate);

    if isa(simData,'Simulink.Simulation.Future')
        wait(simData);
    end

    objectivesWithStatus=obj.verifyTestCases(simData,objIndices);

    for simNum=1:length(simData)
        currentObjectivesWithStatus=objectivesWithStatus{simNum};
        for objNum=1:length(currentObjectivesWithStatus)
            goal=obj.objectiveToGoalMap(currentObjectivesWithStatus(objNum).objective);
            obj.updateStatus(currentObjectivesWithStatus(objNum),goal.status);
        end
    end

    obj.restore();
    validatedSldvData=obj.sldvData;
end
