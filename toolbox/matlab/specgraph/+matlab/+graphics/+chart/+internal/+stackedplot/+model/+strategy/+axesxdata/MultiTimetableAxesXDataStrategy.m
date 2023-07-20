classdef MultiTimetableAxesXDataStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.AxesXDataStrategy




    methods
        function x=getAxesXData(~,chartData,axesIndex)
            multiTabularIndex=chartData.IndexFactory.getIndex("MultiTabularIndex");
            tbls=multiTabularIndex.getSingleVarSubTablesForAxes(axesIndex);
            x=cellfun(@(t)t.Properties.RowTimes,tbls,"UniformOutput",false);
        end
    end
end
