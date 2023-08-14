classdef TabularChartLegendLabelsStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.ChartLegendLabelsStrategy




    methods
        function labels=getChartLegendLabels(~,chartData)
            labels={class(chartData.SourceTable)};
        end
    end
end