function validatedSldvData=validate(obj,counterExamplestoValidate,useParallel)




    validatedSldvData=[];%#ok<NASGU>
    simData=[];

    if~isfield(obj.sldvData,'CounterExamples')
        validatedSldvData=obj.sldvData;
        return;
    end

    if nargin<2
        counterExamplestoValidate=obj.sldvData.CounterExamples;
    end

    if nargin<3
        useParallel=false;
    end

    numCEs=length(counterExamplestoValidate);



    objIndices=cell(1,numCEs);

    try
        obj.initialize(useParallel);
    catch Mex %#ok<NASGU>


        validatedSldvData=obj.sldvData;
        return;
    end

    for ceId=1:numCEs



        obj.clearSimulationData;
        counterExample=counterExamplestoValidate(ceId);
        objIndices{ceId}=[];

        for objNum=1:length([counterExample.objectives])
            objectiveIdx=counterExample.objectives(objNum).objectiveIdx;
            objIndices{ceId}=[objIndices{ceId},objectiveIdx];
        end
    end
    obj.simulateCounterExamples(counterExamplestoValidate);


    if isfield(obj.simData,"simDataForAssertObjectives")
        simData=[simData,obj.simData.simDataForAssertObjectives];
    end
    if isfield(obj.simData,"simDataForProofObjectives")
        simData=[simData,obj.simData.simDataForProofObjectives];
    end
    if isa(simData,'Simulink.Simulation.Future')
        wait(simData);
    end

    objectivesWithStatus=obj.verifyCounterExamples();
    for statusIdx=1:numel(objectivesWithStatus)
        validatedCeObjId=objectivesWithStatus(statusIdx).ceObjId;


        goal=obj.objectiveToGoalMap(validatedCeObjId(2));
        objStatus=struct('objective',[],'status',[]);
        objStatus.objective=validatedCeObjId(2);
        objStatus.status=objectivesWithStatus(statusIdx).status;
        obj.updateStatus(objStatus,goal.status);
    end

    obj.restore();
    validatedSldvData=obj.sldvData;
end

