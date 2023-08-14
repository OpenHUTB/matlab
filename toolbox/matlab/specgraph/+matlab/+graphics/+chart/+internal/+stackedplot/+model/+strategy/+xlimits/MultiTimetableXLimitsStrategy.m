classdef MultiTimetableXLimitsStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.XLimitsStrategy




    methods
        function xLimits=getXLimits(~,chartData)
            data=cellfun(@(t)t.Properties.RowTimes,chartData.SourceTable,"UniformOutput",false);
            xLimits=matlab.graphics.chart.internal.stackedplot.getLimits(vertcat(data{:}));
        end
    end
end