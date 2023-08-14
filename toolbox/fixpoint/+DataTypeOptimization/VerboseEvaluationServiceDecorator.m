classdef VerboseEvaluationServiceDecorator<DataTypeOptimization.EvaluationServiceDecorator&DataTypeOptimization.VerboseActions





    methods
        function this=VerboseEvaluationServiceDecorator(evaluationService,logger)

            this=this@DataTypeOptimization.VerboseActions(logger);


            this=this@DataTypeOptimization.EvaluationServiceDecorator(evaluationService);

        end

        function solutions=evaluateSolutions(this,solutions)


            solutions=evaluateSolutions@DataTypeOptimization.EvaluationServiceDecorator(this,solutions);

            for sIndex=1:numel(solutions)
                if solutions(sIndex).isValid


                    if solutions(sIndex).Pass
                        feasibilityMessage=message('SimulinkFixedPoint:dataTypeOptimization:solutionMetConstraints').getString;
                    else
                        feasibilityMessage=message('SimulinkFixedPoint:dataTypeOptimization:solutionDidNotMeetConstraints').getString;
                    end

                    messageLog=message('SimulinkFixedPoint:dataTypeOptimization:evaluatingSolution',...
                    sprintf('%i',solutions(sIndex).Cost),feasibilityMessage).getString;
                    this.publish(messageLog,DataTypeOptimization.VerbosityLevel.High);
                end
            end
        end
    end

    methods(Hidden)
        function initializeParameters(this,parsedResults)

            initializeParameters@DataTypeOptimization.EvaluationServiceDecorator(this,parsedResults);
        end

    end



end