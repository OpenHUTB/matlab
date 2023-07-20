classdef ArrayAutoDisplayVariablesStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.AutoDisplayVariablesStrategy




    methods
        function setAutoDisplayVariables(~,chartData,~)

            chartData.DisplayVariables=cell(1,0);
        end
    end
end