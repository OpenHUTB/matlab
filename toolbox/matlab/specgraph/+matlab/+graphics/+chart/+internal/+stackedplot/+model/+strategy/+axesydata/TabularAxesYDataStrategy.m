classdef TabularAxesYDataStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.AxesYDataStrategy




    methods
        function y=getAxesYData(~,chartData,axesIndex)
            tabularIndex=chartData.IndexFactory.getIndex("TabularIndex");
            yT=tabularIndex.getSubTableForAxes(axesIndex);
            if tabularIndex.isInnerTable(axesIndex)
                y={yT.(1).(1)};
            else
                y=cell(1,width(yT));
                for i=1:width(yT)
                    y{i}=yT.(i);
                end
            end
        end
    end
end
