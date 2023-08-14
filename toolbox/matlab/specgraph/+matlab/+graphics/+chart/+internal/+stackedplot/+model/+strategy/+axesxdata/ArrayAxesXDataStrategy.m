classdef ArrayAxesXDataStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.AxesXDataStrategy




    methods
        function x=getAxesXData(~,chartData,~)
            x={chartData.XData};
        end
    end
end