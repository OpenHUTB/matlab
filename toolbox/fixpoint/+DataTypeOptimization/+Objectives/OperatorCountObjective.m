classdef OperatorCountObjective<DataTypeOptimization.Objectives.AbstractObjective






    methods
        function validate(this)
            model=this.environmentContext.TopModel;
            p=designcostestimation.internal.preprocessing.PreprocessingService(model);
            p.process();

        end

        function cost=measure(this,solution)

            currentSettings=solution.simIn(1);
            modelState=Simulink.internal.TemporaryModelState(currentSettings,'EnableConfigSetRefUpdate','on');%#ok<NASGU>

            aDesignAnalyzer=designcostestimation.internal.estimateCost(bdroot(this.environmentContext.SUD));
            cost=aDesignAnalyzer.componentTotalCost(this.environmentContext.SUD);
        end
    end
end


