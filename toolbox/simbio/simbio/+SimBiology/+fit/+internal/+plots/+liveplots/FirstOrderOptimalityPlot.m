









classdef FirstOrderOptimalityPlot<SimBiology.fit.internal.plots.liveplots.AbstractLinePlot

    methods

        function obj=FirstOrderOptimalityPlot(varargin)

            obj@SimBiology.fit.internal.plots.liveplots.AbstractLinePlot(varargin{:});


            obj.Axes.Title.Interpreter='none';
            obj.Axes.Title.String=getString(message('SimBiology:fitplots:LivePlots_FirstOrderOptimality_Title'));


            obj.Lines=gobjects(0);


            obj.Axes.Tag='LivePlots_FirstOrderOptimalityPlot';
        end

        function updateContent(obj,info)
            lineObj=obj.Lines(info.Tag);

            if~isempty(info.FirstOrderOptimality)
                val=info.FirstOrderOptimality{info.Iteration+1};
                if~isempty(val)
                    addpoints(lineObj,info.Iteration,val);
                end
            end
        end
    end
end
