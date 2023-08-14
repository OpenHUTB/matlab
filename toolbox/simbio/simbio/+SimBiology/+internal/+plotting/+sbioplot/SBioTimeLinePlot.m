classdef SBioTimeLinePlot<SimBiology.internal.plotting.sbioplot.SBioLinePlot




    methods(Access=public)
        function plotStyle=getPlotStyle(obj)
            plotStyle=SimBiology.internal.plotting.sbioplot.definition.PlotDefinition.TIME;
        end

        function flag=isTimePlot(obj)
            flag=true;
        end
    end
end