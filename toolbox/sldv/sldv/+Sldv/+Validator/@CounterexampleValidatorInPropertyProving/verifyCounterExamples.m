function objWithValidationStatus=verifyCounterExamples(obj,varargin)




    futureObjects=[];
    if~isempty(varargin)
        futureObjects=varargin{1};
    end
    objWithValidationStatus=[];

    assertCeObjIdx={};
    proofCeObjIdx={};
    if~isempty(futureObjects)
        if isfield(obj.simDataMapForObjectives,"AssertObjectives")
            assertObjFutureIdx=isKey(obj.simDataMapForObjectives.AssertObjectives,{futureObjects(:).ID});
            assertObjSimData=futureObjects(assertObjFutureIdx);
            if~isempty(assertObjSimData)
                assertCeObjIdx=values(obj.simDataMapForObjectives.AssertObjectives,{assertObjSimData(:).ID});
            end
        end
        if isfield(obj.simDataMapForObjectives,"ProofObjectives")
            proofObjFutureIdx=isKey(obj.simDataMapForObjectives.ProofObjectives,{futureObjects(:).ID});
            proofObjSimData=futureObjects(proofObjFutureIdx);
            if~isempty(proofObjSimData)
                proofCeObjIdx=values(obj.simDataMapForObjectives.ProofObjectives,{proofObjSimData(:).ID});
            end
        end
    else
        if isfield(obj.simDataMapForObjectives,"AssertObjectives")
            assertCeObjIdx=values(obj.simDataMapForObjectives.AssertObjectives);
            assertObjSimData=obj.simData.simDataForAssertObjectives;
        end
        if isfield(obj.simDataMapForObjectives,"ProofObjectives")
            proofCeObjIdx=values(obj.simDataMapForObjectives.ProofObjectives);
            proofObjSimData=obj.simData.simDataForProofObjectives;
        end
    end

    if~isempty(assertCeObjIdx)
        assertObjectiveStatus=obj.verifyAssertions(assertCeObjIdx,assertObjSimData);
        objWithValidationStatus=[objWithValidationStatus,assertObjectiveStatus];
    end

    if~isempty(proofCeObjIdx)
        proofObjectiveStatus=obj.verifyProofObjectives(proofCeObjIdx,proofObjSimData);
        objWithValidationStatus=[objWithValidationStatus,proofObjectiveStatus];
    end
end
