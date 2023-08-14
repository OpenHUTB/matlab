









classdef SwarmPlot<SimBiology.fit.internal.plots.liveplots.AbstractPlot

    properties(Access=public)
Histogram
ScatterPlot
NumParams
FunctionName
    end

    methods

        function obj=SwarmPlot(info,varargin)

            obj@SimBiology.fit.internal.plots.liveplots.AbstractPlot(varargin{:});


            obj.NumParams=numel(info.EstimatedParameters);
            obj.FunctionName=info.FunctionName;


            obj.Axes.Title.Interpreter='none';
        end

        function updateContent(obj,info)
            swarm=info.Swarm;
            if obj.NumParams==1
                obj.Histogram.Data=swarm;
                obj.Histogram.BinMethod='auto';
            else
                if obj.NumParams==2
                    obj.ScatterPlot.XData=[obj.ScatterPlot.XData,swarm(:,1)'];
                    obj.ScatterPlot.YData=[obj.ScatterPlot.YData,swarm(:,2)'];
                else
                    [u,s]=svd(swarm);
                    obj.ScatterPlot.XData=[obj.ScatterPlot.XData,u(:,1)*s(1,1)];
                    obj.ScatterPlot.YData=[obj.ScatterPlot.YData,u(:,2)*s(2,2)];
                end
            end
        end

        function addContent(obj,~)
            if obj.NumParams==1
                obj.Axes.Title.String='Parameter Range';
                obj.Histogram=histogram(obj.HistAxes,[],'Visible','off','EdgeAlpha',0.5);
                obj.Axes.Box='off';
            else
                if isempty(obj.ScatterPlot)
                    obj.ScatterPlot=scatter('Parent',obj.Axes,[],[],'filled');
                    obj.Axes.XLabel.String='First Principal Component';
                    obj.Axes.YLabel.String='Second Principal Component';

                    if strcmp(obj.FunctionName,'particleswarm')
                        obj.Axes.Title.String='Parameter Swarm PCA';
                    else
                        obj.Axes.Title.String='Parameter Population PCA';
                    end
                end
            end
        end

        function fadeContent(obj,~)
            obj.ScatterPlot.MarkerFaceAlpha=0.3;
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