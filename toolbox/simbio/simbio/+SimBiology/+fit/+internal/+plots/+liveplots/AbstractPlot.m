









classdef(Abstract)AbstractPlot<handle&matlab.mixin.Heterogeneous

    properties(Access=public)
Axes
LineColors
    end

    methods
        function obj=AbstractPlot(varargin)
            if nargin<4
                figure;
                obj.Axes=axes('HandleVisibility','callback');
            else
                m=varargin{1};
                n=varargin{2};
                p=varargin{3};
                figureHandle=varargin{4};
                obj.Axes=subplot(m,n,p,'Parent',figureHandle,'HandleVisibility','callback');
                obj.Axes.Box='on';
            end
        end
    end

    methods(Sealed)
        function addPlotContent(subplots,plotInfo)
            for i=1:numel(subplots)
                subplots(i).addContent(plotInfo);
            end
        end

        function updatePlotContent(subplots,plotInfo)
            for i=1:numel(subplots)
                subplots(i).updateContent(plotInfo);
            end
        end

        function fadePlotContent(subplots,plotInfo)
            for i=1:numel(subplots)
                subplots(i).fadeContent(plotInfo);
            end
        end

        function cleanupPlots(subplots)
            for i=1:numel(subplots)
                subplots(i).cleanup();
            end
        end

        function setPlotExitFlag(subplots,index,exitFlag)
            for i=1:numel(subplots)
                subplots(i).setExitFlag(index,exitFlag);
            end
        end

        function setPlotSelectedLines(subplots,indices)
            for i=1:numel(subplots)
                subplots(i).setSelectedLines(indices);
            end
        end

        function clearPlotSelectedLines(subplots)
            for i=1:numel(subplots)
                subplots(i).clearSelectedLines();
            end
        end

        function notifyFigureResized(subplots,hObject)
            for i=1:numel(subplots)
                subplots(i).figureResized(hObject);
            end
        end
    end

    methods(Abstract)

        fadeContent(obj,info);


        updateContent(obj,info);


        addContent(obj,info);


        setExitFlag(obj,index,exitFlag);


        cleanup(obj);


        setSelectedLines(obj,indices);


        clearSelectedLines(obj);


        figureResized(obj,hObj);
    end
end

