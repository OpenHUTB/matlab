classdef StackedInteractionStrategy<matlab.graphics.interaction.uiaxes.AxesInteractionStrategy




    properties
        StackedPlot(1,1)matlab.graphics.chart.StackedLineChart
    end

    methods
        function hObj=StackedInteractionStrategy(ax,sp)
            hObj=hObj@matlab.graphics.interaction.uiaxes.AxesInteractionStrategy(ax);
            hObj.StackedPlot=sp;
        end





        function setZoomLimits(strategy,~,xlimits,~)

            hideCursor(strategy.StackedPlot.DataCursor);

            allaxes=strategy.StackedPlot.Axes_I;

            allaxes=allaxes(strcmp({allaxes.Visible},'on'));
            xlimits=matlab.graphics.internal.lim2ruler(xlimits,...
            strategy.StackedPlot.Axes_I(1).XAxis);
            set(allaxes,'XLim',xlimits,'YLimMode','manual');

            set(strategy.StackedPlot,'XLimits_I',xlimits,'XLimitsMode','manual');
            set(strategy.StackedPlot.AxesProperties,'YLimitsMode','manual');
        end


        function setPanLimits(strategy,~,xlimits,~)

            hideCursor(strategy.StackedPlot.DataCursor);

            allaxes=strategy.StackedPlot.Axes_I;

            allaxes=allaxes(strcmp({allaxes.Visible},'on'));
            for i=1:length(allaxes)
                curraxes=allaxes(i);
                setPanLimits@matlab.graphics.interaction.uiaxes.AxesInteractionStrategy(...
                strategy,curraxes,xlimits,curraxes.ActiveDataSpace.YLim);
            end

            set(strategy.StackedPlot,'XLimits_I',matlab.graphics.internal.lim2ruler(xlimits,...
            strategy.StackedPlot.Axes_I(1).XAxis),'XLimitsMode','manual');
            set(strategy.StackedPlot.AxesProperties,'YLimitsMode','manual');



            drawnow nocallbacks;
        end
    end
end
