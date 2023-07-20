function objStatus=verifyAssertions(obj,ceObjIdx,simData)



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
                [simData,~]=obj.runTestObj.getSimulationResults(simData);
            end
        catch Mex %#ok<NASGU>
            runTestError=true;
            simData=repmat({-1},1,totalSims);
        end

        for currSim=1:totalSims
            currCeObjId=ceObjIdx{currSim};




            objStatus(currSim).ceObjId=currCeObjId;
            objStatus(currSim).status=Sldv.Validator.ValidationStatus.Inconclusive;

            if~runTestError&&~isempty(simData{currSim}.ErrorMessage)
                if obj.findError(simData{currSim}.SimulationMetadata.ExecutionInfo.ErrorDiagnostic.Diagnostic,'Simulink:blocks:AssertionAssert')
                    objStatus(currSim).status=Sldv.Validator.ValidationStatus.Success;
                end
            end

            if objStatus(currSim).status~=Sldv.Validator.ValidationStatus.Success
                if runTestError||~isempty(simData{currSim}.ErrorMessage)
                    objStatus(currSim).status=Sldv.Validator.ValidationStatus.RuntimeError;
                end
            end
        end

    catch Mex %#ok<NASGU>
        return
    end
end

