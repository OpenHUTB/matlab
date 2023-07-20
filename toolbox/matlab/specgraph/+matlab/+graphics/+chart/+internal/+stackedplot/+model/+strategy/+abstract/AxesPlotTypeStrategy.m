classdef(Abstract)AxesPlotTypeStrategy




    methods(Abstract)
        plotTypes=getAxesPlotType(obj,chartData,axesIndex)
    end
end