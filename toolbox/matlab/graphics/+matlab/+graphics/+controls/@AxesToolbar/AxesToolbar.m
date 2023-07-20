classdef(ConstructOnLoad,Hidden,AllowedSubclasses={?TestAxesToolbar,?matlab.ui.controls.AxesToolbar})AxesToolbar<...
    matlab.graphics.primitive.world.Group&...
    matlab.graphics.mixin.SceneNodeGroup&...
    matlab.graphics.mixin.AxesParentable&...
    matlab.graphics.internal.Legacy






    properties(Hidden,Transient,NonCopyable,GetAccess=?matlab.graphics.controls.AxesToolbarButton,SetAccess=protected)
        ButtonGroup;
    end

    properties(Access=protected,Transient,NonCopyable)
FadeGroup
PixelGroup
Background
OverflowBackground
OverflowButton
FadeTimer
    end

    properties(Access=protected)
        Minimized=false;
        IsInsideAxes=false;
        CachedVisibilityForPrint;
    end

    properties(Access={?matlab.graphics.controls.ToolbarController,...
        ?matlab.graphics.interaction.internal.UnifiedAxesInteractions,...
        ?matlab.graphics.controls.internal.AxesToolbarInteraction,...
        ?TestAxesToolbar,...
        ?tAxesToolbar})
        Axes;


        ToolbarAnchorPoint=[0,0];


        ToolbarMidPoint=[0,0];

        isMobile;
    end

    properties(Access={?matlab.graphics.controls.ToolbarController,...
        ?matlab.graphics.interaction.internal.UnifiedAxesInteractions,...
        ?TestAxesToolbar,...
        ?tAxesToolbar},Transient,NonCopyable)

        Interaction=[];
    end

    properties(Access=private,Transient)
        Opacity_I=0;



        HasTrueParent=false;


        IsOpen=false;
    end

    properties(Access={?matlab.graphics.controls.ToolbarController,...
        ?matlab.graphics.controls.internal.FigureBasedModeStrategy,...
        ?matlab.graphics.interaction.graphicscontrol.AxesToolbarControl,...
        ?TestAxesToolbar,?tAxesToolbar,?AxesToolbarFriend},Dependent)
        Opacity(1,1){...
        mustBeGreaterThanOrEqual(Opacity,0),...
        mustBeLessThanOrEqual(Opacity,1)}
    end

    properties(Access=?matlab.graphics.chart.GeographicBubbleChart)










        ToolbarHeight=20;
    end

    properties(Access=private,Transient,NonCopyable)


NodeListener


        SelectionChangedListener;


