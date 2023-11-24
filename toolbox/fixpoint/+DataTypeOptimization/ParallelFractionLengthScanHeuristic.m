classdef ParallelFractionLengthScanHeuristic<DataTypeOptimization.AbstractHeuristic

    methods
        function this=ParallelFractionLengthScanHeuristic(problemPrototype,tracer)
            this.problemPrototype=problemPrototype;
            this.tracer=tracer;
        end

        function run(this,evaluationService,solutionRepo)

            bestSolution=solutionRepo.getBestSolution;
            if bestSolution.Pass&&bestSolution.isFullySpecified
                return;
            end


            allFractionDomains=arrayfun(@(x)(x.definitionDomain.fractionWidthVector),this.problemPrototype.dv,'UniformOutput',false)';


            domainIntersection=allFractionDomains{1};
            for dIndex=2:numel(allFractionDomains)
                domainIntersection=intersect(domainIntersection,allFractionDomains{dIndex});
            end


            if~isempty(domainIntersection)

                this.scanFractionLengths(domainIntersection,evaluationService,solutionRepo);
            end
        end

        function scanFractionLengths(this,domainIntersection,evaluationService,solutionRepo)
            solutionArray=DataTypeOptimization.OptimizationSolution.empty(numel(domainIntersection),0);
            for sIndex=1:numel(domainIntersection)
                solutionArray(sIndex)=solutionRepo.getEmptySolution();


                currentFractionLength=domainIntersection(sIndex);
                for dIndex=1:length(this.problemPrototype.dv)
                    currentFractionLengthIndex=this.problemPrototype.dv(dIndex).definitionDomain.fractionWidthVector==currentFractionLength;
                    domainIndex=find(currentFractionLengthIndex);
                    solutionArray(sIndex).definitionDomainIndex(dIndex)=domainIndex(1);
                end
            end


            ps=DataTypeOptimization.Parallel.ParallelEvaluationScheduler();
            overloadFactor=3;
            solutionArray=ps.evaluateSolutions(evaluationService,solutionArray,overloadFactor,...
            @(x)(DataTypeOptimization.Parallel.ParallelEvaluationScheduler.stoppingCriteria(x,this.tracer)));

            for sIndex=1:numel(solutionArray)

                solutionRepo.addSolution(solutionArray(sIndex),DataTypeOptimization.SolutionType.FirstFeasible);
            end
        end
    end
end
