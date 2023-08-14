classdef MultiTabularChartLegendLabelsStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.ChartLegendLabelsStrategy




    methods
        function labels=getChartLegendLabels(~,chartData)
            labels=cellstr(class(chartData.SourceTable{1})+" "+(1:numel(chartData.SourceTable)));
        end
    end
end