classdef TabularAxesSeriesIndicesStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.AxesSeriesIndicesStrategy




    methods
        function s=getAxesSeriesIndices(~,chartData,axesIndex)


            tabularIndex=chartData.IndexFactory.getIndex("TabularIndex");
            n=tabularIndex.getNumPlotsInAxes(axesIndex);
            s=1:n;
        end
    end
end