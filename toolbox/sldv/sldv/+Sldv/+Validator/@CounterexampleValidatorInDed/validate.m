function validatedSldvData=validate(obj,counterExamplesToValidate,useParallel)






    if~isfield(obj.sldvData,'CounterExamples')
        validatedSldvData=obj.sldvData;
        return;
    end

    if nargin<2
        counterExamplesToValidate=obj.sldvData.TestCases;
    end

    if nargin<3
        useParallel=false;
    end

    counterExamplesToValidate=filterOutNonActiveLogicTCs(obj,counterExamplesToValidate);

    numTestCases=length(counterExamplesToValidate);



    objIndices=cell(1,numTestCases);

    try
        obj.initialize(useParallel);
    catch Mex %#ok<NASGU>


        validatedSldvData=obj.sldvData;
        return;
    end

    for testCaseId=1:numTestCases
        testCase=counterExamplesToValidate(testCaseId);
        objIndices{testCaseId}=[];

        for objNum=1:length([testCase.objectives])
            objectiveIdx=testCase.objectives(objNum).objectiveIdx;
            objIndices{testCaseId}=[objIndices{testCaseId},objectiveIdx];
        end
    end

    activeLogicValidator=Sldv.Validator.TestcaseValidator(obj.sldvData,...
    obj.modelH,obj.objectiveToGoalMap,obj.testComp,[],obj.runTestObj);

    simData=activeLogicValidator.simulateTestCases(counterExamplesToValidate);

    if isa(simData,'Simulink.Simulation.Future')
        wait(simData);
    end

    objectivesWithStatus=activeLogicValidator.verifyTestCases(simData,objIndices);







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

function counterExamplesToValidate=filterOutNonActiveLogicTCs(obj,counterExamplesToValidate)
    activeLogicIds=false(length(counterExamplesToValidate));

    for i=1:length(counterExamplesToValidate)
        objectives=[counterExamplesToValidate(i).objectives.objectiveIdx];
        if any(strcmp('Active Logic - needs simulation',{obj.sldvData.Objectives(objectives).status}))
            activeLogicIds(i)=true;
        end
    end

    counterExamplesToValidate=counterExamplesToValidate(activeLogicIds);
end
