classdef ObjectiveFactory<handle





    methods(Static)
        function objectiveFunction=getObjective(options,environmentContext,decisionVariables)
            switch options.ObjectiveFunction
            case DataTypeOptimization.Objectives.ObjectiveType.BitWidthSum
                objectiveFunction=DataTypeOptimization.Objectives.BitWidthSumObjective(environmentContext,decisionVariables);
            case DataTypeOptimization.Objectives.ObjectiveType.OperatorCount
                objectiveFunction=DataTypeOptimization.Objectives.OperatorCountObjective(environmentContext,decisionVariables);
            end
        end
    end

end
