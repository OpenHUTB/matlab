classdef TabularNumAxesStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.NumAxesStrategy




    methods
        function n=getNumAxes(~,chartData)
            if isempty(chartData.SourceTable)
                n=0;
            else
                tabularIndex=chartData.IndexFactory.getIndex("TabularIndex");
                n=tabularIndex.getNumAxes();
            end
        end
    end
end