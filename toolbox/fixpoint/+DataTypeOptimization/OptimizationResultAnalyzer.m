classdef OptimizationResultAnalyzer<handle






    properties(SetAccess=private,GetAccess=private)
optimizationResult
    end

    methods
        function this=OptimizationResultAnalyzer(optimizationResult)

            this.optimizationResult=optimizationResult;
        end

        function state=analyze(this)

            bestSolution=this.optimizationResult.optimizationEngine.solutionsRepository.getBestSolution();



            errorIdentifiersMap=containers.Map();
            if~bestSolution.isValid||~bestSolution.isFullySpecified
                solutionOutcome=DataTypeOptimization.SolutionOutcome.NoValidSolutionFound;
                errorIdentifiersMap=gatherErrorIdentifiers(this);
            else
                if bestSolution.Pass
                    solutionOutcome=DataTypeOptimization.SolutionOutcome.FeasibleSolutionFound;
                else
                    solutionOutcome=DataTypeOptimization.SolutionOutcome.NoFeasibleSolutionFound;
                end
            end


            state=DataTypeOptimization.OptimizationResultState();
            state.solutionOutcome=solutionOutcome;
            state.errorsMap=errorIdentifiersMap;
        end
    end

    methods(Hidden)
        function errorIdentifiers=gatherErrorIdentifiers(this)
            allSolutions=this.optimizationResult.optimizationEngine.solutionsRepository.solutions.values;
            errorIdentifiers=containers.Map();
            for sIndex=1:length(allSolutions)
                for scIndex=1:length(allSolutions{sIndex})
                    errorDiagnostic=allSolutions{sIndex}.simOut(scIndex).simOut.SimulationMetadata.ExecutionInfo.ErrorDiagnostic;
                    if~isempty(errorDiagnostic)
                        identifier=errorDiagnostic.Diagnostic.identifier;
                        errorIdentifiers(identifier)=errorDiagnostic.Diagnostic.message;
                    end
                end
            end
        end
    end
end