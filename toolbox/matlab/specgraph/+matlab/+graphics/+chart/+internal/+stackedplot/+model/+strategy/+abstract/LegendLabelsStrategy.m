classdef(Abstract)LegendLabelsStrategy




    methods(Abstract)
        labels=getLegendLabels(obj,chartData,axesIndex)
    end
end