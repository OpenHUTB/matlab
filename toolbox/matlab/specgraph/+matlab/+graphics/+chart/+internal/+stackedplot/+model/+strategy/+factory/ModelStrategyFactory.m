classdef(Abstract)ModelStrategyFactory




    methods(Static)
        function factory=createModelStrategyFactory(type)
            switch type
            case "array"
                factory=matlab.graphics.chart.internal.stackedplot.model.strategy.factory.ArrayModelStrategyFactory();
            case "table"
                factory=matlab.graphics.chart.internal.stackedplot.model.strategy.factory.TableModelStrategyFactory();
            case "timetable"
                factory=matlab.graphics.chart.internal.stackedplot.model.strategy.factory.TimetableModelStrategyFactory();
            case "multi-table"
                factory=matlab.graphics.chart.internal.stackedplot.model.strategy.factory.MultiTableModelStrategyFactory();
            case "multi-timetable"
                factory=matlab.graphics.chart.internal.stackedplot.model.strategy.factory.MultiTimetableModelStrategyFactory();
            otherwise
                assert(false);
            end
        end
    end

    methods(Abstract)
        s=createNumAxesStrategy(obj)
        s=createAxesXDataStrategy(obj)
        s=createAxesYDataStrategy(obj)
        s=createAxesSeriesIndicesStrategy(obj)
        s=createAxesLineStylesStrategy(obj)
        s=createAxesLabelsStrategy(obj)
        s=createLegendLabelsStrategy(obj)
        s=createXLabelStrategy(obj)
        s=createXLimitsStrategy(obj)
        s=createYLimitsStrategy(obj)
        s=createAutoDisplayVariablesStrategy(obj)
        s=createPlotMappingStrategy(obj)
        s=createAxesPlotTypeStrategy(obj)
        s=createPropertyGroupsStrategy(obj)
        s=createValidationStrategy(obj)
        s=createXVariableValidationStrategy(obj)
        s=createDisplayVariablesValidationStrategy(obj)
        s=createCollapseLegendStrategy(obj)
        s=createChartLegendVisibleStrategy(obj)
        s=createChartLegendLabelsStrategy(obj)
    end
end