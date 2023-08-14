classdef SBioXYLinePlot<SimBiology.internal.plotting.sbioplot.SBioLinePlot




    methods(Access=public)
        function plotStyle=getPlotStyle(obj)
            plotStyle=SimBiology.internal.plotting.sbioplot.definition.PlotDefinition.XY;
        end

        function flag=isTimePlot(obj)
            flag=false;
        end
    end
end