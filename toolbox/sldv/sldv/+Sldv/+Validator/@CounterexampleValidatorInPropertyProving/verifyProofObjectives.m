function objStatus=verifyProofObjectives(obj,ceObjIdx,simData)




    modelProofObjGoals=obj.modelProofObjGoals;
    runTestError=false;
    totalSims=numel(simData);

    assert(numel(ceObjIdx)==totalSims);
    objStatus=struct('ceObjId',{},'status',{});

    try
        try
            if~isa(simData,'Simulink.Simulation.Future')
                runTestError=all(arrayfun(@(eachData)eachData,simData)==-1);
            end

            if runTestError
                simData=repmat({-1},1,totalSims);



            else
                [simData,covData]=obj.runTestObj.getSimulationResults(simData);
            end
        catch Mex %#ok<NASGU>
            runTestError=true;
            simData=repmat({-1},1,totalSims);
        end

        for currSim=1:totalSims
            currCeObjId=ceObjIdx{currSim};




            objStatus(currSim).ceObjId=currCeObjId;
            objStatus(currSim).status=Sldv.Validator.ValidationStatus.Inconclusive;

            if modelProofObjGoals(mat2str(currCeObjId)).sfObjID>0
                if runTestError||~isempty(simData{currSim}.ErrorMessage)
                    objStatus(currSim).status=Sldv.Validator.ValidationStatus.RuntimeError;
                    continue;
                end
                [~,falseCount,noCoverage,isUnvalidated]=obj.validateObjective(obj.objectiveToGoalMap(currCeObjId(2)),covData{currSim});
                if noCoverage
                    objStatus(currSim).status=Sldv.Validator.ValidationStatus.NoCoverage;
                    continue;
                elseif isUnvalidated
                    objStatus(currSim).status=Sldv.Validator.ValidationStatus.Unvalidated;
                    continue;
                end
                if(falseCount>0)
                    objStatus(currSim).status=Sldv.Validator.ValidationStatus.Success;
                else
                    objStatus(currSim).status=Sldv.Validator.ValidationStatus.NotSuccess;
                end
            else
                if~runTestError&&~isempty(simData{currSim}.ErrorMessage)
                    if obj.findError(simData{currSim}.SimulationMetadata.ExecutionInfo.ErrorDiagnostic.Diagnostic,'Simulink:Engine:SLDV_ProofViolation')
                        objStatus(currSim).status=Sldv.Validator.ValidationStatus.Success;
                    end
                end
                if objStatus(currSim).status~=Sldv.Validator.ValidationStatus.Success
                    if runTestError||~isempty(simData{currSim}.ErrorMessage)
                        objStatus(currSim).status=Sldv.Validator.ValidationStatus.RuntimeError;
                    end
                end
            end
        end

    catch Mex %#ok<NASGU>
        return;
    end
end


