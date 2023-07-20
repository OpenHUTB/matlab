classdef CustomPlotConnector<simmanager.designview.internal.FigureObjectConnector










    methods(Access=?simmanager.designview.internal.CustomPlot)

        function obj=CustomPlotConnector(customPlot)
            obj=obj@simmanager.designview.internal.FigureObjectConnector(customPlot);

            addlistener(customPlot,"RunSelected",...
            @(~,evtData)obj.sendSelect(evtData));

            addlistener(customPlot,"RunDeselected",...
            @(~,evtData)obj.sendDeselect(evtData));

            addlistener(customPlot,"HoverInactive",...
            @(~,~)obj.sendHoverInactive());

            addlistener(customPlot,"FigureClicked",...
            @(~,~)obj.sendFigureClicked());

            addlistener(customPlot,"AxesClicked",...
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
