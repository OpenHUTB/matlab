




function validatedTestCases=verifyIncremental(obj,simData,testCases,CEValidator,isActiveLogicTc)
    validatedTestCases=[];%#ok<NASGU>
    testComp=obj.testComp;
    currTcIdxToProcess=num2cell(obj.tcIdx);
    if(isActiveLogicTc)
        tcObjIdx=obj.tcObjectiveIndices;

        [objectivesWithStatus,simOut,cvData]=CEValidator.verifyTestCases(simData,tcObjIdx);
        for simNum=1:length(simData)
            testCases(currTcIdxToProcess{simNum}).simoutData=simOut{simNum};
            testCases(currTcIdxToProcess{simNum}).covData=cvData{simNum};

            currentObjectivesWithStatus=objectivesWithStatus{simNum};
            for objNum=1:length(currentObjectivesWithStatus)
                tcId=testCases(currTcIdxToProcess{simNum}).getId();
                [goalId,goalResult]=getGoalDetails(obj,currentObjectivesWithStatus(objNum).objective,tcId);

                validateStatus=obj.updateStatus(currentObjectivesWithStatus(objNum),goalResult.status,true);
                force=false;
                testComp.updateValidatedGoals(goalId,string(validateStatus),force,tcId);
            end
        end
    else


        for simNum=1:length(simData)
            tcIdx=testCases(simNum).getId();
            objectivesToValidate=obj.diagValidatationObjectives{simNum};
            for idx=1:length(objectivesToValidate)
                objectiveID=objectivesToValidate(idx);
                objData=obj.sldvData.Objectives(objectiveID);
                success=verifyDiagnostic(obj,simData(simNum).SimulationMetadata.ExecutionInfo,objData);
                [goalId,goalResult]=getGoalDetails(obj,objectiveID,tcIdx);
                if success





                    validateStatus=obj.updateStatus(struct('objective',objectiveID,'status',Sldv.Validator.ValidationStatus.Success),...
                    goalResult.status,false);
                    force=false;
                    testComp.updateValidatedGoals(goalId,string(validateStatus),force,tcIdx);
                end
            end
        end
    end

    validatedTestCases=testCases;

    return;
end

function[goalId,goalResult]=getGoalDetails(obj,objectiveID,tcIdx)


    goal=obj.objectiveToGoalMap(objectiveID);
    goalId=goal.getGoalMapId();
    goalResult=obj.testComp.getGoalResult(goalId,tcIdx);
end
