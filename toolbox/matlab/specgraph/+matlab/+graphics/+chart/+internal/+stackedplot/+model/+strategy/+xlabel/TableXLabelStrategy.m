classdef TableXLabelStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.XLabelStrategy




    methods
        function xLabel=getXLabel(~,chartData)
            if isempty(chartData.XVariable)
                xLabel=chartData.SourceTable.Properties.DimensionNames{1};
            else
                xLabel=chartData.XVariable;
            end
        end
    end
end
