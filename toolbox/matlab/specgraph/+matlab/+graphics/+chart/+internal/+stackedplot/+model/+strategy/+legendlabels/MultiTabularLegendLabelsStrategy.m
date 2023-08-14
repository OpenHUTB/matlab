classdef MultiTabularLegendLabelsStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.LegendLabelsStrategy




    methods
        function labels=getLegendLabels(~,chartData,axesIndex)
            multiTabularIndex=chartData.IndexFactory.getIndex("MultiTabularIndex");
            tbls=multiTabularIndex.getSingleVarSubTablesForAxes(axesIndex);
            labels=cellfun(@getLegendLabelsForSingleVarTable,tbls,"UniformOutput",false);
            labels=[labels{:}];
        end
    end
end

function labels=getLegendLabelsForSingleVarTable(t)
    labels=t.Properties.VariableNames;
    if istabular(t.(1))
        labels=strcat(labels,".",getLegendLabelsForSingleVarTable(t.(1)));
    else
        w=width(t{:,:}(:,:));
        if w>1
            labels=labels+" "+(1:w);
        end
    end
    labels=cellstr(labels);
end
