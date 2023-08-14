classdef ToolbarController<handle&matlab.graphics.controls.internal.PointerMixin




    properties(Access=private,Constant)
        MIN_FIGURE_PIX_HEIGHT=100;
        MIN_FIGURE_PIX_WIDTH=200;


        TOLERANCE=1;

    end

    properties(Constant)
        ASSUMED_SCROLLBAR_WIDTH=9;
        EDGE_PADDING=5;
    end

    events
ProcessInteractions
    end

    methods(Static,Hidden)

        function obj=getInstance(canvas,varargin)
            obj=matlab.graphics.controls.ToolbarController(canvas,varargin{:});
        end



        function[result,scrollPosition]=hasScrolled(hObj)
            result=[false,false];
            scrollPosition=[1,1];
            scrollableAncestor=ancestor(hObj,'matlab.ui.internal.mixin.Scrollable');
            if~isempty(scrollableAncestor)&&scrollableAncestor.Scrollable=="on"
                scrollPosition=scrollableAncestor.ScrollableViewportLocation;

                result=[true,true];
            end
        end
    end

    properties(Access=protected)
        ListenersAdded=false;
    end

    properties(Access=protected)

        ModeListener;


        ModeStateDataListener;


ResizeListener



        CurrentAxes;


        CurrentToolbar;


        ToolTipTimer_I;



        ModeManagerListener;


        MotionListener;



        PrimitivieDeletedListener;
    end

    properties

        ModeStrategy;
    end

    properties(Dependent,Hidden)
        ToolTipTimer;
    end

    methods(Static)

        function tb=getDefaultToolbar(ax)
            tb=matlab.ui.controls.AxesToolbar();

            if~isa(ax,'matlab.graphics.axis.GeographicAxes')&&...
                ~isa(ax,'map.graphics.axis.MapAxes')&&...
                ~isa(ax,'matlab.graphics.axis.PolarAxes')
                tb.Parent=ax;
            else
                tb.Axes=ax;
            end

            try

                buttons=matlab.graphics.controls.ToolbarController.createToolbarButton...
                (matlab.graphics.controls.internal.ToolbarValidator.default,ax);



                tb.Serializable='off';

                for idx=1:length(buttons)
                    button=buttons(idx);
                    if~isempty(button)
                        button.Parent=tb;
                        button.HandleVisibility='off';
                        button.Serializable='off';
                    end
                end

            catch
                delete(tb);
                tb=[];
            end
        end


        function axesToolbarButton=createToolbarButton(buttonType,varargin)
            import matlab.graphics.controls.internal.ToolbarValidator;




            if strcmpi(char(buttonType),ToolbarValidator.default)
                axesToolbarButton=[
                matlab.graphics.controls.ToolbarController.createToolbarButton(ToolbarValidator.restoreview,varargin{:});
                matlab.graphics.controls.ToolbarController.createToolbarButton(ToolbarValidator.zoomout,varargin{:});
                matlab.graphics.controls.ToolbarController.createToolbarButton(ToolbarValidator.zoomin,varargin{:});
                matlab.graphics.controls.ToolbarController.createToolbarButton(ToolbarValidator.stepzoomout,varargin{:});
                matlab.graphics.controls.ToolbarController.createToolbarButton(ToolbarValidator.stepzoomin,varargin{:});
                matlab.graphics.controls.ToolbarController.createToolbarButton(ToolbarValidator.pan,varargin{:});
                matlab.graphics.controls.ToolbarController.createToolbarButton(ToolbarValidator.rotate,varargin{:});
                matlab.graphics.controls.ToolbarController.createToolbarButton(ToolbarValidator.datacursor,varargin{:});
                matlab.graphics.controls.ToolbarController.createToolbarButton(ToolbarValidator.brush,varargin{:});
                matlab.graphics.controls.ToolbarController.createToolbarButton(ToolbarValidator.export,varargin{:});
                ];
            else

                reg=matlab.graphics.controls.internal.ToolbarButtonRegistry.getInstance();

                axesToolbarButton=reg.getButton(buttonType,varargin{:});
            end
        end
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

    methods(Access=private)
        function t=createTooltipTimer(obj)
            t=timer('StartDelay',1,'Name','TC_ToolTipTimer');
            cb=@(e,d)obj.showToolTip(t.UserData);
            t.TimerFcn=matlab.graphics.controls.internal.timercb(cb);
        end
    end

    methods
        function t=get.ToolTipTimer(obj)
            if isempty(obj.ToolTipTimer_I)||~isvalid(obj.ToolTipTimer_I)
                obj.ToolTipTimer_I=obj.createTooltipTimer();
            end

            t=obj.ToolTipTimer_I;
        end
    end

    methods(Access=protected)
        function obj=ToolbarController(canvas,varargin)

            if matlab.graphics.interaction.internal.isPublishingTest()
                return;
            end

            if~matlab.ui.internal.hasDisplay||~matlab.ui.internal.isFigureShowEnabled


                if~isa(canvas,'matlab.graphics.primitive.canvas.HTMLCanvas')
                    return;
                end
            end




            obj.MotionListener=addlistener(canvas,'ButtonMotion',@(e,d)obj.handleMouseMotion(e,d));

            addlistener(canvas,'ButtonExited',@(e,d)obj.handleMouseExited(e,d));
            addlistener(canvas,'ButtonDown',@(e,d)obj.handleMouseDown(e,d));
            addlistener(canvas,'ButtonUp',@(e,d)obj.handleMouseUp(e,d));



            addlistener(canvas,'ObjectBeingDestroyed',@(e,d)obj.delete());
        end
    end


    methods(Access=public)



        function handleMouseExited(obj,eventSourceObj,mouseData)



            if~isvalid(obj)||~isvalid(eventSourceObj)
                return;
            end



            if isprop(mouseData,'ExitedObjectType')&&strcmp(mouseData.ExitedObjectType,'ExitedObject')
                return
            end

            if~isempty(obj.CurrentToolbar)&&isvalid(obj.CurrentToolbar)
                obj.doButtonUnhover();
                obj.hideToolbar();
            end


            obj.updatePointer(eventSourceObj,mouseData);
        end





        function handleMouseDown(obj,~,mouseData)
            obj.MotionListener.Enabled=false;


            if~isempty(mouseData)&&isprop(mouseData,'Primitive')&&~isempty(mouseData.Primitive)...
                &&isvalid(mouseData.Primitive)

                obj.PrimitivieDeletedListener=addlistener(mouseData.Primitive,...
                'ObjectBeingDestroyed',@(e,d)obj.handleDeletedPrimitive(e,d));
            end

        end

        function handleMouseUp(obj,eventSourceObj,mouseData)
            obj.MotionListener.Enabled=true;


            delete(obj.PrimitivieDeletedListener);

            obj.handleMouseMotion(eventSourceObj,mouseData);
        end



        function handleMouseMotion(obj,eventSourceObj,mouseData)
            try
                [fig,ax]=translateEvent(obj,eventSourceObj,mouseData);





                if obj.isPublishing(fig)
                    obj.MotionListener.Enabled=false;
                    return;
                end



                if obj.useInteractionFramework(fig,ax)
                    tb=ax.Toolbar;

                    if~isempty(tb)&&isempty(tb.NodeParent)||...
                        ancestor(tb.NodeParent,'matlab.ui.internal.mixin.CanvasHostMixin')~=...
                        ancestor(ax.Parent,'matlab.ui.internal.mixin.CanvasHostMixin')

                        tb.parentToolbarToAxesPane(ax);
                    end



                    if~isempty(tb)&&(isempty(tb.Interaction)||...
                        ~isvalid(tb.Interaction))
                        tb.redrawToolbar();
                    end

                    return;
                end


                if~isempty(fig)&&isprop(fig,'UseLegacyExplorationModes')&&fig.UseLegacyExplorationModes&&...
                    isa(obj.ModeStrategy,'matlab.graphics.controls.internal.AxesBasedModeStrategy')
                    obj.ModeStrategy=matlab.graphics.controls.internal.FigureBasedModeStrategy;
                    obj.setPointerStrategy('figure');
                end

                if obj.canShowToolbar(fig,ax)

                    if~isempty(ax)&&isvalid(ax)&&strcmp(ax.BeingDeleted,'off')





                        if obj.axesHandleVisibleOff(ax)
                            return;
                        end



                        [layout,inLayout]=obj.isInLayout(ax);



                        if isa(ax,'matlab.graphics.axis.AbstractAxes')&&inLayout
                            tb=layout.Toolbar;
                            if isempty(tb)
                                tb=ax.Toolbar;
                                tb.createOverflowButton();
                            end
                        else
                            tb=ax.Toolbar;
                            tb.createOverflowButton();
                        end





                        if isdeployed...
                            &&(isa(ax,'matlab.graphics.axis.Axes')...
                            ||isa(ax,'matlab.graphics.axis.PolarAxes'))
                            ax.InteractionContainer.updateInteractions();
                        end

                        if~any(isvalid(ax.Toolbar))&&strcmp(ax.ToolbarMode,'auto')
                            ax.Toolbar=matlab.graphics.controls.ToolbarController.getDefaultToolbar(ax);
                            tb=ax.Toolbar;
                            ax.ToolbarMode='auto';
                        end

                        if isempty(tb)
                            return;
                        end

                        fig=ancestor(ax,'figure');



                        if isempty(fig)||strcmp(fig.Visible,'off')
                            return;
                        end


                        if strcmp(tb.Visible,'off')
                            return;
                        end



                        if obj.ModeStrategy.hasFigureChanged(fig)
                            obj.ListenersAdded=false;
                            obj.ModeStrategy.resetListeners();
                            obj.createListeners(eventSourceObj,ax);


                            obj.setToolbarModeState(ax,[]);
                        end





                        if isempty(obj.CurrentToolbar)


                            obj.setCurrentToolbar(tb);
                        elseif~isequal(obj.CurrentToolbar,tb)




                            obj.doButtonUnhover();


                            if isvalid(obj.CurrentToolbar)&&strcmp(obj.CurrentToolbar.BeingDeleted,'off')
                                obj.CurrentToolbar.Opacity=0;
                            end



                            obj.setCurrentToolbar(tb);
                        elseif~isempty(obj.CurrentAxes)

                            axesInfo=obj.getLayoutInformation(ax);
                            if(inLayout&&~obj.isDifferentLayout(ax))...
                                ||~obj.isDifferentAxesLayout(axesInfo)





                                if obj.isOverToolbar(mouseData)
                                    obj.doButtonHover(mouseData);
                                else
                                    obj.doButtonUnhover();
                                end

                                obj.setToolbarBackgroundColor(ax);


                                [hasScrolled,scrollPosition]=matlab.graphics.controls.ToolbarController.hasScrolled(ax);
                                if hasScrolled(1)
                                    pbx=axesInfo.PlotBox;
                                    pbx(3)=axesInfo.PlotBox(3)-scrollPosition(1);
                                    obj.CurrentToolbar.setToolbarAnchorPosition(pbx);
                                end
                                obj.showToolbar();
                                return;
                            end
                        end




                        obj.CurrentAxes=obj.getLayoutInformation(ax);





                        if isempty(tb.NodeParent)||...
                            ancestor(tb.NodeParent,'matlab.ui.internal.mixin.CanvasHostMixin')~=...
                            ancestor(ax.Parent,'matlab.ui.internal.mixin.CanvasHostMixin')


                            if~isempty(tb.NodeParent)&&strcmp(ax.ToolbarMode,'auto')
                                ax.Toolbar=[];
                                ax.ToolbarMode='auto';


                                tb=ax.Toolbar;
                            end
                            tb.Parent=[];

                            if inLayout&&~isempty(layout.Toolbar)...
                                &&tb==layout.Toolbar
                                tb.parentToolbarToAxesPane(layout);
                            else
                                tb.parentToolbarToAxesPane(ax);
                            end
                            obj.setCurrentToolbar(tb);
                        end



                        obj.createListeners(eventSourceObj,ax)


                        if strcmp(obj.CurrentToolbar.BeingDeleted,'off')
                            obj.setToolbarModeState(ax,mouseData);

                            stackedPlot=ancestor(ax,'matlab.graphics.chart.StackedLineChart','node');

                            if~isempty(stackedPlot)
                                cca=ancestor(stackedPlot,'matlab.ui.internal.mixin.CanvasHostMixin');
                                posTarget=hgconvertunits(fig,stackedPlot.Position,stackedPlot.Units,'pixels',cca);
                                obj.CurrentToolbar.setToolbarAnchorPosition(posTarget);
                            else
                                posTarget=obj.CurrentAxes.PlotBox;
                            end

                            obj.CurrentToolbar.setToolbarAnchorPosition(posTarget);


                            obj.setToolbarBackgroundColor(ax);

                            obj.showToolbar();
                        end
                    elseif~isempty(obj.CurrentToolbar)&&isvalid(obj.CurrentToolbar)


                        if~obj.inActiveArea(mouseData,eventSourceObj)

                            obj.doButtonUnhover();
                            obj.hideToolbar();
                        else


                            obj.CurrentToolbar.Opacity=1;
                            obj.doButtonHover(mouseData);
                        end
                    end
                end

            catch




            end
        end



        function result=isPublishing(~,fig)
            result=~isempty(fig)&&isvalid(fig)&&isprop(fig,'MW_PublishGeneratedFigure');
        end



        function result=useInteractionFramework(obj,fig,ax)
            result=false;

            layout=ancestor(ax,'matlab.graphics.layout.Layout','node');
            stackedChart=ancestor(ax,'matlab.graphics.chart.StackedLineChart');

            if~isempty(ax)&&isempty(layout)&&isempty(stackedChart)&&...
                ~isa(ax,'matlab.graphics.axis.PolarAxes')&&...
                ~contains(ax.Tag,"PlotMatrix",'IgnoreCase',true)&&...
                isa(obj,'matlab.graphics.controls.WebToolbarController')

                can=ancestor(ax,'matlab.graphics.primitive.canvas.Canvas','node');
                if~isempty(can)
                    result=strcmpi(ax.SortMethod_I,'childorder')&&~strcmp(can.ServerSideRendering,'on');
                end
            end
        end



        function handleDeletedPrimitive(obj,~,~)
            if~isempty(obj)&&isvalid(obj)
                obj.MotionListener.Enabled=true;

                delete(obj.PrimitivieDeletedListener);
            end
        end

    end

    methods(Access=public)



        function setCurrentToolbar(obj,tbar)
            obj.ModeStrategy.CurrentToolbar=tbar;
            obj.CurrentToolbar=tbar;
        end




        function createListeners(obj,canvas,ax)


            if~obj.ListenersAdded

                fig=obj.getCanvasFigure(canvas);



                addlistener(fig,'ObjectBeingDestroyed',@(e,d)obj.handleFigureDelete(e));

                obj.ResizeListener=event.listener(fig,'SizeChanged',@(e,d)obj.handleResize(e,d));

                obj.ListenersAdded=true;
            end


            obj.ModeStrategy.createListeners(canvas,ax);
        end

        function setToolbarModeState(obj,ax,evd)
            obj.ModeStrategy.setToolbarModeState(ax,evd);
        end


        function handleResize(obj,~,~)
            if~isempty(obj.CurrentToolbar)&&isvalid(obj.CurrentToolbar)
                obj.doButtonUnhover();
                obj.CurrentToolbar.Opacity=0;
            end
        end

        function HWCallbacksExist=checkIfHWCallbacksExist(~,fig)
            HWCallbacksExist=isvalid(fig)&&...
            (~isempty(fig.WindowButtonDownFcn)||...
            ~isempty(fig.WindowButtonMotionFcn)||...
            ~isempty(fig.WindowButtonUpFcn)||...
            ~isempty(fig.WindowScrollWheelFcn));
        end

        function[fig,ax]=translateEvent(obj,eventSourceObj,mouseData)
            fig=obj.getCanvasFigure(eventSourceObj);

            ax=obj.getHitAxes(mouseData);
        end

        function result=canShowToolbar(obj,fig,ax)
            if obj.isPlotEditMode(fig)
                result=false;
                return;
            end

            pos=fig.Position;


            if~strcmp(fig.Units,'pixels')

                pos=hgconvertunits(fig,pos,fig.Units,'pixels',groot);
            end

            result=pos(3)>obj.MIN_FIGURE_PIX_WIDTH&&...
            pos(4)>obj.MIN_FIGURE_PIX_HEIGHT;
        end

        function result=axesHandleVisibleOff(~,ax)
            result=true;
        end

        function axesInfo=getLayoutInformation(~,ax)
            layout=ancestor(ax,'matlab.graphics.layout.Layout','node');

            if(isa(ax,'matlab.graphics.layout.Layout')&&~isempty(ax.Toolbar))||...
                (~isempty(layout)&&~isempty(layout.Toolbar))

                canvasContainingAncestor=ancestor(ax,'matlab.ui.internal.mixin.CanvasHostMixin');
                if isempty(canvasContainingAncestor)
                    canvasContainingAncestor=ancestor(ax,'figure');
                end




                axesInfo.is2D=true;
                axesInfo.PlotBox=hgconvertunits(ancestor(ax,'figure'),layout.Position,...
                'normalized','pixels',canvasContainingAncestor);
                axesInfo.Position=layout.Position;
            else
                axesInfo=ax.GetLayoutInformation();
            end
        end


        function showToolbar(obj)
            if isempty(obj.CurrentToolbar)||~isvalid(obj.CurrentToolbar)||strcmp(obj.CurrentToolbar.BeingDeleted,'on')
                return;
            end


            if~isempty(obj.ResizeListener)
                obj.ResizeListener.Enabled=true;
            end



            if obj.CurrentToolbar.Opacity<1
                obj.CurrentToolbar.Opacity=1;
                obj.CurrentToolbar.redrawToolbar();
            end

        end

        function hideToolbar(obj)
            if isempty(obj.CurrentToolbar)||~isvalid(obj.CurrentToolbar)||strcmp(obj.CurrentToolbar.BeingDeleted,'on')
                return;
            end

            if obj.CurrentToolbar.Opacity>0
                obj.CurrentToolbar.Opacity=0;
            end
        end

        function fig=getCanvasFigure(~,canvas)
            if~isempty(canvas)
                fig=ancestor(canvas,'figure');
            else

                fig=[];
            end
        end

        function ax=getHitAxes(~,mouseData)



            ax=[];
        end

        function result=inActiveArea(obj,mouseData,canvas)

            result=obj.isOverToolbar(mouseData);

            if~result
                if~isempty(obj.CurrentAxes)



                    if isa(mouseData,'matlab.graphics.controls.internal.InvisibleAxesEnterExitEventData')
                        result=strcmp(mouseData.Direction,'mouseenter');
                        return;
                    end


                    height=canvas.Viewport(4);
                    x=mouseData.X;
                    y=height-mouseData.Y;

                    plotBox=obj.CurrentAxes.PlotBox;


                    if y>plotBox(2)&&y<=plotBox(2)+plotBox(4)&&...
                        x>plotBox(1)&&x<=plotBox(1)+plotBox(3)
                        result=true;
                    end
                end
            end
        end

        function isInside=isOverToolbar(obj,mouseData)
            isInside=false;

            if~isempty(obj.CurrentToolbar)
                if isprop(mouseData,'Primitive')&&~isempty(mouseData.Primitive)
                    isInside=obj.CurrentToolbar.isInsideToolbar(mouseData);
                end
            end
        end



        function doButtonUnhover(obj)
            if~isempty(obj.CurrentToolbar)&&isvalid(obj.CurrentToolbar)...
                &&strcmp(obj.CurrentToolbar.BeingDeleted,'off')



                if strcmp(obj.ToolTipTimer.Running,'on')
                    stop(obj.ToolTipTimer);
                    obj.ToolTipTimer.UserData=[];
                end

                btnChildren=obj.CurrentToolbar.getToolbarButtons();


                for idx=1:length(btnChildren)
                    btn=btnChildren(idx);
                    btn.unhover();

                    if isa(btn,'matlab.ui.controls.ToolbarDropdown')
                        btn.doClose();
                    else
                        btn.hideToolTip();
                    end
                end
            end
        end

        function doButtonHover(obj,mouseData)
            if~isempty(obj.CurrentToolbar)&&isvalid(obj.CurrentToolbar)




                if~isempty(mouseData.Primitive)

                    overButton=ancestor(mouseData.Primitive,'matlab.graphics.controls.AxesToolbarButton','node');


                    if isempty(overButton)
                        obj.doButtonUnhover();
                        return;
                    end



                    fig=ancestor(overButton,'figure');
                    matlab.graphics.interaction.internal.setPointer(fig,'arrow');

                    btnChildren=obj.CurrentToolbar.getToolbarButtons();

                    for idx=1:length(btnChildren)
                        btn=btnChildren(idx);

                        hasTooltip=isa(btn,'matlab.graphics.controls.internal.ToolTipMixin');



                        if isequal(overButton,btn)&&strcmp(btn.Visible,'on')

                            btn.hover();

                            if~isequal(btn,obj.ToolTipTimer.UserData)


                                stop(obj.ToolTipTimer);


                                if hasTooltip&&strcmp(obj.ToolTipTimer.Running,'off')


                                    obj.ToolTipTimer.UserData=btn;
                                    start(obj.ToolTipTimer);
                                end
                            end
                        else


                            btn.unhover();
                            if hasTooltip
                                btn.hideToolTip();
                            end
                        end
                    end
                end
            end
        end


        function showToolTip(obj,button)
            if~isempty(button)&&isvalid(button)

                button.showToolTip();


                stop(obj.ToolTipTimer);


                obj.ToolTipTimer.UserData=[];
            end
        end


        function setToolbarBackgroundColor(obj,ax)




            if isa(ax,'matlab.graphics.layout.Layout')
                isHit=false;
            else
                hFig=ancestor(ax,'figure');
                hContainer=ancestor(ax,'matlab.ui.internal.mixin.CanvasHostMixin');
                vp=matlab.graphics.interaction.internal.getViewportInDevicePixels(hFig,hContainer);
                isHit=matlab.graphics.interaction.internal.isAxesHit(ax,vp,obj.CurrentToolbar.ToolbarMidPoint,[0,0]);
            end

            obj.CurrentToolbar.matchBackgroundColor(ax,isHit);
        end

        function[layout,result]=isInLayout(~,ax)
            layout=ancestor(ax,'matlab.graphics.layout.Layout','node');

            result=~isempty(layout);
        end

        function result=isDifferentLayout(obj,ax)
            layout=ancestor(ax,'matlab.graphics.layout.Layout','node');

            result=~any(layout.Position==obj.CurrentAxes.PlotBox);
        end

        function result=isDifferentAxesLayout(obj,layoutInfo)




            result=~isequal(layoutInfo.is2D,obj.CurrentAxes.is2D)||...
            any(abs(layoutInfo.PlotBox-obj.CurrentAxes.PlotBox)>obj.TOLERANCE)||...
            any(abs(layoutInfo.Position-obj.CurrentAxes.Position)>obj.TOLERANCE);
        end




        function handleFigureDelete(obj,e,~)
            if isvalid(obj)&&~isempty(obj.CurrentToolbar)&&...
                isvalid(obj.CurrentToolbar)

                if isequal(ancestor(obj.CurrentToolbar,'figure'),e)
                    obj.CurrentToolbar.Parent=[];
                end
            end
        end

        function delete(obj)
            if~isempty(obj.ToolTipTimer_I)&&isvalid(obj.ToolTipTimer_I)
                stop(obj.ToolTipTimer_I);
                delete(obj.ToolTipTimer_I);
                obj.ToolTipTimer_I=[];
            end

            if~isempty(obj.ResizeListener)
                delete(obj.ResizeListener);
            end

            if~isempty(obj.ModeListener)
                delete(obj.ModeListener);
            end

            if~isempty(obj.ModeManagerListener)
                delete(obj.ModeManagerListener);
            end

            if~isempty(obj.MotionListener)
                delete(obj.MotionListener);
            end

            if~isempty(obj.PrimitivieDeletedListener)
                delete(obj.PrimitivieDeletedListener);
            end

        end

        function result=isPlotEditMode(~,fig)
            result=false;

            if~isempty(fig)&&isprop(fig,'ModeManager')&&~isempty(fig.ModeManager)
                mode=fig.ModeManager.CurrentMode;
                if~isempty(mode)
                    result=strcmp(mode.Name,'Standard.EditPlot');
                end
            end
        end
    end
end

