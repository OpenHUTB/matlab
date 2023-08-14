classdef ArrayAxesYDataStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.AxesYDataStrategy




    methods
        function y=getAxesYData(~,chartData,axesIndex)
            y={chartData.YData(:,axesIndex)};
        end
    end
end