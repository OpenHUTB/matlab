classdef ArrayModelStrategyFactory<matlab.graphics.chart.internal.stackedplot.model.strategy.factory.ModelStrategyFactory




    methods
        function s=createNumAxesStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.numaxes.ArrayNumAxesStrategy();
        end

        function s=createAxesXDataStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.axesxdata.ArrayAxesXDataStrategy();
        end

        function s=createAxesYDataStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.axesydata.ArrayAxesYDataStrategy();
        end

        function s=createAxesSeriesIndicesStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.axesseriesindices.ArrayAxesSeriesIndicesStrategy();
        end

        function s=createAxesLineStylesStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.axeslinestyles.ArrayAxesLineStylesStrategy();
        end

        function s=createAxesLabelsStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.axeslabels.ArrayAxesLabelsStrategy();
        end

        function s=createLegendLabelsStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.legendlabels.ArrayLegendLabelsStrategy();
        end

        function s=createXLabelStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.xlabel.ArrayXLabelStrategy();
        end

        function s=createXLimitsStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.xlimits.ArrayXLimitsStrategy();
        end

        function s=createYLimitsStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.ylimits.ArrayYLimitsStrategy();
        end

        function s=createAutoDisplayVariablesStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.autodisplayvariables.ArrayAutoDisplayVariablesStrategy();
        end

        function s=createPlotMappingStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.plotmapping.ArrayPlotMappingStrategy();
        end

        function s=createAxesPlotTypeStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.axesplottype.ArrayAxesPlotTypeStrategy();
        end

        function s=createPropertyGroupsStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.propertygroups.ArrayPropertyGroupsStrategy();
        end

        function s=createValidationStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.validation.ArrayValidationStrategy();
        end

        function s=createXVariableValidationStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.xvariablevalidation.UnsupportedXVariableValidationStrategy();
        end

        function s=createDisplayVariablesValidationStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.displayvariablesvalidation.ArrayDisplayVariablesValidationStrategy();
        end

        function s=createCollapseLegendStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.collapselegend.ArrayCollapseLegendStrategy();
        end

        function s=createChartLegendVisibleStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.chartlegendvisible.ArrayChartLegendVisibleStrategy();
        end

        function s=createChartLegendLabelsStrategy(~)
            s=matlab.graphics.chart.internal.stackedplot.model.strategy.chartlegendlabels.ArrayChartLegendLabelsStrategy();
        end
    end
end