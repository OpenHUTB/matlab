classdef TabularAxesPlotTypeStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.AxesPlotTypeStrategy




    methods
        function plotType=getAxesPlotType(~,chartData,axesIndex)
            tabularIndex=chartData.IndexFactory.getIndex("TabularIndex");
            t=tabularIndex.getSubTableForAxes(axesIndex);
            if tabularIndex.isInnerTable(axesIndex)
                plotType=getPlotTypeForTable(t.(1));
            else
                plotType=getPlotTypeForTable(t);
            end
        end
    end
end

function plotType=getPlotTypeForTable(t)

    continuity=t.Properties.VariableContinuity;
    if isempty(continuity)

        plotType='plot';
    else
        plotType=[continuity.PlotType];
    end
end