VisibleListener


        AxesDeletedListener;


        FadeOutListener;


        PositionChangeListener;


        AxesHandleVisibleChangeListener;
        AxesHitTestChangeListener;


        ModeListener;
        ModeManagerListener;
    end

    events(NotifyAccess={?matlab.ui.controls.ToolbarStateButton})
        SelectionChanged;
    end

    properties(Hidden,Transient,Access={?matlab.ui.controls.ToolbarStateButton})
        CurrentSelection matlab.internal.datatype.matlab.graphics.datatype.HandleOrEmpty=[];
    end

    properties(NonCopyable)
        SelectionChangedFcn matlab.internal.datatype.matlab.graphics.datatype.Callback=[];
    end

    methods(Hidden,Access={?tAxesToolbar,?AxesToolbarFriend})
        function color=getBackgroundColor(obj)
            color=obj.Background.Color;
        end

        function pos=getBackgroundPosition(obj)
            pos=obj.Background.Position;
        end

        function hOverflowBackground=getOverFlowBackground(obj)
            hOverflowBackground=obj.OverflowBackground;
        end

        function hOverFlowButton=getOverFlowButton(obj)
            hOverFlowButton=obj.OverflowButton;
        end
    end

    methods(Hidden,Access={?graphicstest.utils.AxesToolbarTester})
        function trueVisibility=getTrueVisibility(obj)
            trueVisibility='off';
            if obj.Opacity_I>0
                trueVisibility='on';
            end
        end
    end

    methods(Hidden,Access={?qehgtools.internal.testers.QEHGAxesToggleButtonTester})
        function hCurrentSelection=getCurrentSelection(obj)
            hCurrentSelection=obj.CurrentSelection;
        end
    end

    methods(Hidden)
        function obj=AxesToolbar(varargin)


            obj.FadeGroup=matlab.graphics.controls.internal.FadeGroup(...
            'Alpha',obj.Opacity_I,...
            'Internal',true);
            obj.addNode(obj.FadeGroup);


            obj.PixelGroup=matlab.graphics.controls.internal.ControlsGroup(...
            'Parent',obj.FadeGroup,...
            'Visible','on',...
            'Internal',true);



            obj.Background=matlab.graphics.controls.internal.Backdrop(...
            'Parent',obj.PixelGroup,...
            'Color',uint8([240,240,240,240]));
            obj.Background.Layer='back';
            obj.Background.setPickableParts('visible');

            obj.OverflowBackground=matlab.graphics.controls.internal.Backdrop(...
            'Parent',obj.PixelGroup,...
            'Visible','off',...
            'Color',uint8([240,240,240,240]));
            obj.OverflowBackground.Layer='back';
            obj.OverflowBackground.setPickableParts('visible');

            obj.ButtonGroup=matlab.graphics.primitive.Group(...
            'Parent',obj.PixelGroup,...
            'Internal',true);

            obj.Type='AxesToolbar';

            obj.Copyable=false;


            pb=hggetbehavior(obj,'Print');
            pb.PrePrintCallback=@(e,d)obj.printCallback(d);
            pb.PostPrintCallback=@(e,d)obj.printCallback(d);






            obj.NodeListener=event.listener(obj,'NodeChildAdded',@handleNodeAdded);

            obj.SelectionChangedListener=event.listener(obj,'SelectionChanged',...
            @handleSelectionChanged);



            obj.OverflowButton=[];

            if nargin
                set(obj,varargin{:});
            end

            obj.VisibleListener=event.proplistener(obj,findprop(obj,'Visible'),...
            'PostSet',@(~,~)togglePickable(obj));
        end

        function handleNodeAdded(src,evt)
            child=evt.ChildNode;
            if~isempty(child)
                child.Parent=src;
            end
        end



        function addToolbarButtons(obj,btn)
            btn.Parent=obj;
        end



        function buttons=getToolbarButtons(obj)
            buttons=obj.ButtonGroup.NodeChildren;
            ddButtons=[];

            for i=1:numel(buttons)
                element=buttons(i);

                if isa(element,'matlab.ui.controls.ToolbarDropdown')
                    ddButtons=[ddButtons;element.Children];
                end
            end

            buttons=[buttons;ddButtons];
        end
    end

    methods
        function set.ToolbarAnchorPoint(obj,newValue)
            obj.ToolbarAnchorPoint=newValue;
        end

        function set.Opacity(obj,newValue)
            obj.Opacity_I=newValue;

            obj.FadeGroup.Alpha=newValue;



            if newValue==0
                obj.FadeGroup.Visible='off';
            else
                obj.FadeGroup.Visible='on';
            end
        end

        function val=get.Opacity(obj)
            val=obj.Opacity_I;
        end

        function delete(obj)
            if~isempty(obj)
                obj.deleteListeners();
                delete(obj.FadeOutListener);


                if~isempty(obj.FadeTimer)&&isvalid(obj.FadeTimer)
                    stop(obj.FadeTimer);
                    delete(obj.FadeTimer);
                end

                if~isempty(obj.Interaction)&&isvalid(obj.Interaction)
                    delete(obj.Interaction);
                end
            end
        end
    end

    methods(Static,Hidden)

        function showToolbarForTest(ax)
            tb=ax.Toolbar;

            actionData=struct();
            actionData.enterexit='Entered';

            if~isempty(tb)
                if isempty(tb.Interaction)||~isvalid(tb.Interaction)
                    canvasContainer=ancestor(ax,'matlab.ui.internal.mixin.CanvasHostMixin');
                    canvas=canvasContainer.getCanvas();

                    if isa(canvas,'matlab.graphics.primitive.canvas.HTMLCanvas')
                        tbi=matlab.graphics.controls.internal.AxesToolbarInteraction(canvas,ax,tb);

                        tb.Interaction=tbi;
                        tb.Interaction.response(actionData);
                    end
                end

                tb.Interaction.response(actionData);


                tb.Opacity=1;
            end
        end


        function hideToolbarForTest(ax)
            tb=ax.Toolbar;

            actionData=struct();
            actionData.enterexit='Exited';


            if~isempty(tb)

                if isempty(tb.Interaction)
                    canvasContainer=ancestor(ax,'matlab.ui.internal.mixin.CanvasHostMixin');
                    canvas=canvasContainer.getCanvas();

                    if isa(canvas,'matlab.graphics.primitive.canvas.HTMLCanvas')
                        tbi=matlab.graphics.controls.internal.AxesToolbarInteraction(canvas,ax,tb);

                        tb.Interaction=tbi;
                        tb.Interaction.response(actionData);
                    end
                end


                btns=tb.getToolbarButtons();

                for i=1:length(btns)
                    element=btns(i);

                    dropDown=ancestor(element,'matlab.ui.controls.ToolbarDropdown');

                    if~isempty(dropDown)
                        dropDown.doClose();
                    end

                    element.unhover();
                end

                tb.Opacity=0;
            end
        end
    end

    methods(Access={?matlab.graphics.controls.internal.AxesToolbarInteraction,...
        ?matlab.graphics.controls.internal.AxesToolbarButtonInteraction,...
        ?matlab.graphics.controls.internal.AxesToolbarButtonClickInteraction,...
        ?matlab.graphics.interaction.graphicscontrol.AxesToolbarControl,...
        ?matlab.graphics.controls.WebToolbarController,...
        ?TestAxesToolbar,?tAxesToolbar})




        function setPosition(obj,ax)
            if isvalid(obj)
                canvasContainingAncestor=getCanvasContainingAncestor(ax);
                axesInfo=getAxesInfo(ax,canvasContainingAncestor);
                if isempty(axesInfo)
                    return
                end


                tbAncestor=ancestor(obj.NodeParent,'matlab.ui.internal.mixin.CanvasHostMixin');
                if tbAncestor~=canvasContainingAncestor
                    obj.parentToolbarToAxesPane(ax);
                end


                if isempty(obj.OverflowButton)
                    obj.createOverflowButton()
                end
                obj.setToolbarAnchorPosition(axesInfo.PlotBox,false);
                doMatch=false;
                if~isa(ax,'matlab.graphics.layout.Layout')
                    hFig=ancestor(ax,'figure');
                    if isempty(hFig)
                        return;
                    end

                    vp=matlab.graphics.interaction.internal.getViewportInDevicePixels(hFig,canvasContainingAncestor);
                    doMatch=matlab.graphics.interaction.internal.isAxesHit(ax,vp,obj.ToolbarMidPoint,[0,0]);
                end

                obj.matchBackgroundColor(ax,doMatch,false);
            end
        end

        function show(obj)

            if~isempty(obj.FadeTimer)&&strcmp(obj.FadeTimer.Running,'on')
                stop(obj.FadeTimer);
            end



            obj.Opacity=1;
            obj.redrawToolbar();
        end

        function hide(obj)
            if isempty(obj.FadeTimer)
                obj.FadeTimer=matlab.graphics.controls.FadeTimer(...
                'ObjectVisibility','off',...
                'Period',0.1,...
                'ExecutionMode','fixedRate',...
                'Name','TB_FadeOutTimer');
                obj.FadeOutListener=event.listener(obj.FadeTimer,...
                'Fade',@(s,e)obj.fade(1-s.CurrentFade));
            end


            btns=obj.getToolbarButtons();

            for i=1:length(btns)
                element=btns(i);

                dropDown=ancestor(element,'matlab.ui.controls.ToolbarDropdown');

                if~isempty(dropDown)
                    dropDown.doClose();
                end

                element.unhover();
            end


            if strcmp(obj.FadeTimer.Running,'on')
                return;
            end

            start(obj.FadeTimer,1-obj.Opacity);
        end

        function fade(obj,alpha)
            if~isempty(obj)&&isvalid(obj)&&...
                ~strcmp(obj.BeingDeleted,'on')&&...
                ~isequal(obj.Opacity,alpha)

                obj.Opacity=alpha;


                obj.redrawToolbar();
            end
        end

    end
    methods(Access={?matlab.graphics.controls.internal.AxesToolbarInteraction,...
        ?matlab.graphics.controls.internal.AxesToolbarButtonInteraction,...
        ?matlab.graphics.controls.internal.AxesToolbarButtonClickInteraction,...
        ?matlab.graphics.interaction.graphicscontrol.AxesToolbarControl,...
        ?matlab.graphics.controls.WebToolbarController,...
        ?TestAxesToolbar,?tAxesToolbar,...
        ?matlab.internal.editor.FigureProxy})

        function setTrueParent(obj,parent)
            obj.parentToolbarToAxesPane(parent);
        end
    end

    methods(Access={?matlab.graphics.controls.ToolbarController,?TestAxesToolbar,...
        ?tToolbarController,?tWebToolbarController,?AxesToolbarFriend,...
        ?matlab.graphics.controls.internal.AxesToolbarInteraction,...
        ?matlab.graphics.interaction.internal.UnifiedAxesInteractions})


        function ap=parentToolbarToAxesPane(obj,ax)
            ap=obj.NodeParent;

            if isempty(ap)||ancestor(ap,'matlab.ui.internal.mixin.CanvasHostMixin')~=ancestor(ax,'matlab.ui.internal.mixin.CanvasHostMixin')


                canvasContainingAncestor=localGetCanvasContainingAncestor(ax);

                if~isempty(canvasContainingAncestor)



                    ap=matlab.graphics.annotation.internal.getDefaultCamera(canvasContainingAncestor,'overlay','-peek');



                    if isempty(ap)
                        ap=matlab.graphics.shape.internal.AnnotationPane('Parent',...
                        canvasContainingAncestor,'Serializable','off');
                    end




                    obj.Axes=[];
                    obj.deleteListeners();

                    ap.addNode(obj);
                    obj.Axes=ax;
                    obj.HasTrueParent=true;
                    obj.addListeners(obj.Axes);


                    obj.togglePickable();





                    if~isempty(ax)&&isvalid(ax)&&isa(ax,'matlab.graphics.axis.AbstractAxes')&&...
                        ancestor(ap,'matlab.ui.internal.mixin.CanvasHostMixin')~=ancestor(ax,'matlab.ui.internal.mixin.CanvasHostMixin')
                        obj.registerToolbarInteraction(ax,canvasContainingAncestor.getCanvas());
                    end
                end
            end
        end

        function addListeners(obj,ax)



            obj.AxesDeletedListener=event.listener(ax,...
            'ObjectBeingDestroyed',@(e,d)obj.handleDeletedAxes(e,d));


            obj.AxesHandleVisibleChangeListener=event.proplistener(ax,ax.findprop('HandleVisibility'),...
            'PostSet',@(~,~)obj.redrawToolbar());


            if isa(ax,'matlab.graphics.axis.AbstractAxes')


                obj.PositionChangeListener=event.listener(ax,...
                'OuterPositionChanged',@(e,~)obj.outerPositionChangedHandler(e));

                obj.AxesHitTestChangeListener=event.proplistener(ax,ax.findprop('HitTest'),...
                'PostSet',@(~,~)obj.redrawToolbar());
            end


            fig=ancestor(ax,'figure');
            if~isempty(fig)&&isprop(fig,'ModeManager')&&~isempty(fig.ModeManager)...
                &&~isstruct(fig.ModeManager)
                if isempty(obj.ModeListener)
                    obj.ModeListener=event.proplistener(fig.ModeManager,...
                    fig.ModeManager.findprop('CurrentMode'),'PostSet',@(~,~)obj.redrawToolbar());
                end
            else



                obj.ModeManagerListener=matlab.graphics.controls.internal.ModeManagerListener(...
                ?matlab.uitools.internal.uimodemanager,'InstanceCreated',@(e,d)obj.handleModeManagerCreation(d.Instance,fig),fig);
            end
        end

        function outerPositionChangedHandler(obj,ax)
            canvasContainingAncestor=getCanvasContainingAncestor(ax);

            axesInfo=getAxesInfo(ax,canvasContainingAncestor);
            if isempty(axesInfo)
                return
            end




            if~isprop(ax,'PlotBox')
                hprop=addprop(ax,'PlotBox');
                hprop.Hidden=true;
                hprop.Transient=true;
            end
            if isequal(ax.PlotBox,axesInfo.PlotBox)
                return
            end
            ax.PlotBox=axesInfo.PlotBox;
            obj.setPosition(ax);
        end

        function handleModeManagerCreation(obj,modeManagerInstance,fig)
            if isequal(modeManagerInstance.Figure,fig)
                delete(obj.ModeManagerListener);
                obj.ModeListener=event.proplistener(fig.ModeManager,...
                fig.ModeManager.findprop('CurrentMode'),'PostSet',@(~,~)obj.redrawToolbar());
            end
        end

        function deleteListeners(obj)
            delete(obj.AxesDeletedListener);
            delete(obj.PositionChangeListener);
            delete(obj.AxesHandleVisibleChangeListener);
            delete(obj.AxesHitTestChangeListener);
            delete(obj.ModeListener);
        end



        function handleDeletedAxes(obj,~,~)


            if isvalid(obj)&&~isempty(obj.PositionChangeListener)&&...
                isvalid(obj.PositionChangeListener)
                delete(obj.PositionChangeListener);
            end


            if isvalid(obj)&&~isempty(obj.AxesHandleVisibleChangeListener)&&...
                isvalid(obj.AxesHandleVisibleChangeListener)
                delete(obj.AxesHandleVisibleChangeListener);
            end


            if isvalid(obj)&&~isempty(obj.AxesHitTestChangeListener)&&...
                isvalid(obj.AxesHitTestChangeListener)
                delete(obj.AxesHitTestChangeListener);
            end


            if isvalid(obj)&&~isempty(obj.ModeListener)&&isvalid(obj.ModeListener)
                delete(obj.ModeListener);
            end



            if isvalid(obj)&&~isvalid(obj.Axes)
                obj.Parent=[];
                delete(obj);
            end
        end



        function redrawToolbar(obj)
            obj.MarkDirty('all');
        end


        function result=isShowing(obj)
            result=strcmp(obj.PixelGroup.Visible,'on');
        end

        function matchBackgroundColor(obj,ax,matchAxes,doMarkDirty)

            colorProp="Color";
            if obj.IsInsideAxes&&strcmp(ax.Visible,'on')&&matchAxes
                container=ax;

            else
                container=localGetCanvasContainingAncestor(obj);


                if isempty(container)
                    container=localGetCanvasContainingAncestor(ax);
                end
                if~isa(container,"matlab.ui.Figure")
                    colorProp="BackgroundColor";
                end
            end

            if isempty(container)
                return
            end

            if isprop(container,colorProp)
                color=get(container,colorProp);
            else
                return;
            end
            if~ischar(color)
                if nargin<=3
                    obj.setBackgroundColor(color,0.9,true);

                else
                    obj.setBackgroundColor(color,0.9,doMarkDirty);
                end
            end
        end


        function setBackgroundColor(obj,color,pqColor,doMarkDirty)
            newColor=uint8(255*[color,pqColor]);
            if~isequal(obj.Background.Color,newColor)
                obj.Background.Color=newColor;
                if~isempty(obj.OverflowButton)
                    obj.OverflowBackground.Color=newColor;

                    obj.OverflowButton.BackgroundColor=double(newColor(1:3));
                end

                if nargin<=3||doMarkDirty
                    obj.MarkDirty('all');
                end
            end
        end

        function[pos,units]=getPositionFromCanvasContainer(~,cca)
            isGridLayout=isa(cca,'matlab.ui.container.GridLayout');


            if isGridLayout
                pos=cca.Position;
                units='pixels';

            else
                pos=cca.InnerPosition;
                units=cca.Units;
            end
        end

        function result=isInsideToolbar(~,mouseData)


            tb=ancestor(mouseData.Primitive,'matlab.graphics.controls.AxesToolbar','node');

            result=~isempty(tb);
        end
    end

    methods(Hidden)
        doUpdate(obj,updateState)
        setInternalPosition(obj,updateState);
        var=isEnabledForAxes(obj,ax,button);
        name=getBehaviorName(obj,var);
        result=canRegisterInteraction(obj,ax);




        function result=hasValidParent(obj)
            result=isempty(obj.Parent)||...
            isa(obj.Parent,'matlab.graphics.axis.AbstractAxes')||...
            isa(obj.Parent,'matlab.graphics.layout.Layout');
        end



        function ignore=mcodeIgnoreHandle(~,~)
            ignore=true;
        end
    end

    methods(Access='public',Hidden=true)

        function trueParent=addChild(hObj,newChild)
            trueParent=hObj;


            if isa(newChild,'matlab.graphics.controls.AxesToolbarButton')
                newChild.Parent=hObj;
                trueParent=hObj.ButtonGroup;
            end
        end

        function firstChild=doGetChildren(hObj)

            hPar=hObj.ButtonGroup;
            firstChild=matlab.graphics.primitive.world.Group.empty;
            if isempty(hPar)||~isvalid(hPar)
                return;
            else
                allChil=hgGetTrueChildren(hPar);
                if~isempty(allChil)
                    firstChild=allChil(1);
                end
            end
        end

        function hParent=getParentImpl(obj,hParentIn)


            hParent=hParentIn;
            if~isempty(hParentIn)

                parent=obj.Axes;
                if~isempty(parent)
                    hParent=parent;
                end
            elseif~obj.HasTrueParent
                hParent=obj.Axes;
            end
        end

        function actualValue=setParentImpl(obj,proposedValue)
            if~isempty(proposedValue)
                if isa(proposedValue,'matlab.graphics.axis.AbstractAxes')



                    obj.Axes=proposedValue;
                    actualValue=obj.parentToolbarToAxesPane(proposedValue);
                elseif isa(proposedValue,'matlab.graphics.layout.Layout')
                    obj.Axes=proposedValue;
                    actualValue=obj.parentToolbarToAxesPane(proposedValue);
                elseif isa(proposedValue,'matlab.graphics.shape.internal.AnnotationPane')
                    actualValue=proposedValue;
                elseif isa(proposedValue,'matlab.graphics.shape.internal.FakeOverlay')
                    actualValue=proposedValue;
                else
                    error(message('MATLAB:graphics:configureAxes:AxesToolbarParentError'));
                end
            else

                actualValue=proposedValue;
            end
        end
    end

    methods(Access='protected',Hidden=true)
        function handleSelectionChanged(obj,eventData)
            if~isempty(obj.SelectionChangedFcn)
                try


                    hgfeval(obj.SelectionChangedFcn,obj,eventData);
                catch ex

                    warnState=warning('off','backtrace');
                    warning(message('MATLAB:graphics:axestoolbar:ErrorWhileEvaluating',ex.message,'SelectionChangedFcn'));
                    warning(warnState);
                end
            end
        end

        function varargout=getPropertyGroups(~)
            varargout{1}=matlab.mixin.util.PropertyGroup(...
            {'Visible','SelectionChangedFcn'});
        end

        function printCallback(obj,type)

            if strcmp(type,'PrePrintCallback')
                obj.CachedVisibilityForPrint=obj.Visible_I;
                obj.Visible_I='off';
                obj.ButtonGroup.Visible_I='off';
            elseif strcmp(type,'PostPrintCallback')
                if~isempty(obj.CachedVisibilityForPrint)
                    obj.Visible_I=obj.CachedVisibilityForPrint;
                    obj.ButtonGroup.Visible_I='on';
                    obj.CachedVisibilityForPrint=[];
                else



                    warnState=warning('off','backtrace');
                    warning(message('MATLAB:graphics:axestoolbar:PrintWarning'));
                    warning(warnState);
                end
            end
        end

        function togglePickable(obj)
            val='all';

            if strcmpi(obj.Visible,'off')
                val='visible';
            end

            buttons=obj.getToolbarButtons();
            for i=1:numel(buttons)
                element=buttons(i);
                if strcmp(element.Visible,'on')
                    element.togglePickable(val);
                else
                    element.togglePickable('visible');
                end
            end
        end
    end
