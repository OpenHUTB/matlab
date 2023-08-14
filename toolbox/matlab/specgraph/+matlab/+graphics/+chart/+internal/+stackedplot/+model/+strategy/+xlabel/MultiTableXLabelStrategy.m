classdef MultiTableXLabelStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.XLabelStrategy




    methods
        function xLabel=getXLabel(~,chartData)
            xvar=chartData.XVariable;
            if isempty(xvar)
                xLabel=chartData.SourceTable{1}.Properties.DimensionNames{1};
            else
                if ischar(xvar)
                    xLabel=xvar;
                else
                    xLabel=xvar{1};
                end
            end
        end
    end
end
