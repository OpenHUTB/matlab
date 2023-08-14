classdef TabularDisplayVariablesValidationStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.DisplayVariablesValidationStrategy




    methods
        function vars=validateDisplayVariables(~,chartData,vars,chartClassName)
            import matlab.graphics.chart.internal.stackedplot.validateDisplayVariables
            vars=validateDisplayVariables(vars,chartData.SourceTable,chartClassName,"DisplayVariables");
        end
    end
end
