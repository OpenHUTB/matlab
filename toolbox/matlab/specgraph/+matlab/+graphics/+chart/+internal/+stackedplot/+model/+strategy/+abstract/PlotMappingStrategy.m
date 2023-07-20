classdef(Abstract)PlotMappingStrategy





    methods(Abstract)
        [axesMapping,plotMapping]=mapPlotObjects(obj,chartData,oldState)
    end
end