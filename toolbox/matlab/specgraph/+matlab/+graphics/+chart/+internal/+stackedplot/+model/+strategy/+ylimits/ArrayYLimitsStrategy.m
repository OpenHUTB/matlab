classdef ArrayYLimitsStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.YLimitsStrategy




    methods
        function yLimits=getYLimits(~,chartData,axesIndex)
            yLimits=matlab.graphics.chart.internal.stackedplot.getLimits(chartData.YData(:,axesIndex));
        end
    end
end