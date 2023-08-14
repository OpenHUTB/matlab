



classdef CounterexampleValidatorInDed<Sldv.Validator.Validator
    properties(Hidden=true)
        tcIdx;
        covTcIdx;
        diagValidatationObjectives;
        noopValidatedTcIdx;
        tcObjectiveIndices;
        diagnosticSettingsStruct;
        settingsArray;
    end

    methods
        function obj=CounterexampleValidatorInDed(sldvData,model,objectiveToGoalMap,testcomp,goalIdToObjectiveIdMap)
            obj@Sldv.Validator.Validator(sldvData,model,objectiveToGoalMap,testcomp,goalIdToObjectiveIdMap);
        end

        function validatedStatus=updateStatus(obj,objectiveWithStatus,goalStatus,varargin)



            if nargin>3
                isActiveLogic=varargin{1};
            else
                isActiveLogic=true;
            end
            if slavteng('feature','DedValidation')&&~isActiveLogic
                validatedStatus=obj.updateStatusForDiagnosticObj(objectiveWithStatus,goalStatus);
            else
                validatedStatus=obj.updateStatusForCoverageObjective(objectiveWithStatus,goalStatus);
            end
        end


        function resetSimulationData(obj)
            obj.tcIdx=[];
            obj.noopValidatedTcIdx=[];
            obj.tcObjectiveIndices=[];
        end

        success=verifyDiagnostic(obj,executionInfo,objData);
        checkObj=getCheckObject(obj,objData);
        validatedGoalStatus=updateStatusForDiagnosticObj(obj,objectiveWithStatus,currentGoalStatus)
    end

    methods(Static)
        function runOpts=getRunOpts(model,sldvData)

            runOpts=Sldv.Validator.TestcaseValidator.getRunOpts(model,sldvData);
        end
    end
end

