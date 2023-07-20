




function[validatedTestCases,futureData,noopValidatedTcIdx]=validateIncremental(obj,testCases)
    validatedTestCases=[];%#ok<NASGU>




    obj.clearSimulationData;
    simData=obj.simulateIncremental(testCases);
    if isa(simData,'Simulink.Simulation.Future')
        validatedTestCases=testCases(obj.noopValidatedTcIdx);
        futureData=simData;
        noopValidatedTcIdx=obj.noopValidatedTcIdx;
        return;
    end
    futureData=[];
    noopValidatedTcIdx=[];
    validatedTestCases=obj.verifyIncremental(simData,testCases);
    return;
end
