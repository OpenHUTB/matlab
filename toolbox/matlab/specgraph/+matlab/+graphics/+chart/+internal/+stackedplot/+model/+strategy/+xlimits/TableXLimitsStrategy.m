classdef TableXLimitsStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.XLimitsStrategy




    methods
        function xLimits=getXLimits(~,chartData)
            if isempty(chartData.XVariable)
                data=1:height(chartData.SourceTable);
            else
                data=chartData.SourceTable.(chartData.XVariable);
            end
            xLimits=matlab.graphics.chart.internal.stackedplot.getLimits(data);
        end
    end
end