classdef TimetableAxesXDataStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.AxesXDataStrategy




    methods
        function x=getAxesXData(~,chartData,~)
            x={chartData.SourceTable.Properties.RowTimes};
        end
    end
end