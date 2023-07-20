



function[simData,CEValidator]=simulateTestCases(obj,testCases,modelToSimulate)

    if nargin<3
        modelToSimulate=obj.modelH;
    end

    CEValidator=Sldv.Validator.TestcaseValidator(obj.sldvData,...
    modelToSimulate,obj.objectiveToGoalMap,obj.testComp,[],obj.runTestObj);
    simData=CEValidator.simulateTestCases(testCases,modelToSimulate);
    if isa(simData,'Simulink.Simulation.Future')
        wait(simData);
    end
end
