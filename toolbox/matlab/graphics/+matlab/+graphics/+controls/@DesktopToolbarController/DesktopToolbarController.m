
classdef DesktopToolbarController<matlab.graphics.controls.ToolbarController

    methods(Static)

        function obj=getInstance(canvas,varargin)
            obj=matlab.graphics.controls.DesktopToolbarController(canvas,varargin{:});
        end
    end

    properties(Access=protected)


        InvisibleAxesHover;
    end

    methods(Static,Hidden)

        function buttonState=getButtonStateFromMode(modeName,direction)
            import matlab.graphics.controls.internal.ToolbarValidator;

            switch modeName
            case 'Exploration.Pan'
                buttonState=ToolbarValidator.pan;
            case 'Exploration.Zoom'
                if strcmpi(direction,'out')
                    buttonState=ToolbarValidator.zoomout;
                else
                    buttonState=ToolbarValidator.zoomin;
                end
            case 'Exploration.Rotate3d'
                buttonState=ToolbarValidator.rotate;
            case 'Exploration.Brushing'
                buttonState=ToolbarValidator.brush;
            case 'Exploration.Datacursor'
                buttonState=ToolbarValidator.datacursor;
            otherwise
                buttonState='';
            end
        end
    end

    methods(Access=protected)
        function obj=DesktopToolbarController(canvas,varargin)
            obj@matlab.graphics.controls.ToolbarController(canvas,varargin{:});
            obj.ModeStrategy=matlab.graphics.controls.internal.FigureBasedModeStrategy;
            obj.setPointerStrategy('figure');
        end
    end


    methods(Access=public)


        function handleModeChange(obj,~,eventData)
            obj.ModeStrategy.handleModeChange(eventData);
        end
    end


    methods(Access=public)



        function handleMouseExited(obj,eventSourceObj,mouseData)
            obj.handleMouseExited@matlab.graphics.controls.ToolbarController(eventSourceObj,mouseData);
            obj.InvisibleAxesHover=[];
        end

        function handleMouseMotion(obj,eventSourceObj,mouseData)
            try
                if isvalid(obj)
                    obj.handleMouseMotion@matlab.graphics.controls.ToolbarController(eventSourceObj,mouseData);

                    evtData=matlab.graphics.controls.eventdata.ProcessInteractionsEventData(obj,eventSourceObj);
                    obj.notify('ProcessInteractions',evtData);




                    if~strcmp(mouseData.EventName,'ButtonUp')

                        obj.updatePointer(eventSourceObj,mouseData);
                    end
                end
            catch




            end
        end

        function[fig,ax]=translateEvent(obj,eventSourceObj,mouseData)
            fig=obj.getCanvasFigure(eventSourceObj);

            ax=obj.getHitAxes(mouseData);




            if isa(mouseData,'matlab.graphics.controls.internal.InvisibleAxesEnterExitEventData')
                if strcmp(mouseData.Direction,'mouseenter')
                    obj.InvisibleAxesHover=mouseData.Axes;
                elseif strcmp(mouseData.Direction,'mouseleave')
                    obj.InvisibleAxesHover=[];
                end
            end
        end

        function result=canShowToolbar(obj,fig,ax)

            result=obj.canShowToolbar@matlab.graphics.controls.ToolbarController(fig,ax);

            if~result
                return;
            end



            result=(~isAxesToolbarExcluded(fig,ax)||...
            (~isempty(ax)&&strcmpi(ax.ToolbarMode,'manual')));



            if~result
                canvasContainer=ancestor(ax,'matlab.ui.internal.mixin.CanvasHostMixin');
                if~isempty(canvasContainer)
                    ap=matlab.graphics.annotation.internal.getDefaultCamera(canvasContainer,'overlay','-peek');
                    if~isempty(ap)&&numel(findobj(ap,'-isa','matlab.graphics.controls.AxesToolbar'))>0
                        result=(~isempty(ax)&&~isempty(ax.Toolbar_I)&&strcmpi(ax.Toolbar_I.VisibleMode,'manual'))||...
                        (~isempty(obj.CurrentToolbar)&&strcmp(obj.CurrentToolbar.VisibleMode,'manual'));
                    end
                end
            end
        end

        function result=axesHandleVisibleOff(~,ax)
            result=strcmp(ax.HandleVisibility,'off');
            if isa(ax,'matlab.graphics.axis.Axes')
                result=result||strcmp(ax.HitTest,'off');
            end
        end


        function ax=getHitAxes(hObj,mouseData)
            ax=hObj.getHitAxes@matlab.graphics.controls.ToolbarController(mouseData);
            tb=[];

            if~isempty(mouseData.Primitive)




                ax=ancestor(mouseData.Primitive,'matlab.graphics.axis.AbstractAxes','node');
                tb=ancestor(mouseData.Primitive,'matlab.graphics.controls.AxesToolbar','node');
            end




            if isempty(ax)
                if~isempty(hObj.InvisibleAxesHover)
                    ax=hObj.InvisibleAxesHover;
                elseif~isempty(tb)
                    ax=tb.Axes;
                else



                    return;
                end
            end


            if strcmpi(ax.Tag,'PlotMatrixScatterAx')||...
                strcmpi(ax.Tag,'PlotMatrixHistAx')
                ax=findobj(ax.Parent,'Tag','PlotMatrixBigAx');
            end
        end
    end
end

function state=isAxesToolbarExcluded(fig,ax)




    canvasContainer=ancestor(ax,'matlab.ui.internal.mixin.CanvasHostMixin');

    state=true;

    if~isempty(fig)&&isvalid(fig)
        state=(((strcmp(fig.ToolBar,'none')&&strcmp(fig.ToolBarMode,'manual'))...
        ||(strcmp(fig.MenuBar,'none')&&strcmp(fig.MenuBarMode,'manual'))&&strcmp(fig.ToolBar,'auto'))||...
        isa(canvasContainer,'matlab.ui.container.internal.UIFlowContainer')||...
        isa(canvasContainer,'matlab.ui.container.internal.UIGridContainer'));
    end
end
