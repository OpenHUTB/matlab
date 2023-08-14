classdef TimetableXLabelStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.XLabelStrategy




    methods
        function xLabel=getXLabel(~,chartData)
            xLabel=chartData.SourceTable.Properties.DimensionNames{1};
        end
    end
end
