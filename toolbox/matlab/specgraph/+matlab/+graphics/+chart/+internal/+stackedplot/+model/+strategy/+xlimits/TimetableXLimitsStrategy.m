classdef TimetableXLimitsStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.XLimitsStrategy




    methods
        function xLimits=getXLimits(~,chartData)
            xLimits=matlab.graphics.chart.internal.stackedplot.getLimits(chartData.SourceTable.Properties.RowTimes);
        end
    end
end