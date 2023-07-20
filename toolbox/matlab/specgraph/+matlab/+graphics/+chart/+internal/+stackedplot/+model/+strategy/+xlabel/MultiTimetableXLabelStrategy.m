classdef MultiTimetableXLabelStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.XLabelStrategy




    methods
        function xLabel=getXLabel(~,chartData)
            xLabel=chartData.SourceTable{1}.Properties.DimensionNames{1};
        end
    end
end
