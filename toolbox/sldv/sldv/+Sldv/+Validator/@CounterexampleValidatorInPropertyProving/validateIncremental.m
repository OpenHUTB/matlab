


function[validatedCounterExamples,futureData,noopValidatedCeIdx]=validateIncremental(obj,counterExamples)
    validatedCounterExamples=[];
    futureData=[];
    noopValidatedCeIdx=[];
    simData=[];




    obj.clearSimulationData;
    obj.simulateIncremental(counterExamples);


    if isfield(obj.simData,"simDataForAssertObjectives")
        simData=[simData,obj.simData.simDataForAssertObjectives];
    end
    if isfield(obj.simData,"simDataForProofObjectives")
        simData=[simData,obj.simData.simDataForProofObjectives];
    end
    if isa(simData,'Simulink.Simulation.Future')
        futureData=simData;
        noopValidatedCeIdx=obj.noOpIdx;
        return;
    end
    obj.verifyIncremental(futureData,counterExamples);
    validatedCounterExamples=counterExamples;
end
