classdef ArrayXLimitsStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.XLimitsStrategy




    methods
        function xLimits=getXLimits(~,chartData)
            xLimits=matlab.graphics.chart.internal.stackedplot.getLimits(chartData.XData);
        end
    end
end