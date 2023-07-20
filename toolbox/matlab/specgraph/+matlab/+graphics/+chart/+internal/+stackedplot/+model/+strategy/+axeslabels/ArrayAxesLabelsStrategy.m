classdef ArrayAxesLabelsStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.AxesLabelsStrategy




    methods
        function labels=getAxesLabels(~,~,axesIndex)
            labels={getString(message("MATLAB:stackedplot:Column",axesIndex))};
        end
    end
end
