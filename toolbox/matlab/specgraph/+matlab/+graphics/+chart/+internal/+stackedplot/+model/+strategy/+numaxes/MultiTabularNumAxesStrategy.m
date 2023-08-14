classdef MultiTabularNumAxesStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.NumAxesStrategy




    methods
        function n=getNumAxes(~,chartData)
            multiTabularIndex=chartData.IndexFactory.getIndex("MultiTabularIndex");
            n=multiTabularIndex.getNumAxes();
        end
    end
end
