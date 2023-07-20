classdef TabularAxesLineStylesStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.AxesLineStylesStrategy




    methods
        function s=getAxesLineStyles(~,chartData,axesIndex)

            tabularIndex=chartData.IndexFactory.getIndex("TabularIndex");
            n=tabularIndex.getNumPlotsInAxes(axesIndex);
            s=ones(1,n);
        end
    end
end