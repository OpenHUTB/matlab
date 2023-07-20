









classdef ParallelCoordinatesPlot<SimBiology.fit.internal.plots.liveplots.AbstractPlot

    properties(Access=public)
PCPlot
Pooled
Legend
    end

    methods

        function obj=ParallelCoordinatesPlot(info,varargin)

            obj@SimBiology.fit.internal.plots.liveplots.AbstractPlot(varargin{:});


            obj.Pooled=info.Pooled;


            if info.Pooled
                obj.PCPlot=parallelcoords(zeros(1,numel(info.EstimatedParameters)),'Standardize','PCA','Labels',info.EstimatedParameters,'Visible','off','Parent',obj.Axes);
            else
                obj.PCPlot=parallelcoords(zeros(numel(info.Groups),numel(info.EstimatedParameters)),'Standardize','PCA','Labels',info.EstimatedParameters,'Visible','off','Parent',obj.Axes);
            end


            obj.Axes.Title.Interpreter='none';
            obj.Axes.Title.String='Estimated Parameter Values';
            obj.Axes.XLabel.String='Parameters';
            obj.Axes.YLabel.String='Parameter Values';
        end

        function updateContent(obj,info)
            obj.PCPlot(info.Tag).YData=info.ParameterEstimates{info.Iteration+1};
        end

        function addContent(obj,info)
            if~obj.Pooled
                obj.PCPlot(info.Tag).Visible='on';
            else
                obj.PCPlot(1).Visible='on';
            end
        end

        function fadeContent(obj,info)
            obj.PCPlot(info.Tag).YData=info.ParameterEstimates{end};
        end

        function setExitFlag(~,~,~)
        end

        function cleanup(~)
        end

        function setSelectedLines(~,~)
        end

        function clearSelectedLines(~)
        end

        function figureResized(~,~)
        end
    end
end