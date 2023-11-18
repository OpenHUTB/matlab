classdef DimensionalityReduction<DataTypeOptimization.AbstractHeuristic

    properties(SetAccess=private)
dimensionalityReductionStrategies
    end

    methods
        function this=DimensionalityReduction(problemPrototype,options)
            this.problemPrototype=problemPrototype;
            this.registerStrategies(options);
        end

        function run(this,evaluationService,solutionRepo)
            for sIndex=1:numel(this.dimensionalityReductionStrategies)

                currentSolution=solutionRepo.cloneSolution(solutionRepo.getBestSolution());


                currentSolution=this.dimensionalityReductionStrategies{sIndex}.processSolution(currentSolution,this.problemPrototype,evaluationService);

                if currentSolution.isFullySpecified

                    currentSolution=evaluationService.evaluateSolutions(currentSolution);


                    solutionRepo.addSolution(currentSolution,DataTypeOptimization.SolutionType.DimensionalityReduction);
                end
            end
        end

        function canAdvance=advance(~)
            canAdvance=true;
        end
    end

    methods(Hidden)
        function registerStrategies(this,options)
            if~options.AdvancedOptions.PerformSlopeBiasCancellation
                this.dimensionalityReductionStrategies={DataTypeOptimization.DimensionalityReductionStrategies.BinaryPointScaling()};
                if~isequal(options.ObservedPrecisionReduction,DataTypeOptimization.ObservedPrecisionLevel.Inactive)
                    this.dimensionalityReductionStrategies{end+1}=DataTypeOptimization.DimensionalityReductionStrategies.ObservedPrecision();
                end
            else
                trySlopeBiasCancellation=DataTypeOptimization.DimensionalityReductionStrategies.FallbackOnFailure(...
                DataTypeOptimization.DimensionalityReductionStrategies.SlopeBiasCancellation(),...
                DataTypeOptimization.DimensionalityReductionStrategies.BinaryPointScaling());
                this.dimensionalityReductionStrategies={trySlopeBiasCancellation};
            end
        end
    end

end
