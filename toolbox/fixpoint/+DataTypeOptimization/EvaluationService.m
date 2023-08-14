classdef EvaluationService<DataTypeOptimization.ParallelEvaluationService




    methods
        function solutions=evaluateSolutions(this,solutions)
            for sIndex=1:numel(solutions)

                this.getSimulationInputs(solutions(sIndex));


                DataTypeOptimization.Application.ApplyUtil.applyMLFB(this.environmentProxy,this.problemPrototype,solutions(sIndex));


                solutions(sIndex).simOut=sim(solutions(sIndex).simIn,'ShowSimulationManager','off','ShowProgress','off');
                DataTypeOptimization.Parallel.Utils.exportSolutions(solutions(sIndex));
            end
        end
    end

end
