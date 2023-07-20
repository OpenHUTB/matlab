function simData=simulateAssertions(obj,objectives,counterExamples,modelToSimulate)%#ok<INUSD>




    numCEs=length(counterExamples);
    totalObjectives=0;
    AssertionBlocks=cell(1,numCEs);
    mapValues={};
    simDataIdToObjectiveIdMap=containers.Map('KeyType','double','ValueType','any');



    for ceIdx=1:numCEs
        AssertionBlocks{ceIdx}=[];
        currentObjectives=objectives{ceIdx};
        for oIdx=1:length(currentObjectives)
            totalObjectives=totalObjectives+1;
            currentBlk=obj.getOrigBlock(obj.objectiveToGoalMap(currentObjectives(oIdx)));
            AssertionBlocks{ceIdx}=[AssertionBlocks{ceIdx},struct('Handle',sldvprivate('get_sldv_block',currentBlk),'Type',obj.sldvData.Objectives(currentObjectives(oIdx)).type)];
            mapValues(totalObjectives)={[counterExamples(ceIdx).testCaseId,currentObjectives(oIdx)]};%#ok<AGROW>
        end
    end

    try

        simData=obj.runTestObj.runSimulation(counterExamples,AssertionBlocks);
        if isa(simData,'Simulink.Simulation.Future')
            for simIdx=1:length(simData)
                simDataIdToObjectiveIdMap(simData(simIdx).ID)=mapValues{simIdx};
            end
        else
            for simIdx=1:length(simData)
                simDataIdToObjectiveIdMap(simIdx)=mapValues{simIdx};
            end
        end
        obj.simDataMapForObjectives.AssertObjectives=simDataIdToObjectiveIdMap;
    catch Mex %#ok<NASGU>




        simData=repmat(-1,1,totalObjectives);
        obj.simDataMapForObjectives.AssertObjectives=containers.Map('KeyType','double','ValueType','any');
    end
end