end

function canvasContainingAncestor=localGetCanvasContainingAncestor(target)

    canvasContainingAncestor=ancestor(target,'matlab.ui.internal.mixin.CanvasHostMixin');
    if isempty(canvasContainingAncestor)
        canvasContainingAncestor=ancestor(target,'figure');
    end
end

function canvasContainingAncestor=getCanvasContainingAncestor(ax)
    canvasContainingAncestor=ancestor(ax,'matlab.ui.internal.mixin.CanvasHostMixin');
    if isempty(canvasContainingAncestor)
        canvasContainingAncestor=ancestor(ax,'figure');
    end
end

function axesInfo=getAxesInfo(ax,canvasContainingAncestor)

    axesInfo=[];

    canvas=canvasContainingAncestor.getCanvas();
    isHTMLCanvas=isa(canvas,'matlab.graphics.primitive.canvas.HTMLCanvas');

    if isa(canvasContainingAncestor,'hgunithelper.FakeFigure')||...
        ~isHTMLCanvas
        return;
    end

    hFig=ancestor(ax,'figure');
    if isempty(hFig)
        return;
    end

    if isa(ax,'matlab.graphics.layout.Layout')



        axesInfo.is2D=true;
        axesInfo.PlotBox=hgconvertunits(hFig,ax.Position,...
        'normalized','pixels',canvasContainingAncestor);
        axesInfo.Position=layout.Position;
    else
        axesInfo=ax.GetLayoutInformation();
    end
end
