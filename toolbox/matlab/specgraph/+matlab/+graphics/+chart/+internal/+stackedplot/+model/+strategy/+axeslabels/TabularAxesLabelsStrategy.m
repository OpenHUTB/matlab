classdef TabularAxesLabelsStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.AxesLabelsStrategy




    methods
        function labels=getAxesLabels(~,chartData,axesIndex)
            tabularIndex=chartData.IndexFactory.getIndex("TabularIndex");
            t=tabularIndex.getSubTableForAxes(axesIndex);
            labels=t.Properties.VariableNames';
            if tabularIndex.isInnerTable(axesIndex)

                innerLabels=t.(1).Properties.VariableNames;
                labels=strcat(labels,'.',innerLabels);
            end
        end
    end
end
