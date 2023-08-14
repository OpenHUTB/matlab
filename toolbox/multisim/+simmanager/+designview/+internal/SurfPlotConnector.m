






classdef SurfPlotConnector<simmanager.designview.internal.FigureObjectConnector
    methods(Access=?simmanager.designview.SurfPlot)
        function obj=SurfPlotConnector(scatterPlot)
            obj=obj@simmanager.designview.internal.FigureObjectConnector(scatterPlot);
            addlistener(scatterPlot,"RunSelected",...
            @(~,evtData)obj.sendSelect(evtData));

            addlistener(scatterPlot,"RunDeselected",...
            @(~,evtData)obj.sendDeselect(evtData));

            addlistener(scatterPlot,"HoverInactive",...
            @(~,~)obj.sendHoverInactive());

            addlistener(scatterPlot,"FigureClicked",...
            @(~,~)obj.sendFigureClicked());

            addlistener(scatterPlot,"AxesClicked",...
            @(~,~)obj.sendAxesClicked());
        end
    end

    methods(Access=private)

        function sendSelect(obj,evtData)
            obj.publish(struct('type','selected','runId',evtData.Data));
        end


        function sendDeselect(obj,evtData)
            obj.publish(struct('type','deselected','runId',evtData.Data));
        end


        function sendHoverInactive(obj)
            obj.publish(struct('type','hoverInactive'));
        end


        function sendFigureClicked(obj)
            obj.publish(struct('type','figureClicked'));
        end


        function sendAxesClicked(obj)
            obj.publish(struct('type','axesClicked'));
        end

    end
end