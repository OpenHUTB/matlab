classdef ArrayChartLegendLabelsStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.ChartLegendLabelsStrategy




    methods
        function labels=getChartLegendLabels(~,chartData)
            labels={class(chartData.YData)};
        end
    end
end