classdef HeuristicsFactory<handle




    methods(Static)
        function heuristic=getHeuristic(heuristicType,problemPrototype,tracer,options)
            if nargin<4
                options='';
            end

            if nargin<3
                tracer='';
            end

            switch(heuristicType)
            case 'dimensionalityReduction'
                heuristic=DataTypeOptimization.DimensionalityReduction(problemPrototype,options);
            case 'fullscan'
                heuristic=DataTypeOptimization.FullScanHeuristic(problemPrototype,tracer);
            case 'fractionlengthscan'
                heuristic=DataTypeOptimization.FractionLengthScanHeuristic(problemPrototype,tracer);
            case 'greedy'
                heuristic=DataTypeOptimization.GreedyHeuristic(problemPrototype,tracer);
            case 'randomizedSearch'
                heuristic=DataTypeOptimization.RandomizedHeuristic(problemPrototype,tracer);
            case 'parallelfullscan'
                heuristic=DataTypeOptimization.ParallelFullScanHeuristic(problemPrototype,tracer);
            case 'parallelfractionlengthscan'
                heuristic=DataTypeOptimization.ParallelFractionLengthScanHeuristic(problemPrototype,tracer);
            case 'parallelrandomizeddescent'
                heuristic=DataTypeOptimization.ParallelRandomizedDescentHeuristic(problemPrototype,tracer,10);
            case 'parallelguideddescent'
                heuristic=DataTypeOptimization.ParallelGuidedDescentHeuristic(problemPrototype,tracer,10);
            case 'parallelrandomized'
                heuristic=DataTypeOptimization.ParallelRandomizedHeuristic(problemPrototype,tracer,Inf);
            end
        end
    end
end


