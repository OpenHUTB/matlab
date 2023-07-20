classdef ParallelGuidedDescentHeuristic<DataTypeOptimization.ParallelRandomizedDescentHeuristic












    methods(Hidden)
        function initialize(this,solutionRepo)
            this.solutionRepo=solutionRepo;



            nsHeuristics={};

            for pT=.05:.05:.15
                for depth=1:3
                    for breadth=1:3
                        nsHeuristics{end+1}=DataTypeOptimization.MetaHeuristics.SuccessProbabilityRandomPerturbation(...
                        [-min(depth,numel(this.problemPrototype.gddm)),0],...
                        min(breadth,numel(this.problemPrototype.dv)),...
                        numel(this.problemPrototype.dv),...
                        solutionRepo,...
                        pT);%#ok<*AGROW>
                    end
                end
            end



            this.heuristicsScheduler=DataTypeOptimization.MetaHeuristics.HeuristicsScheduler(nsHeuristics);
        end

    end

end