classdef ParallelEvaluationScheduler<handle









    properties
numWorkers
    end

    methods
        function this=ParallelEvaluationScheduler()

            this.numWorkers=DataTypeOptimization.Parallel.Utils.getNumberOfParallelWorkers();

        end

        function evaluatedSolutions=evaluateSolutions(this,evaluationService,solutionArray,overloadFactor,stoppingCondition)
            evaluatedSolutions=[];


            solutionsBatch=this.splitSolutions(solutionArray,overloadFactor);


            currentBatch=1;
            while~stoppingCondition(evaluatedSolutions)&&currentBatch<=numel(solutionsBatch)

                currentEvaluatedSolutions=evaluationService.evaluateSolutions(solutionsBatch{currentBatch});

                evaluatedSolutions=[evaluatedSolutions,currentEvaluatedSolutions];%#ok<AGROW>
                currentBatch=currentBatch+1;
            end

        end

    end

    methods(Hidden)
        function solutionsCellArray=splitSolutions(this,solutionArray,overloadFactor)



            batchSize=min(this.numWorkers*overloadFactor,length(solutionArray));



            numBatchSolutions=floor(length(solutionArray)/batchSize);


            solutionsCellArray=cell(numBatchSolutions,1);
            for sIndex=1:numBatchSolutions-1
                batchStart=1+(sIndex-1)*batchSize;
                batchEnd=sIndex*batchSize;
                solutionsCellArray{sIndex}=solutionArray(batchStart:batchEnd);
            end
            solutionsCellArray{numBatchSolutions}=solutionArray((numBatchSolutions-1)*batchSize+1:end);
        end
    end

    methods(Static)
        function shouldStop=stoppingCriteria(solutions,tracer)
            shouldStop=...
            DataTypeOptimization.Parallel.ParallelEvaluationScheduler.feasibleSolutionFound(solutions)||...
            DataTypeOptimization.Parallel.ParallelEvaluationScheduler.tracerStopped(tracer);
        end

        function shouldStop=tracerStopped(tracer)
            shouldStop=~tracer.advance;
        end

        function found=feasibleSolutionFound(solutions)


            found=~isempty(solutions)&&any([solutions.Pass]);
        end
    end

end


