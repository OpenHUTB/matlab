classdef MultiTabularAxesPlotTypeStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.AxesPlotTypeStrategy




    methods
        function plotType=getAxesPlotType(~,chartData,axesIndex)
            multiTabularIndex=chartData.IndexFactory.getIndex("MultiTabularIndex");
            tbls=multiTabularIndex.getSingleVarSubTablesForAxes(axesIndex);
            plotType=cellfun(@getPlotTypeForTable,tbls);
        end
    end
end

function plotType=getPlotTypeForTable(t)

    if istabular(t.(1))
        plotType=getPlotTypeForTable(t.(1));
        return
    end
    continuity=t.Properties.VariableContinuity;
    if isempty(continuity)

        plotType={'plot'};
    else
        plotType={continuity.PlotType};
    end
end