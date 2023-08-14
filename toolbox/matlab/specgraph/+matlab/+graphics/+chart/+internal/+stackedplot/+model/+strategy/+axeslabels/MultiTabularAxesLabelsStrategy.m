classdef MultiTabularAxesLabelsStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.AxesLabelsStrategy




    methods
        function labels=getAxesLabels(~,chartData,axesIndex)
            multiTabularIndex=chartData.IndexFactory.getIndex("MultiTabularIndex");
            tbls=multiTabularIndex.getSingleVarSubTablesForAxes(axesIndex);
            labels=cell(1,length(tbls));
            for i=1:length(tbls)
                t=tbls{i};
                labels{i}=t.Properties.VariableNames;
                if istabular(t.(1))
                    labels{i}=strcat(labels{i},'.',t.(1).Properties.VariableNames);
                end
            end
            labels=unique(vertcat(labels{:}),"stable");
        end
    end
end
