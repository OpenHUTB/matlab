classdef ArrayLegendLabelsStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.LegendLabelsStrategy




    methods
        function labels=getLegendLabels(~,~,axesIndex)
            labels=getString(message("MATLAB:stackedplot:Column",axesIndex));
        end
    end
end
