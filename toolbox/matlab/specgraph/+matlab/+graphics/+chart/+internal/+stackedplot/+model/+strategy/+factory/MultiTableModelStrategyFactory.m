classdef MultiTableModelStrategyFactory<matlab.graphics.chart.internal.stackedplot.model.strategy.factory.ModelStrategyFactory




    methods
        function s=createNumAxesStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.numaxes.MultiTabularNumAxesStrategy();
        end

        function s=createAxesXDataStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.axesxdata.MultiTableAxesXDataStrategy();
        end

        function s=createAxesYDataStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.axesydata.MultiTabularAxesYDataStrategy();
        end

        function s=createAxesSeriesIndicesStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.axesseriesindices.MultiTabularAxesSeriesIndicesStrategy();
        end

        function s=createAxesLineStylesStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.axeslinestyles.MultiTabularAxesLineStylesStrategy();
        end

        function s=createAxesLabelsStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.axeslabels.MultiTabularAxesLabelsStrategy();
        end

        function s=createLegendLabelsStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.legendlabels.MultiTabularLegendLabelsStrategy();
        end

        function s=createXLabelStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.xlabel.MultiTableXLabelStrategy();
        end

        function s=createXLimitsStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.xlimits.MultiTableXLimitsStrategy();
        end

        function s=createYLimitsStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.ylimits.MultiTabularYLimitsStrategy();
        end

        function s=createAutoDisplayVariablesStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.autodisplayvariables.MultiTabularAutoDisplayVariablesStrategy();
        end

        function s=createPlotMappingStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.plotmapping.MultiTabularPlotMappingStrategy();
        end

        function s=createAxesPlotTypeStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.axesplottype.MultiTabularAxesPlotTypeStrategy();
        end

        function s=createPropertyGroupsStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.propertygroups.MultiTablePropertyGroupsStrategy();
        end

        function s=createValidationStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.validation.MultiTabularValidationStrategy();
        end

        function s=createXVariableValidationStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.xvariablevalidation.MultiTableXVariableValidationStrategy();
        end

        function s=createDisplayVariablesValidationStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.displayvariablesvalidation.MultiTabularDisplayVariablesValidationStrategy();
        end

        function s=createCollapseLegendStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.collapselegend.MultiTabularCollapseLegendStrategy();
        end

        function s=createChartLegendVisibleStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.chartlegendvisible.MultiTabularChartLegendVisibleStrategy();
        end

        function s=createChartLegendLabelsStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.chartlegendlabels.MultiTabularChartLegendLabelsStrategy();
        end
    end
end