classdef EvaluationServiceDecorator<DataTypeOptimization.AbstractEvaluationService






    properties
decoratedEvaluationService

    end

    methods
        function this=EvaluationServiceDecorator(evaluationService)

            this=this@DataTypeOptimization.AbstractEvaluationService();


            this.decoratedEvaluationService=evaluationService;
        end

        function solutions=evaluateSolutions(this,solutions)

            solutions=this.decoratedEvaluationService.evaluateSolutions(solutions);
        end

    end

    methods(Hidden)
        function initializeParameters(this,parsedResults)

            this.decoratedEvaluationService.initializeParameters(parsedResults);



            this.baselineSimOut=this.decoratedEvaluationService.baselineSimOut;
            this.baselineRunID=this.decoratedEvaluationService.baselineRunID;
            this.problemPrototype=this.decoratedEvaluationService.problemPrototype;
            this.environmentProxy=this.decoratedEvaluationService.environmentProxy;
        end

    end

end