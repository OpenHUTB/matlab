



function[validatedCounterExamples,futureData,noopValidatedCeIdx]=validateIncremental(obj,testCases)


    futureData=[];
    noopValidatedCeIdx=[];




    obj.resetSimulationData;
    [simData,CEValidator,isActiveLogicTC]=obj.simulateIncremental(testCases);
    if isa(simData,'Simulink.Simulation.Future')
        wait(simData);
    end
    validatedCounterExamples=obj.verifyIncremental(simData,testCases,CEValidator,isActiveLogicTC);
end
