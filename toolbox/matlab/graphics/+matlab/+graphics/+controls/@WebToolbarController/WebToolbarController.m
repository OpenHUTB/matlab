classdef WebToolbarController<matlab.graphics.controls.ToolbarController




    properties(Access=private,Constant)

        HIT_THRESHOLD=5;


        AXES_THRESHOLD=1;
    end

    methods(Static)

        function obj=getInstance(canvas,varargin)
            obj=matlab.graphics.controls.WebToolbarController(canvas,varargin{:});
        end
    end

    properties(Access=protected)

        LastHitEvent;

        CanvasPostUpdateListener;


        IsLiveEditorFigure;


        IsDesignTimeFigure;

        CanShowToolbarCache=true;

        IsTestRun=false;
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
        function obj=WebToolbarController(canvas,varargin)
            obj@matlab.graphics.controls.ToolbarController(canvas,varargin{:});

            fig=obj.getCanvasFigure(canvas);
            figmodes=false;


            obj.IsLiveEditorFigure=[];

            obj.CanvasPostUpdateListener=event.listener(canvas,'MarkedClean',@(canvas,~)...
            obj.queueMarkedClean(canvas));

            if~isempty(fig)&&isprop(fig,'UseLegacyExplorationModes')
                figmodes=fig.UseLegacyExplorationModes;
            end

            if figmodes
                obj.ModeStrategy=matlab.graphics.controls.internal.FigureBasedModeStrategy;
                obj.setPointerStrategy('figure');
            else
                obj.ModeStrategy=matlab.graphics.controls.internal.AxesBasedModeStrategy;
                obj.setPointerStrategy('axes');
            end
        end
    end

    methods(Access=public)

        function queueMarkedClean(obj,canvas)
            import matlab.internal.editor.figure.*;

            if~isvalid(obj)
                return;
            end

            fig=ancestor(canvas,'figure');



            if isempty(fig)
                return;
            end


            if isempty(obj.IsLiveEditorFigure)
                obj.IsLiveEditorFigure=FigureUtils.isEditorEmbeddedFigure(fig)||...
                FigureUtils.isEditorSnapshotFigure(fig);
            end


            if isempty(obj.IsDesignTimeFigure)
                fig=ancestor(canvas,'figure');
                obj.IsDesignTimeFigure=isprop(fig,'GUIDEFigure');
            end






            if obj.IsLiveEditorFigure||obj.IsDesignTimeFigure
                obj.CanvasPostUpdateListener.Enabled=false;
                return;
            end

            canvasContainer=ancestor(canvas,'matlab.ui.internal.mixin.CanvasHostMixin');

            allAx=findobjinternal(canvasContainer,'type','axes');

            numAxes=numel(allAx);


            if numAxes<=0
                return;
            end





            if numAxes<=obj.AXES_THRESHOLD&&~obj.IsTestRun
                tbFcn=@()localCleanupStrandedToolbars(obj,allAx(1));
                builtin('_dtcallback',tbFcn,internal.matlab.datatoolsservices.getSetCmdExecutionTypeIdle);
            end



            obj.CanvasPostUpdateListener.Enabled=false;
        end

        function cleanupStrandedToolbars(obj,ax)
            if~isempty(ax)&&isvalid(ax)&&~ax.BeingDeleted


                tb=ax.Toolbar_I;



                if~isempty(tb)&&isempty(tb.NodeParent)
                    tb.setTrueParent(ax);
                end

                canvasContainer=ancestor(ax,'matlab.ui.internal.mixin.CanvasHostMixin','node');
                if isempty(canvasContainer)
                    canvasContainer=ancestor(ax,'figure','node');
                end


                if~any(isvalid(tb))&&strcmp(ax.ToolbarMode,'auto')
                    obj.recreateToolbar(ax);


                    tb=ax.Toolbar_I;
                end

                if~isempty(canvasContainer)
                    ap=matlab.graphics.annotation.internal.getDefaultCamera(canvasContainer,'overlay','-peek');

                    if~isempty(ap)
                        tbs=findobj(ap,'-depth',1,'-isa','matlab.graphics.controls.AxesToolbar');
                        if~isempty(tb)
                            tbs=tbs(tbs~=tb);
                        end
                        for i=1:numel(tbs)
                            toolbar=tbs(i);



                            if isequal(toolbar.Parent,ax)||~toolbar.hasValidParent()
                                set(toolbar,'Visible_I','off');


                                matlab.graphics.internal.drawnow.callback(@()delete(toolbar));
                            end
                        end
                    end
                end
            end
        end

        function recreateToolbar(~,ax)
            try
                ax.Toolbar=matlab.graphics.controls.ToolbarController.getDefaultToolbar(ax);
                ax.ToolbarMode='auto';
            catch


            end
        end


        function handleResize(obj,eventSourceObj,data)
            obj.handleResize@matlab.graphics.controls.ToolbarController(eventSourceObj,data);

            currentValue=obj.CanShowToolbarCache;

            newValue=obj.canShowToolbar(eventSourceObj,[]);

            if currentValue~=newValue
                obj.CanShowToolbarCache=newValue;


                allAx=findobjinternal(eventSourceObj,'type','axes');

                for i=1:numel(allAx)
                    ax=allAx(i);

                    if~isempty(ax.Toolbar)&&isvalid(ax.Toolbar)
                        ax.Toolbar.redrawToolbar();
                    end
                end
            end
        end

        function handleMouseMotion(obj,eventSourceObj,mouseData)
            obj.handleMouseMotion@matlab.graphics.controls.ToolbarController(eventSourceObj,mouseData);





            if~obj.IsLiveEditorFigure&&~obj.IsDesignTimeFigure

                [~,ax]=translateEvent(obj,eventSourceObj,mouseData);

                obj.cleanupStrandedToolbars(ax);
            end

            if isempty(obj.ResizeListener)
                [fig,~]=translateEvent(obj,eventSourceObj,mouseData);
                obj.ResizeListener=event.listener(fig,'SizeChanged',@(e,d)obj.handleResize(e,d));
            end




            if~strcmp(mouseData.EventName,'ButtonUp')

                obj.updatePointer(eventSourceObj,mouseData);
            end
        end



        function handleMouseExited(obj,eventSourceObj,mouseData)
            obj.handleMouseExited@matlab.graphics.controls.ToolbarController(eventSourceObj,mouseData);
        end



        function handleModeChange(obj,ax,evd)
            obj.ModeStrategy.handleModeChange(ax,evd);
        end

        function setToolbarModeState(obj,ax,evd)
            obj.ModeStrategy.setToolbarModeState(ax,evd);
        end

        function createListeners(obj,canvas,ax)


            if~obj.ListenersAdded


                toolbarEnterExit=matlab.graphics.interaction.graphicscontrol.InteractionObjects.EnterExitInteraction;
                toolbarEnterExit.Canvas=canvas;
                toolbarEnterExit.Object=ax.Toolbar;
                canvas.InteractionsManager.registerInteraction(ax.Toolbar,toolbarEnterExit);

                axesEnterExit=matlab.graphics.interaction.graphicscontrol.InteractionObjects.EnterExitInteraction;
                axesEnterExit.Canvas=canvas;
                axesEnterExit.Object=ax;
                canvas.InteractionsManager.registerInteraction(ax,axesEnterExit);


                obj.createListeners@matlab.graphics.controls.ToolbarController(canvas,ax);
            end



            obj.ModeStrategy.createListeners(canvas,ax);
        end





        function handleMouseDown(obj,eventSourceObj,mouseData)
            obj.handleMouseDown@matlab.graphics.controls.ToolbarController(eventSourceObj,mouseData);

            if isempty(obj.LastHitEvent)
                obj.LastHitEvent=mouseData;
            end
        end

        function handleMouseUp(obj,eventSourceObj,mouseData)
            evtData=mouseData;

            if isempty(evtData.Primitive)
                if~isempty(obj.LastHitEvent)&&...
                    abs(evtData.X-obj.LastHitEvent.X)<obj.HIT_THRESHOLD&&...
                    abs(evtData.Y-obj.LastHitEvent.Y)<obj.HIT_THRESHOLD
                    evtData=obj.LastHitEvent;
                end
            end

            obj.LastHitEvent=[];

            obj.handleMouseUp@matlab.graphics.controls.ToolbarController(eventSourceObj,evtData);
        end

        function result=axesHandleVisibleOff(~,ax)
            result=strcmp(ax.HandleVisibility,'off')||strcmp(ax.HitTest,'off');
        end

        function ax=getHitAxes(obj,mouseData)
            ax=obj.getHitAxes@matlab.graphics.controls.ToolbarController(mouseData);
            tb=[];


            if isprop(mouseData,'Primitive')&&~isempty(mouseData.Primitive)






                ax=ancestor(mouseData.Primitive,'matlab.graphics.axis.AbstractAxes','node');
                tb=ancestor(mouseData.Primitive,'matlab.graphics.controls.AxesToolbar','node');
            end

            if~isempty(tb)
                ax=tb.Axes;
            end


            if~isempty(ax)
                if strcmpi(ax.Tag,'PlotMatrixScatterAx')||...
                    strcmpi(ax.Tag,'PlotMatrixHistAx')
                    ax=findobj(ax.Parent,'Tag','PlotMatrixBigAx');
                end
            end
        end

    end
end

function localCleanupStrandedToolbars(obj,ax)
    if isvalid(obj)&&~isempty(obj)
        obj.cleanupStrandedToolbars(ax);
    end
end
