function simData=simulateProofObjectives(obj,objectives,counterExamples,modelToSimulate)%#ok<INUSD>




    numCEs=length(counterExamples);
    totalSims=0;
    ProofBlocks=cell(1,numCEs);
    mapValues={};
    modelProofObjGoals=containers.Map('KeyType','char','ValueType','any');
    simDataIdToObjectiveIdMap=containers.Map('KeyType','double','ValueType','any');
    noOpIdx={};




    for ceIdx=1:numCEs
        ProofBlocks{ceIdx}=[];
        currentObjectives=objectives{ceIdx};
        for oIdx=1:length(currentObjectives)
            ceObjIdx=[counterExamples(ceIdx).testCaseId,currentObjectives(oIdx)];
            modelProofObjGoals(mat2str(ceObjIdx))=obj.objectiveToGoalMap(currentObjectives(oIdx)).up;
            if modelProofObjGoals(mat2str(ceObjIdx)).sfObjID>0
                ProofBlocks{ceIdx}=[ProofBlocks{ceIdx},struct('Handle','','Type','')];
            else
                currentBlk=obj.getOrigBlock(obj.objectiveToGoalMap(currentObjectives(oIdx)));
                currentSldvBlk=sldvprivate('get_sldv_block',currentBlk);






                blkParams=get_param(currentSldvBlk,'ObjectParameters');
                if~isfield(blkParams,'enableStopSim')
                    status=Sldv.Validator.ValidationStatus.Unvalidated;
                    obj.updateObjectiveStatus(ceObjIdx,status);
                    noOpIdx(end+1)={ceObjIdx};%#ok<AGROW>
                    continue;
                end

                ProofBlocks{ceIdx}=[ProofBlocks{ceIdx},struct('Handle',currentSldvBlk,'Type',obj.sldvData.Objectives(currentObjectives(oIdx)).type)];
            end
            totalSims=totalSims+1;
            mapValues(totalSims)={ceObjIdx};%#ok<AGROW>
        end
    end

    obj.modelProofObjGoals=modelProofObjGoals;
    obj.noOpIdx=[obj.noOpIdx,noOpIdx];

    oc=onCleanup(@()cleanSetup(obj.runTestObj));
    obj.runTestObj.turnOffFastRestart();

    try
        simData=obj.runTestObj.runSimulation(counterExamples,ProofBlocks);
        if isa(simData,'Simulink.Simulation.Future')
            for simIdx=1:length(simData)
                simDataIdToObjectiveIdMap(simData(simIdx).ID)=mapValues{simIdx};
            end
        else
            for simIdx=1:length(simData)
                simDataIdToObjectiveIdMap(simIdx)=mapValues{simIdx};
            end
        end
        obj.simDataMapForObjectives.ProofObjectives=simDataIdToObjectiveIdMap;
    catch MexSldvProve %#ok<NASGU>




        simData=repmat(-1,1,totalSims);
        obj.simDataMapForObjectives.ProofObjectives=containers.Map('KeyType','double','ValueType','any');
    end
end

function cleanSetup(runTestObj)
    if~isempty(runTestObj)
        runTestObj.turnOnFastRestart();
    end
end
