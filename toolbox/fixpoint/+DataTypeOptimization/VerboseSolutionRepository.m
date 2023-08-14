classdef VerboseSolutionRepository<DataTypeOptimization.SolutionRepository&DataTypeOptimization.VerboseActions





    methods
        function this=VerboseSolutionRepository(logger)

            this=this@DataTypeOptimization.VerboseActions(logger);
            this=this@DataTypeOptimization.SolutionRepository();

        end

        function addSolution(this,newSolution,solutionType)




            bestSolutionID=this.bestSolution.id;


            addSolution@DataTypeOptimization.SolutionRepository(this,newSolution,solutionType);



            if~strcmp(bestSolutionID,this.bestSolution.id)
                if this.bestSolution.Pass&&this.bestSolution.isFullySpecified
                    messageLog=message('SimulinkFixedPoint:dataTypeOptimization:newLocalOptimalSolution',...
                    sprintf('%i',this.bestSolution.Cost)).getString;
                    this.publish(messageLog,DataTypeOptimization.VerbosityLevel.High);
                end

            end
        end
    end
end