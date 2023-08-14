function simulateCounterExamples(obj,counterExamples,modelToSimulate)




    if nargin<4
        modelToSimulate=obj.modelH;
    end
    simData=struct();
    ceObjectiveIndices=arrayfun(@(counterExample){arrayfun(@(object)object.objectiveIdx,counterExample.objectives)},counterExamples);
    noOpIdx={};


    proofObjectives=struct('ceIdx',{},'objectives',{});
    assertObjectives=struct('ceIdx',{},'objectives',{});

    for ceIdx=1:length(ceObjectiveIndices)
        currentObjectives=ceObjectiveIndices{ceIdx};



        proofObjIdx=length(proofObjectives)+1;
        assertObjIdx=length(assertObjectives)+1;

        proofObjectives(proofObjIdx).ceIdx=ceIdx;
        assertObjectives(assertObjIdx).ceIdx=ceIdx;

        for i=1:length(currentObjectives)
            objIdx=currentObjectives(i);
            if obj.ignoreObjectiveForValidation(objIdx)


                status=Sldv.Validator.ValidationStatus.IgnoredDueToBlockReplacement;
                ceObjIdx=[counterExamples(ceIdx).testCaseId,objIdx];
                obj.updateObjectiveStatus(ceObjIdx,status);
                noOpIdx(end+1)={ceObjIdx};%#ok<AGROW>
            else
                switch obj.sldvData.Objectives(objIdx).type
                case 'Assert'
                    assertObjectives(assertObjIdx).objectives=[assertObjectives(assertObjIdx).objectives,objIdx];
                case 'Proof objective'
                    proofObjectives(proofObjIdx).objectives=[proofObjectives(proofObjIdx).objectives,objIdx];
                case 'Requirements Table Objective'
                    proofObjectives(proofObjIdx).objectives=[proofObjectives(proofObjIdx).objectives,objIdx];
                end
            end
        end

        if isempty(assertObjectives(assertObjIdx).objectives)
            assertObjectives(assertObjIdx)=[];
        end

        if isempty(proofObjectives(proofObjIdx).objectives)
            proofObjectives(proofObjIdx)=[];
        end
    end

    if~isempty(assertObjectives)
        assertCounterExamples=counterExamples([assertObjectives.ceIdx]);
        assertObjIdx={assertObjectives.objectives};
        simData.simDataForAssertObjectives=obj.simulateAssertions(assertObjIdx,assertCounterExamples,modelToSimulate);
    end

    if~isempty(proofObjectives)
        proofCounterExamples=counterExamples([proofObjectives.ceIdx]);
        proofObjIdx={proofObjectives.objectives};
        simData.simDataForProofObjectives=obj.simulateProofObjectives(proofObjIdx,proofCounterExamples,modelToSimulate);
    end





    obj.simData=simData;
    obj.noOpIdx=[obj.noOpIdx,noOpIdx];

end


