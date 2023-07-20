classdef TimetableModelStrategyFactory<matlab.graphics.chart.internal.stackedplot.model.strategy.factory.ModelStrategyFactory




    methods
        function s=createNumAxesStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.numaxes.TabularNumAxesStrategy();
        end

        function s=createAxesXDataStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.axesxdata.TimetableAxesXDataStrategy();
        end

        function s=createAxesYDataStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.axesydata.TabularAxesYDataStrategy();
        end

        function s=createAxesSeriesIndicesStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.axesseriesindices.TabularAxesSeriesIndicesStrategy();
        end

        function s=createAxesLineStylesStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.axeslinestyles.TabularAxesLineStylesStrategy();
        end

        function s=createAxesLabelsStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.axeslabels.TabularAxesLabelsStrategy();
        end

        function s=createLegendLabelsStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.legendlabels.TabularLegendLabelsStrategy();
        end

        function s=createXLabelStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.xlabel.TimetableXLabelStrategy();
        end

        function s=createXLimitsStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.xlimits.TimetableXLimitsStrategy();
        end

        function s=createYLimitsStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.ylimits.TabularYLimitsStrategy();
        end

        function s=createAutoDisplayVariablesStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.autodisplayvariables.TabularAutoDisplayVariablesStrategy();
        end

        function s=createPlotMappingStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.plotmapping.TabularPlotMappingStrategy();
        end

        function s=createAxesPlotTypeStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.axesplottype.TabularAxesPlotTypeStrategy();
        end

        function s=createPropertyGroupsStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.propertygroups.TimetablePropertyGroupsStrategy();
        end

        function s=createValidationStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.validation.TabularValidationStrategy();
        end

        function s=createXVariableValidationStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.xvariablevalidation.UnsupportedXVariableValidationStrategy();
        end

        function s=createDisplayVariablesValidationStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.displayvariablesvalidation.TabularDisplayVariablesValidationStrategy();
        end

        function s=createCollapseLegendStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.collapselegend.TabularCollapseLegendStrategy();
        end

        function s=createChartLegendVisibleStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.chartlegendvisible.TabularChartLegendVisibleStrategy();
        end

        function s=createChartLegendLabelsStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.chartlegendlabels.TabularChartLegendLabelsStrategy();
        end
    end
end