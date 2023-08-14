classdef(Abstract)YLimitsStrategy




    methods(Abstract)
        yLimits=getYLimits(obj,chartData,axesIndex)
    end
end