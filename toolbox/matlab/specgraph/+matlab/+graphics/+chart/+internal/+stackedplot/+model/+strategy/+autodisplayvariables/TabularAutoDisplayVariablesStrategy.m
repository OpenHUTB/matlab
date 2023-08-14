classdef TabularAutoDisplayVariablesStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.AutoDisplayVariablesStrategy




    methods
        function setAutoDisplayVariables(~,chartData,~)

            import matlab.graphics.chart.internal.stackedplot.canBeDisplayVariables


            dv=chartData.SourceTable.Properties.VariableNames(canBeDisplayVariables(chartData.SourceTable,false));
            if~isempty(chartData.XVariable)
                dv=setdiff(dv,chartData.XVariable,'stable');
            end


            if isempty(dv)
                dv=cell(1,0);
            end
            chartData.DisplayVariables=dv;
        end
    end
end