classdef ArrayDisplayVariablesValidationStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.DisplayVariablesValidationStrategy




    methods
        function vars=validateDisplayVariables(~,~,vars,chartClassName)
            import matlab.graphics.chart.internal.stackedplot.validateDisplayVariables
            if~isempty(vars)
                error(message('MATLAB:stackedplot:DisplayVariablesTablesOnly'));
            end
            vars=validateDisplayVariables(vars,table.empty(),chartClassName,"DisplayVariables");
        end
    end
end
