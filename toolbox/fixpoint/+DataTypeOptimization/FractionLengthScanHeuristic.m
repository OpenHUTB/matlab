classdef FractionLengthScanHeuristic<DataTypeOptimization.AbstractHeuristic

    methods
        function this=FractionLengthScanHeuristic(problemPrototype,tracer)
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

                this.performBinarySearch(domainIntersection,evaluationService,solutionRepo);
            end
        end

        function performBinarySearch(this,domainIntersection,evaluationService,solutionRepo)

            minIndex=1;
            maxIndex=length(domainIntersection);

            while this.advance()

                bestSolution=solutionRepo.getBestSolution;
                if bestSolution.Pass&&bestSolution.isFullySpecified
                    break;
                end

                currentSolution=solutionRepo.getEmptySolution();



                midIndex=ceil((maxIndex+minIndex)/2);
                midPoint=domainIntersection(midIndex);
                for dIndex=1:length(this.problemPrototype.dv)
                    midPointIndex=this.problemPrototype.dv(dIndex).definitionDomain.fractionWidthVector==midPoint;
                    domainIndex=find(midPointIndex);
                    currentSolution.definitionDomainIndex(dIndex)=domainIndex(1);
                end


                if~solutionRepo.solutionExists(currentSolution)

                    currentSolution=evaluationService.evaluateSolutions(currentSolution);

                    solutionRepo.addSolution(currentSolution,DataTypeOptimization.SolutionType.FirstFeasible);
                else

                    currentSolution=solutionRepo.solutions(currentSolution.id);
                end

                if currentSolution.Pass


                    maxIndex=midIndex;
                else

                    minIndex=midIndex;
                end


                if maxIndex-minIndex<=1
                    break
                end
            end
        end
    end
end
