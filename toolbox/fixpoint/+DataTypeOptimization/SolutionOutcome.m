classdef SolutionOutcome










    enumeration
FeasibleSolutionFound
NoFeasibleSolutionFound
NoValidSolutionFound
    end

    methods(Static)
        function str=getString(outcome)

            str="";
            switch outcome
            case DataTypeOptimization.SolutionOutcome.FeasibleSolutionFound
                str=message('SimulinkFixedPoint:dataTypeOptimization:engineFinishedFeasibleSolution').getString;

            case DataTypeOptimization.SolutionOutcome.NoFeasibleSolutionFound
                str=message('SimulinkFixedPoint:dataTypeOptimization:engineFinishedNoFeasibleSolution').getString;

            case DataTypeOptimization.SolutionOutcome.NoValidSolutionFound
                str=message('SimulinkFixedPoint:dataTypeOptimization:outcomeNoValidSolution').getString;
            end
        end
    end
end