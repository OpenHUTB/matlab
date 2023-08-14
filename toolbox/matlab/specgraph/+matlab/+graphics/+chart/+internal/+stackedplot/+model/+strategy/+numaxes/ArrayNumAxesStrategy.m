classdef ArrayNumAxesStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.NumAxesStrategy




    methods
        function n=getNumAxes(~,chartData)
            if isempty(chartData.YData)
                n=0;
            else
                n=width(chartData.YData(:,:));
            end
        end
    end
end