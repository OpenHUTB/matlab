classdef(Abstract,AllowedSubclasses={?images.roi.internal.AbstractFreehand,...
    ?images.roi.internal.AbstractPolygon,...
    ?images.roi.internal.AbstractPoint,...
    ?vision.roi.internal.ROI,...
    ?vision.roi.ProjectedCuboid,...
    ?images.roi.Circle,...
    ?images.roi.Cuboid,...
    ?images.roi.Ellipse,...
    ?images.roi.Line,...
    ?images.roi.Rectangle})...
    ROI<matlab.graphics.primitive.Data...
    &matlab.graphics.mixin.AxesParentable...
    &matlab.graphics.mixin.GeographicAxesParentable...
    &matlab.graphics.internal.GraphicsBaseFunctions...
    &images.roi.internal.DrawingCanvas





    events





DeletingROI





DrawingStarted




DrawingFinished





MovingROI





ROIMoved

























ROIClicked

    end

    properties(Abstract,Dependent)


Position

    end

    properties(Dependent)






Color










Deletable







EdgeAlpha












InteractionsAllowed






LineWidth








Selected









SelectedColor









StripeColor








ContextMenu

    end

    properties(Dependent,Hidden)








UIContextMenu









EdgeColor







Layer

    end

    properties(Transient,Hidden,NonCopyable=true,Access=protected)


        Edge matlab.graphics.primitive.world.LineStrip
        StripeEdge matlab.graphics.primitive.world.LineStrip
        Point matlab.graphics.primitive.world.Marker
        LabelHandle matlab.graphics.primitive.world.Text
        Fill matlab.graphics.primitive.world.TriangleStrip
        Canvas matlab.graphics.primitive.world.Quadrilateral


        UserIsDrawing(1,1)logical=false;
        UserIsDragging(1,1)logical=false;


        ROIIsUnderConstruction(1,1)logical=false;


        HasNewParent(1,1)logical=false;


FigureHandle


EdgeListener
LabelListener
FillListener
PointListener
ButtonDownEvt
ButtonStartEvt
ButtonMotionEvt
ButtonUpEvt
KeyPressEvt
KeyReleaseEvt
DragMotionEvt
DragButtonUpEvt
ScrollWheelEvt
EscapeKeyEvt
FigureModeListener
ContextMenuListener


        StartPoint matlab.graphics.primitive.world.Marker
        NumPoints(1,1)double=0;
CurrentPointIdx
CachedPosition
CurrentPoint




        DataUnitsPerScreenPixel(1,2)double=[0.001,0.001];

        BlockWhileDrawing(1,1)logical=true;

    end

    properties(Hidden,Access=protected)


        AlphaInternal(1,1)double{mustBeReal}=1;
        ColorInternal matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor=[0,0.447,0.741];
        DeletableInternal(1,1)logical=true;
        DraggableInternal(1,1)logical=true;
        EdgeColorInternal matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor='none';
        LineWidthInternal(1,1)double{mustBeReal}=images.roi.internal.getLineSize();
        PositionInternal double=[];
        ReshapableInternal(1,1)logical=true;
        SelectedInternal(1,1)logical=false;
        SelectedColorInternal matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor='none';
        StripeColorInternal matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor='none';
        UIContextMenuInternal=[];
        UIPointContextMenuInternal=[];
        MarkerSizeInternal(1,1)double=images.roi.internal.getCircleSize();
        MarkersVisibleInternal(1,1)logical=true;
        MarkersVisibleOnHoverInternal(1,1)logical=false;
        LayerInternal(1,1)string{mustBeMember(LayerInternal,{'middle','front'})}='middle';

    end

    properties(Transient,NonCopyable=true,Hidden,SetAccess=private)
        CData=[];
    end

    properties(Transient,NonCopyable=true,Hidden,SetAccess=protected)
        MouseHit(1,1)logical=false;
    end

    methods(Abstract,Access=protected)

        addDragPoints(self)
        getContextMenu(self)
        reshapeROI(self,currentPoint)
        wireUpListeners(self,varargin)

    end

    methods(Abstract,Hidden)

        [x,y,z]=getLineData(self)
        [x,y,z]=getPointData(self)
        [x,y,z,xAlign,yAlign]=getLabelData(self)

    end

    methods




        function self=ROI()

            self.Fill=matlab.graphics.primitive.world.TriangleStrip(...
            'HitTest','on','Layer','middle','HandleVisibility','off',...
            'Visible','off','PickableParts','visible','Internal',true);
            self.addNode(self.Fill);

            self.Edge=matlab.graphics.primitive.world.LineStrip(...
            'HitTest','on','ColorType','truecoloralpha',...
            'ColorBinding','object','Layer','middle','HandleVisibility','off',...
            'Internal',true);
            self.addNode(self.Edge);

            self.StripeEdge=matlab.graphics.primitive.world.LineStrip(...
            'HitTest','off','PickableParts','none',...
            'ColorType','truecoloralpha','ColorBinding','object',...
            'Layer','middle','LineStyle','dashed','HandleVisibility','off',...
            'Internal',true);
            self.addNode(self.StripeEdge);

            self.LabelHandle=matlab.graphics.primitive.world.Text(...
            'Layer','middle','HitTest','on','HandleVisibility','off',...
            'Margin',1,'LineStyle','none',...
            'Font',matlab.graphics.general.Font('Name','Helvetica'),...
            'Internal',true);
            self.addNode(self.LabelHandle);

            self.Canvas=matlab.graphics.primitive.world.Quadrilateral(...
            'HitTest','off','Layer','front','HandleVisibility','off',...
            'Visible','off','PickableParts','none',...
            'ColorBinding','object',...
            'ColorType','truecoloralpha',...
            'ColorData',uint8([0;0;0;0]),'Internal',true);
            self.addNode(self.Canvas);

            self.Type=class(self);

        end




        function bringToFront(self)











            hParent=self.Parent;
            self.Parent=[];
            self.Parent=hParent;

        end




        function delete(self)
            try
                deleteInternalEvents(self);
                hROI=self;
                if isValid(self,hROI.FigureHandle)
                    hROI.FigureHandle.IPTROIPointerManager.removeROI(hROI);
                end
            catch

            end
        end




        function draw(self)





            prepareToDraw(self);
            setEmptyCallbackHandle(self);
            notify(self,'DrawingStarted');

            self.ButtonStartEvt=event.listener(self.FigureHandle,...
            'WindowMousePress',@(src,evt)waitForButtonPressToBegin(self,evt));

            wireUpEscapeKeyListener(self);
            if self.BlockWhileDrawing
                cleanupObject=onCleanup(@()self.cleanUpForCtrlC());
                uiwait(self.FigureHandle);
            end
        end




        function beginDrawingFromPoint(self,pos)





















            validateattributes(pos,{'numeric'},...
            {'nonempty','real','size',[1,2],'finite','nonsparse'},...
            mfilename,'Location');

            prepareToDraw(self);
            setEmptyCallbackHandle(self);
            wireUpListeners(self,pos);
            notify(self,'DrawingStarted');
            wireUpEscapeKeyListener(self);
            if self.BlockWhileDrawing
                cleanupObject=onCleanup(@()self.cleanUpForCtrlC());
                uiwait(self.FigureHandle);
            end
        end




        function wait(self)
















            if isValid(self,self.Parent)&&isROIConstructed(self)



                setEmptyCallbackHandle(self);

                clickEvent=event.listener(self,'ROIClicked',...
                @(src,evt)clickDuringWait(self,evt));

                keyPressEvent=event.listener(self.FigureHandle,'WindowKeyRelease',...
                @(src,evt)keyPressDuringWait(self,evt));

                deleteEvent=event.listener(self,'DeletingROI',...
                @(~,~)uiresume(self.FigureHandle));










                uiwait(self.FigureHandle);

                try

                    clearEmptyCallbackHandle(self);
                    delete(clickEvent);
                    delete(keyPressEvent);
                    delete(deleteEvent);
                catch





                end
            end

        end

    end

    methods(Hidden)


        function doUpdate(self,us)




            if self.HasNewParent
                self.HasNewParent=false;
                self.FigureHandle=ancestor(self.Parent,'figure');
                images.roi.internal.IPTROIPointerManager(self.FigureHandle,self);
            end


            DC=self.Canvas;
            if strcmp(DC.HitTest,'on')


                if self.UserIsDrawing

                    if strcmp(DC.Clipping,'on')
                        xLim=us.DataSpace.XLim;
                        yLim=us.DataSpace.YLim;
                        zLim=us.DataSpace.ZLim;
                    else



                        xLim=[-Inf,Inf];
                        yLim=[-Inf,Inf];
                        zLim=[-Inf,Inf];
                    end
                    x=[xLim(1);xLim(1);xLim(1);xLim(1);xLim(2);xLim(2);xLim(2);xLim(2)];
                    y=[yLim(1);yLim(2);yLim(1);yLim(2);yLim(1);yLim(2);yLim(1);yLim(2)];
                    z=[zLim(1);zLim(1);zLim(2);zLim(2);zLim(1);zLim(1);zLim(2);zLim(2)];
                    vd=images.roi.internal.transformPoints(us,x,y,z);
                    DC.VertexData=vd;
                    DC.StripData=[];
                    DC.VertexIndices=uint32([5,6,8,7,6,2,4,8,2,1,3,4,1,5,7,3,7,8,4,3,5,6,2,1]);
                    set(self.Canvas,'Visible','on');
                else

                    DC.VertexData=[];
                    DC.StripData=[];
                    set(self.Canvas,'HitTest','off','PickableParts','none');
                end
            end


            doUpdateLabel(self,us,self.LabelHandle,getLabelColor(self),getEdgeColor(self));












            if self.ROIIsUnderConstruction
                return;
            end


            doUpdatePoints(self,us,self.Point);


            if us.ViewerPosition(3)>1&&us.ViewerPosition(4)>1
                self.DataUnitsPerScreenPixel=[diff(us.DataSpace.XLim)/us.ViewerPosition(3),diff(us.DataSpace.YLim)/us.ViewerPosition(4)]/10;
            else

                self.DataUnitsPerScreenPixel=[0.001,0.001];
            end


            doUpdateLine(self,us,self.Edge,self.StripeEdge)


            [x,y,~]=getLineData(self);

            if numel(x)==1
                x=[x;x];
                y=[y;y];
            end
            doUpdateFill(self,us,self.Fill,getColor(self),x,y)


            doCustomUpdate(self,us);

        end


        function actualValue=setParentImpl(self,proposedValue)




            if isa(proposedValue,'matlab.graphics.axis.GeographicAxes')

                if strcmp(self.Type,'images.roi.cuboid')
                    error(message('images:imroi:cuboidInGeographicAxes'));
                end

                if strcmp(self.Type,'images.roi.assistedfreehand')
                    error(message('images:imroi:assistedFreehandInGeographicAxes'));
                end

            end

            actualValue=proposedValue;


            if~isempty(self.FigureHandle)&&isprop(self.FigureHandle,'IPTROIPointerManager')
                hROI=self;
                self.FigureHandle.IPTROIPointerManager.removeROI(hROI);
            end


            hFig=ancestor(actualValue,'figure');

            if~isempty(hFig)
                self.FigureHandle=hFig;
            end



            if~isempty(self.UIContextMenuInternal)&&isvalid(self.UIContextMenuInternal)
                self.UIContextMenuInternal.Parent=gobjects(0);
            end

            if~isempty(self.UIPointContextMenuInternal)&&isvalid(self.UIPointContextMenuInternal)
                self.UIPointContextMenuInternal.Parent=gobjects(0);
            end



            self.HasNewParent=true;

            setUpROI(self);

        end


        function update(self)


            self.MarkDirty('all');
        end


        function setMarkerSize(self,val)






            validateattributes(val,{'numeric'},{'nonempty','real','scalar','positive','finite','nonsparse'},...
            mfilename,'MarkerSize');

            val=double(val);
            if self.MarkerSizeInternal~=val
                self.MarkerSizeInternal=val;

                setPointSize(self);

                update(self);
            end

        end


        function val=getMarkerSize(self)
            val=self.MarkerSizeInternal;
        end


        function setMarkersVisible(self,val)

            validStr=validatestring(val,{'on','off','hover'});

            markerVisible=self.MarkersVisibleInternal;
            markerHover=self.MarkersVisibleOnHoverInternal;

            switch validStr
            case 'on'
                self.MarkersVisibleInternal=true;
                self.MarkersVisibleOnHoverInternal=false;
                if~(markerVisible==true&&markerHover==false)
                    update(self);
                end
            case 'off'
                self.MarkersVisibleInternal=false;
                self.MarkersVisibleOnHoverInternal=false;
                if~(markerVisible==false&&markerHover==false)
                    update(self);
                end
            case 'hover'
                self.MarkersVisibleInternal=false;
                self.MarkersVisibleOnHoverInternal=true;
                if~(markerVisible==false&&markerHover==true)
                    update(self);
                end
            end

        end


        function val=getMarkersVisible(self)

            if self.MarkersVisibleInternal
                val='on';
            else
                if self.MarkersVisibleOnHoverInternal
                    val='hover';
                else
                    val='off';
                end
            end

        end


        function color=getTextColor(self)
            color=getEdgeColor(self);
            color=im2double(color(1:3))';
        end


        function setLabelFont(self,obj)

            self.LabelHandle.Font=obj;
        end


        function obj=getLabelFont(self)
            obj=self.LabelHandle.Font;
        end

    end

    methods(Sealed,Access={?matlab.graphics.mixin.internal.Copyable,?matlab.graphics.internal.CopyContext},Hidden)


        function hCopy=copyElement(hSrc)


            hCopy=copyElement@matlab.graphics.primitive.Data(hSrc);


            if~isempty(hSrc.UIContextMenuInternal)&&isvalid(hSrc.UIContextMenuInternal)
                hCopy.UIContextMenuInternal=copy(hSrc.UIContextMenuInternal);
                hCopy.UIContextMenuInternal.Parent=gobjects(0);
            end

            if~isempty(hSrc.UIPointContextMenuInternal)&&isvalid(hSrc.UIPointContextMenuInternal)
                hCopy.UIPointContextMenuInternal=copy(hSrc.UIPointContextMenuInternal);
                hCopy.UIPointContextMenuInternal.Parent=gobjects(0);
            end


            setUpROI(hCopy);

        end

    end

    methods(Hidden,Access=protected)




        function setUpROI(self)












            if isROIDefined(self)...
                &&(isValid(self,self.Parent)||self.HasNewParent)...
                &&~isROIConstructed(self)...
                &&(self.DraggableInternal||self.ReshapableInternal||strcmp(self.Type,'images.roi.point'))

                self.ROIIsUnderConstruction=true;
                updateROISpecificProperties(self);
                addDragPoints(self);
                wireUpLineListeners(self);
                self.ROIIsUnderConstruction=false;
                self.MarkDirty('all');

            end
        end


        function drawDragPoints(self,shape,sz,layer)

            [hPoint,hPointListener]=createPoint(self,shape,sz,layer);
            pointHandles=self.Point;
            self.Point=[pointHandles,hPoint];
            pointListenerHandles=self.PointListener;
            self.PointListener=[pointListenerHandles,hPointListener];

        end


        function[hPoint,hPointListener]=createPoint(self,marker,sz,layer)


            hPoint=matlab.graphics.primitive.world.Marker(...
            'Size',sz*self.MarkerSizeInternal,...
            'Style',marker,'Clipping','on','Layer',layer,...
            'HandleVisibility','off','HitTest','on','PickableParts','visible',...
            'FaceColorBinding','object','FaceColorType','truecoloralpha',...
            'FaceColorData',uint8([0;0;0;0]),'Visible','off',...
            'Internal',true);

            self.addNode(hPoint);
            hPointListener=event.listener(hPoint,'Hit',@(src,evt)startROIReshape(self,src,evt));

        end


        function stopDraw(self)
            endInteractivePlacement(self);
            notifyDrawCompletion(self);
        end


        function endInteractivePlacement(self)

            wireUpLineListeners(self);

            self.UserIsDrawing=false;

            set(self.Canvas,'HitTest','off','PickableParts','none');

            if~isempty(self.StartPoint)
                set(self.StartPoint,'HitTest','off','Visible','off');
            end

            updateROISpecificProperties(self);
            deleteInternalEvents(self);


            try %#ok<TRYNC> 
                self.FigureHandle.IPTROIPointerManager.Enabled=true;
            end

        end


        function notifyDrawCompletion(self)

            evtData=packageROIMovedEventData(self);
            self.MarkDirty('all');
            notify(self,'ROIMoved',evtData);

            if self.BlockWhileDrawing
                uiresume(self.FigureHandle);
            end
            notify(self,'DrawingFinished');

        end


        function wireUpLineListeners(self)

            self.EdgeListener=event.listener(self.Edge,'Hit',@(src,evt)startROIDrag(self,src));
            self.LabelListener=event.listener(self.LabelHandle,'Hit',@(src,evt)startROIDrag(self,src));
            self.FillListener=event.listener(self.Fill,'Hit',@(src,evt)startROIDrag(self,src));

            if~self.DraggableInternal
                self.EdgeListener.Enabled=false;
                self.LabelListener.Enabled=false;
                self.FillListener.Enabled=false;
            else
                setFillListenerState(self,self.FillListener);
            end

        end


        function wireUpEscapeKeyListener(self)


            self.EscapeKeyEvt=event.listener(self.FigureHandle,...
            'WindowKeyRelease',@(src,evt)escapeKeyPress(self,evt));

        end


        function wireUpReshapeListeners(self,evt)


            [x,y,z]=getLineData(self);
            setConstraintLimits(self,x,y,z);

            cacheDataForROIMovedEvent(self);


            self.FigureHandle.IPTROIPointerManager.Enabled=false;


            currentPoint=getCurrentAxesPoint(self);

            prepareToReshape(self,evt);
            setEmptyCallbackHandle(self);

            self.DragMotionEvt=event.listener(self.FigureHandle,...
            'WindowMouseMotion',@(~,~)reshapeROI(self,currentPoint));

            self.DragButtonUpEvt=event.listener(self.FigureHandle,...
            'WindowMouseRelease',@(~,~)stopDrag(self,currentPoint));


            self.KeyPressEvt=event.listener(self.FigureHandle,...
            'WindowKeyPress',@(src,evt)keyPressDuringInteraction(self,evt));


            self.KeyReleaseEvt=event.listener(self.FigureHandle,...
            'WindowKeyRelease',@(src,evt)keyPressDuringInteraction(self,evt));

        end


        function prepareToDraw(self)

            validateParentBeforeDrawing(self);
            cacheDataForROIMovedEvent(self);


            self.NumPoints=0;
            clearPosition(self);
            clearPoints(self);


            set(self.Edge,'Layer','middle');
            set(self.StripeEdge,'Layer','middle');
            set(self.LabelHandle,'Layer','middle');

            set(self.Canvas,'Layer','front','HitTest','on',...
            'PickableParts','all','Clipping',get(self.Parent,'Clipping'));

            self.UserIsDrawing=true;

            prop=isprop(self.FigureHandle,'ModeManager');

            if~isempty(prop)&&prop&&...
                ~isempty(self.FigureHandle.ModeManager)&&...
                ~isempty(self.FigureHandle.ModeManager.CurrentMode)
                self.FigureHandle.ModeManager.CurrentMode=[];
            end


            prepareROISpecificDrawingSetup(self);

            self.MarkDirty('all');

        end


        function constrainedPos=resetConstraintsAndFigureMode(self,varargin)






            delete(self.ButtonStartEvt);


            [x,y,z]=getLineData(self);
            setConstraintLimits(self,x,y,z);



            if nargin>1
                constrainedPos=varargin{1};
            else
                constrainedPos=getConstrainedPosition(self,getCurrentAxesPoint(self));
            end

        end

        function waitForButtonPressToBegin(self,evt)




            if isModeManagerActive(self)||wasClickOnAxesToolbar(self,evt)
                return;
            end

            wireUpListeners(self);

        end


        function deleteROI(self)

            if~self.DeletableInternal
                return;
            end

            notify(self,'DeletingROI');
            delete(self);

        end


        function startROIDrag(self,src)

            if isModeManagerActive(self)
                return;
            end

            click=images.roi.internal.getClickType(self.FigureHandle);
            hitObject=getHitObject(self,src);

            if strcmp(click,'left')

                [x,y,z]=getLineData(self);
                setConstraintLimits(self,x,y,z);

                cacheDataForROIMovedEvent(self);


                self.FigureHandle.IPTROIPointerManager.Enabled=false;

                self.UserIsDragging=true;


                currentPoint=getCurrentAxesPoint(self);
                setDragBoundary(self,currentPoint,x,y,z);
                setEmptyCallbackHandle(self);

                self.DragMotionEvt=event.listener(self.FigureHandle,...
                'WindowMouseMotion',@(~,~)dragROI(self,currentPoint));

                self.DragButtonUpEvt=event.listener(self.FigureHandle,...
                'WindowMouseRelease',@(~,~)stopDrag(self,currentPoint));

            elseif strcmp(click,'double')&&strcmp(hitObject,'edge')
                doROIDoubleClick(self);
            end

            determineSelectionStatus(self,src,click,hitObject);

        end


        function startROIReshape(self,hPoint,evt)

            if isModeManagerActive(self)
                return;
            end


            setCurrentPointIdx(self,hPoint);
            click=images.roi.internal.getClickType(self.FigureHandle);
            hitObject=getHitObject(self,hPoint);

            if strcmp(click,'left')

                self.UserIsDragging=true;
                wireUpReshapeListeners(self,evt);

            elseif strcmp(click,'shift')


                self.UserIsDragging=true;
                doROIShiftClick(self,evt);

            end

            determineSelectionStatus(self,hPoint,click,hitObject);

        end


        function hitObject=getHitObject(self,src)

            if self.Edge==src
                hitObject='edge';
            elseif self.LabelHandle==src
                hitObject='label';
            elseif self.Fill==src
                hitObject='face';
            else
                hitObject='marker';
            end

        end


        function dragROI(self,startPoint)

            currentPoint=getCurrentAxesPoint(self);



            if~isequal(getConstrainedPosition(self,currentPoint),startPoint)

                previousPosition=self.PositionInternal;

                constrainedPos=getConstrainedDragPosition(self,currentPoint);
                newPositions=self.CachedPosition+constrainedPos-startPoint;

                pos=setROIPosition(self,newPositions);
                self.PositionInternal=pos(:,1:2);

                evtData=packageROIMovingEventData(self,previousPosition);

                self.MarkDirty('all');
                notify(self,'MovingROI',evtData);

            end

        end


        function stopDrag(self,startPoint)


            updateROISpecificProperties(self);

            self.UserIsDragging=false;
            deleteInternalEvents(self);


            self.FigureHandle.IPTROIPointerManager.Enabled=true;

            if~isequal(getCurrentAxesPoint(self),startPoint)
                evtData=packageROIMovedEventData(self);
                self.MarkDirty('all');
                notify(self,'ROIMoved',evtData);
            end

        end


        function determineSelectionStatus(self,src,click,hitObject)



            oldSelected=self.SelectedInternal;

            switch click

            case{'left','right','shift'}
                if~self.SelectedInternal
                    self.SelectedInternal=true;
                end
                if strcmp(click,'right')&&~self.UserIsDrawing
                    if ispc
                        self.ContextMenuListener=event.listener(self.FigureHandle,'WindowMouseRelease',@(~,~)showContextMenu(self,src));
                    else
                        showContextMenu(self,src);
                    end
                end

            case 'ctrl'
                toggleSelected(self);

            case 'double'





            end


            evtData=images.roi.ROIClickedEventData(click,hitObject,oldSelected,self.SelectedInternal);

            self.MarkDirty('all');
            notify(self,'ROIClicked',evtData);

        end


        function toggleSelected(self)
            self.SelectedInternal=~self.SelectedInternal;
        end


        function deleteInternalEvents(self)
            delete(self.ButtonStartEvt);
            delete(self.ButtonDownEvt);
            delete(self.ButtonMotionEvt);
            delete(self.ButtonUpEvt);
            delete(self.KeyPressEvt);
            delete(self.KeyReleaseEvt);
            delete(self.DragButtonUpEvt);
            delete(self.DragMotionEvt);
            delete(self.ScrollWheelEvt);
            delete(self.FigureModeListener);
            delete(self.ContextMenuListener);
            delete(self.EscapeKeyEvt);
            clearEmptyCallbackHandle(self);
        end


        function clearPoints(self)
            delete(self.Point);
            self.Point=matlab.graphics.primitive.world.Marker.empty;
            delete(self.PointListener);
            self.PointListener=[];
        end


        function escapeKeyPress(self,evt)



            if isModeManagerActive(self)
                return;
            end

            if strcmp(evt.Key,'escape')
                clearPosition(self);
                clearPoints(self);
                endInteractivePlacement(self);
                notifyDrawCompletion(self);
            end

        end


        function clickDuringWait(self,evt)



            if strcmp(evt.SelectionType,'double')
                uiresume(self.FigureHandle);
            end

        end


        function keyPressDuringWait(self,evt)




            if strcmp(evt.Key,'escape')
                clearPosition(self);
                clearPoints(self);
                self.MarkDirty('all');
                uiresume(self.FigureHandle);
            elseif strcmp(evt.Key,'return')
                uiresume(self.FigureHandle);
            end

        end


        function TF=wasClickOnAxesToolbar(~,evt)



            TF=~isempty(ancestor(evt.HitObject,'matlab.graphics.controls.AxesToolbar'));
        end

    end

    methods(Hidden,Access=protected)



        function color=getColor(self)
            if self.SelectedInternal&&~strcmp(self.SelectedColorInternal,'none')
                color=uint8(([self.SelectedColorInternal,self.AlphaInternal]*255).');
            else
                color=uint8(([self.ColorInternal,self.AlphaInternal]*255).');
            end
        end


        function color=getEdgeColor(self)


            if sum(getColorInternal(self))<1
                color=uint8(([1,1,1,self.AlphaInternal]*255).');
            else
                color=uint8(([0,0,0,self.AlphaInternal]*255).');
            end
        end


        function color=getFaceColor(self)

            color=getColorInternal(self);
            colorDiff=0.5*(1-color);
            color=color+colorDiff;
            color(color>1)=1;
            color=uint8(([color,self.AlphaInternal]*255).');
        end


        function color=getStripeColor(self)
            color=uint8(([self.StripeColorInternal,self.AlphaInternal]*255).');
        end


        function color=getColorInternal(self)




            if self.SelectedInternal&&~strcmp(self.SelectedColorInternal,'none')
                color=self.SelectedColorInternal;
            else
                color=self.ColorInternal;
            end
        end


        function color=getLabelColor(self)



            color=getColor(self);
        end


        function setPointColor(self)
            if~isempty(self.Point)
                if self.MouseHit
                    set(self.Point,'EdgeColorData',getColor(self),...
                    'FaceColorData',getFaceColor(self));
                else
                    set(self.Point,'EdgeColorData',getEdgeColor(self),...
                    'FaceColorData',getColor(self));
                end
            end
        end


        function showContextMenu(self,~)

            delete(self.ContextMenuListener);
            self.ContextMenuListener=[];

            if isnumeric(self.UIContextMenuInternal)

                self.UIContextMenuInternal=getContextMenu(self);
            elseif isempty(self.UIContextMenuInternal)


                return;
            end

            cMenu=self.UIContextMenuInternal;
            cMenu.Parent=self.FigureHandle;

            prepareROISpecificContextMenu(self,cMenu);


            drawnow;

            displayContextMenuInFigure(self,cMenu);

        end


        function displayContextMenuInFigure(self,cMenu)
            if~isempty(cMenu)



                figPoint=self.FigureHandle.CurrentPoint;
                figPoint=hgconvertunits(self.FigureHandle,[figPoint,0,0],...
                self.FigureHandle.Units,'pixels',self.FigureHandle);
                figPoint=figPoint(1:2);
                cMenu.Position=figPoint;
                set(cMenu,'Visible','on');
            end
        end


        function enableContextMenuDelete(self,cMenu)


            hobj=findall(cMenu,'Type','uimenu','Tag','IPTROIContextMenuDelete');
            if~isempty(hobj)
                if self.DeletableInternal
                    hobj.Enable='on';
                else
                    hobj.Enable='off';
                end
            end
        end

    end

    methods(Hidden,Access=protected)



        function prepareROISpecificDrawingSetup(~)

        end

        function prepareToReshape(~,~)


        end

        function updateROISpecificProperties(~)


        end

        function prepareROISpecificContextMenu(self,cMenu)




            enableContextMenuDelete(self,cMenu);
        end

        function setPointVisibility(self)



            if(~self.ReshapableInternal&&~self.DraggableInternal)||self.UserIsDragging
                set(self.Point,'Visible','off');
            else
                if self.MarkersVisibleOnHoverInternal
                    set(self.Point,'Visible',self.Visible&&self.MouseHit);
                else
                    set(self.Point,'Visible',self.Visible&&self.MarkersVisibleInternal);
                end
            end

        end

        function setPointSize(self)

            if isROIConstructed(self)
                set(self.Point,'Size',self.MarkerSizeInternal);
            end
        end

        function setLayer(self)


            set(self.Edge,'Layer',self.LayerInternal);
            set(self.StripeEdge,'Layer',self.LayerInternal);
            set(self.LabelHandle,'Layer',self.LayerInternal);
            set(self.Fill,'Layer',self.LayerInternal);

            if~isempty(self.Point)
                set(self.Point,'Layer',self.LayerInternal);
            end

        end

        function clearPosition(self)



            self.PositionInternal=[];
        end

        function TF=isROIDefined(self)





            TF=~isempty(self.PositionInternal);
        end

        function TF=isROIConstructed(self)





            TF=~isempty(self.Point)&&~isempty(self.PointListener);
        end

        function doROIDoubleClick(~)

        end

        function doROIShiftClick(~,~)

        end

        function keyPressDuringInteraction(~,~)



        end

        function keyPressDuringDraw(~,~)



        end

        function varargout=setROIPosition(~,varargin)


            varargout=varargin;
        end

        function setCurrentPointIdx(self,hObject)





            self.CurrentPointIdx=find(self.Point==hObject);
        end

        function setStartPointVisibility(self)



            set(self.StartPoint,'Visible','off');
        end

        function setFillListenerState(~,fillListener)


            fillListener.Enabled=false;
        end

        function doUpdateLabel(~,~,lab,~,~)


            set(lab,'Visible','off');
        end

        function doUpdateFill(~,~,fill,~,~,~)


            set(fill,'Visible','off');
        end

        function doCustomUpdate(~,~)





        end

        function evtData=packageROIMovingEventData(self,varargin)




            evtData=images.roi.ROIMovingEventData(varargin{1},self.PositionInternal);
        end

        function evtData=packageROIMovedEventData(self)




            evtData=images.roi.ROIMovingEventData(self.CachedPosition,self.PositionInternal);
        end

        function cacheDataForROIMovedEvent(self)










            self.CachedPosition=self.PositionInternal;
        end

        function validateInteractionsAllowed(self,val)




            validStr=validatestring(val,{'all','none','translate','reshape'});

            switch validStr
            case 'all'
                self.DraggableInternal=true;
                self.ReshapableInternal=true;
            case 'none'
                self.DraggableInternal=false;
                self.ReshapableInternal=false;
            case 'translate'
                self.DraggableInternal=true;
                self.ReshapableInternal=false;
            case 'reshape'
                self.DraggableInternal=false;
                self.ReshapableInternal=true;
            otherwise
                error(message('images:imroi:invalidInteractionInput'));
            end

        end

        function validateParentBeforeDrawing(self)















            if~isValid(self,self.Parent)||isempty(ancestor(self.Parent,'figure'))
                self.Parent=gca;
            end

        end

        function doUpdateLine(self,us,L,SL)

            [x,y,z]=getLineData(self);

            if numel(x)==1
                x=[x;x];
                y=[y;y];
                z=[z;z];
            end

            [vd,stripData]=images.roi.internal.transformPoints(us,x,y,z);


            L.VertexData=vd;
            L.StripData=stripData;

            SL.VertexData=vd;
            SL.StripData=stripData;

            if strcmp(self.EdgeColorInternal,'none')
                color=getColor(self);
            else
                color=uint8(([self.EdgeColorInternal,self.AlphaInternal]*255).');
            end

            set(L,'ColorData',color,...
            'LineWidth',self.LineWidthInternal,...
            'Visible',self.Visible);

            setPrimitiveClickability(self,L,'visible','on');


            if strcmp(self.StripeColorInternal,'none')
                set(SL,'Visible','off');
            else
                set(SL,'ColorData',getStripeColor(self),...
                'LineWidth',self.LineWidthInternal,...
                'Visible',self.Visible);
            end

        end

        function doUpdatePoints(self,us,P)

            if(self.DraggableInternal||self.ReshapableInternal)&&~self.UserIsDragging

                [x,y,z]=getPointData(self);
                vd=images.roi.internal.transformPoints(us,x,y,z);

                for idx=1:numel(P)
                    P(idx).VertexData=vd(:,idx);
                end




                if~self.UserIsDrawing&&self.ReshapableInternal&&strcmp(self.Visible,'on')
                    setPrimitiveClickability(self,self.Point,'visible','on');
                else
                    setPrimitiveClickability(self,self.Point,'none','off');
                end


                setPointColor(self);

            else
                vd=[];
            end


            setPointVisibility(self);


            SP=self.StartPoint;
            if~isempty(SP)



                if self.UserIsDrawing&&~isempty(vd)
                    SP.VertexData=vd(:,1);

                    set(self.StartPoint,'EdgeColorData',getEdgeColor(self),...
                    'FaceColorData',getColor(self),...
                    'Layer','front');
                else
                    SP.VertexData=[];
                end

                setStartPointVisibility(self);
            end

        end

    end

    methods(Hidden)




        function dragPointerEnterFcn(self,symbol)

            try
                self.MouseHit=true;
                if self.ReshapableInternal
                    images.roi.internal.setROIPointer(self.FigureHandle,symbol);
                else
                    if self.DraggableInternal
                        images.roi.internal.setROIPointer(self.FigureHandle,'drag');
                    end
                end
            catch

            end
            self.MarkDirty('all');
        end


        function linePointerEnterFcn(self)


            try
                self.MouseHit=true;
                if self.DraggableInternal
                    images.roi.internal.setROIPointer(self.FigureHandle,'drag');
                else
                    if self.ReshapableInternal
                        images.roi.internal.setROIPointer(self.FigureHandle,'restricted');
                    end
                end
            catch

            end
            self.MarkDirty('all');
        end


        function linePointerExitFcn(self)


            if ishandle(self)
                try
                    self.MouseHit=false;
                catch

                end
                self.MarkDirty('all');
            end
        end


        function setPointerEnterFcn(self,~)
            dragPointerEnterFcn(self,'circle');
        end


        function setEdgeEnterFcn(self,~)
            linePointerEnterFcn(self);
        end


        function setFaceEnterFcn(self,~)
            linePointerEnterFcn(self);
        end


        function setLabelEnterFcn(self,~)
            linePointerEnterFcn(self);
        end


        function setPrimitiveClickability(self,hObject,pickableParts,hitTest)




            if~self.DraggableInternal&&~self.ReshapableInternal

                pickableParts='none';
                hitTest='off';
            end

            set(hObject,'PickableParts',pickableParts,'HitTest',hitTest);

        end

    end

    methods(Hidden,Access=protected)

        function TF=isModeManagerActive(self)
            TF=imageslib.internal.app.utilities.isAxesInteractionModeActive(...
            ancestor(self,["axes","geoaxes"]),self.FigureHandle);
        end

        function TF=isValid(~,hg)

            TF=~isempty(hg)&&ishandle(hg)&&isvalid(hg);
        end


        function setEmptyCallbackHandle(self)




            if isempty(self.FigureHandle.WindowButtonMotionFcn)
                self.FigureHandle.WindowButtonMotionFcn=@images.roi.internal.emptyCallback;
            end

            if isempty(self.FigureHandle.KeyPressFcn)
                self.FigureHandle.KeyPressFcn=@images.roi.internal.emptyCallback;
            end

        end


        function clearEmptyCallbackHandle(self)



            if isValid(self,self.FigureHandle)...
                &&isequal(self.FigureHandle.WindowButtonMotionFcn,@images.roi.internal.emptyCallback)
                self.FigureHandle.WindowButtonMotionFcn=[];
            end

            if isValid(self,self.FigureHandle)...
                &&isequal(self.FigureHandle.KeyPressFcn,@images.roi.internal.emptyCallback)
                self.FigureHandle.KeyPressFcn=[];
            end

        end


        function cleanUpForCtrlC(self)





            if isvalid(self)&&self.UserIsDrawing
                clearPosition(self);
                clearPoints(self);
                endInteractivePlacement(self);
                notifyDrawCompletion(self);
            end

        end


        function g=addParentPropertyGroup(self,g)






            if~isempty(self.Parent)
                g=[g,{'Color','Parent','Visible','Selected'}];
            end

        end


        function parseInputs(self,varargin)


            varargin=matlab.images.internal.stringToChar(varargin);


            if~isempty(varargin)
                if~(ischar(varargin{1})||isstring(varargin{1}))


                    self.Parent=varargin{1};
                    varargin(1)=[];
                else


                    varargin=extractInputNameValue(self,varargin,'Parent');
                end



                if~isempty(varargin)
                    varargin=extractInputNameValue(self,varargin,'InteractionsAllowed');
                end



                if~isempty(varargin)
                    varargin=extractInputNameValue(self,varargin,'Position');
                end


                if~isempty(varargin)
                    set(self,varargin{:});
                end
            end

        end


        function inputs=extractInputNameValue(self,inputs,propname)

            index=[];

            for p=1:2:length(inputs)


                name=inputs{p};
                TF=strncmpi(name,propname,numel(name));

                if TF
                    index=p;
                end

            end


            for i=1:length(index)
                set(self,propname,inputs{index(i)+1});
            end

            inputs([index,index+1])=[];

        end

    end

    methods





        function set.Color(self,color)

            color=convertColorSpec(images.internal.ColorSpecToRGBConverter,color);
            if~isequal(self.ColorInternal,color)
                self.ColorInternal=color;
                self.MarkDirty('all');
            end

        end

        function color=get.Color(self)
            color=self.ColorInternal;
        end




        function set.ContextMenu(self,uimenu)




















            if isempty(uimenu)
                self.UIContextMenuInternal=matlab.ui.container.ContextMenu.empty;
            else
                validateattributes(uimenu,{'matlab.ui.container.ContextMenu'},{'scalar'},...
                mfilename,'ContextMenu');
                self.UIContextMenuInternal=uimenu;
            end
        end

        function uimenu=get.ContextMenu(self)



            if isnumeric(self.UIContextMenuInternal)
                self.UIContextMenuInternal=getContextMenu(self);
            end
            uimenu=self.UIContextMenuInternal;
        end




        function set.Deletable(self,TF)
            validateattributes(TF,{'logical','numeric'},...
            {'nonempty','real','scalar','nonsparse'},...
            mfilename,'Deletable');
            self.DeletableInternal=logical(TF);
        end

        function TF=get.Deletable(self)
            TF=self.DeletableInternal;
        end




        function set.EdgeAlpha(self,val)

            validateattributes(val,{'numeric'},...
            {'nonempty','real','scalar','nonsparse','>=',0,'<=',1},...
            mfilename,'EdgeAlpha');

            val=double(val);
            if self.AlphaInternal~=val
                self.AlphaInternal=val;
                self.MarkDirty('all');
            end

        end

        function val=get.EdgeAlpha(self)
            val=self.AlphaInternal;
        end




        function set.EdgeColor(self,color)

            if(ischar(color)||isstring(color))&&strcmp(color,'match')
                if~ischar(self.EdgeColorInternal)
                    self.EdgeColorInternal='none';
                    self.MarkDirty('all');
                end
            else
                color=convertColorSpec(images.internal.ColorSpecToRGBConverter,color);
                if~isequal(self.EdgeColorInternal,color)
                    self.EdgeColorInternal=color;
                    self.MarkDirty('all');
                end
            end

        end

        function color=get.EdgeColor(self)

            if strcmp(self.EdgeColorInternal,'none')
                color=self.ColorInternal;
            else
                color=self.EdgeColorInternal;
            end

        end




        function set.InteractionsAllowed(self,val)
            validateattributes(val,{'char','string'},{'scalartext'},...
            mfilename,'InteractionsAllowed');

            validateInteractionsAllowed(self,val);

            if isROIConstructed(self)
                if self.DraggableInternal
                    self.EdgeListener.Enabled=true;
                    self.LabelListener.Enabled=true;
                    setFillListenerState(self,self.FillListener);
                else
                    self.EdgeListener.Enabled=false;
                    self.LabelListener.Enabled=false;
                    self.FillListener.Enabled=false;
                end
            else



                setUpROI(self);
            end

            self.MarkDirty('all');
        end

        function val=get.InteractionsAllowed(self)

            if self.DraggableInternal
                if self.ReshapableInternal
                    val='all';
                else
                    val='translate';
                end
            else
                if self.ReshapableInternal
                    val='reshape';
                else
                    val='none';
                end
            end

        end




        function set.SelectedColor(self,color)

            if(ischar(color)||isstring(color))&&strcmp(color,'none')
                if~ischar(self.SelectedColorInternal)
                    self.SelectedColorInternal='none';
                    self.MarkDirty('all');
                end
            else
                color=convertColorSpec(images.internal.ColorSpecToRGBConverter,color);
                if~isequal(self.SelectedColorInternal,color)
                    self.SelectedColorInternal=color;
                    self.MarkDirty('all');
                end
            end

        end

        function color=get.SelectedColor(self)
            color=self.SelectedColorInternal;
        end




        function set.LineWidth(self,val)
            validateattributes(val,{'numeric'},{'nonempty','real','scalar','positive','finite','nonsparse'},...
            mfilename,'LineWidth');

            val=double(val);
            if self.LineWidthInternal~=val
                self.LineWidthInternal=val;
                self.MarkDirty('all');
            end
        end

        function val=get.LineWidth(self)
            val=self.LineWidthInternal;
        end




        function set.Selected(self,TF)
            validateattributes(TF,{'logical','numeric'},...
            {'nonempty','real','scalar','nonsparse'},...
            mfilename,'Selected');

            TF=logical(TF);
            if self.SelectedInternal~=TF
                self.SelectedInternal=TF;
                self.MarkDirty('all');
            end
        end

        function TF=get.Selected(self)
            TF=self.SelectedInternal;
        end




        function set.StripeColor(self,color)

            if(ischar(color)||isstring(color))&&strcmp(color,'none')
                if~ischar(self.StripeColorInternal)
                    self.StripeColorInternal='none';
                    self.MarkDirty('all');
                end
            else
                color=convertColorSpec(images.internal.ColorSpecToRGBConverter,color);
                if~isequal(self.StripeColorInternal,color)
                    self.StripeColorInternal=color;
                    self.MarkDirty('all');
                end
            end

        end

        function color=get.StripeColor(self)
            color=self.StripeColorInternal;
        end




        function set.Layer(self,str)

            previousLayer=self.LayerInternal;
            self.LayerInternal=str;

            if previousLayer==self.LayerInternal

                return;
            end



            setLayer(self);

            if isROIConstructed(self)
                self.MarkDirty('all');
            end

        end

        function str=get.Layer(self)
            str=self.LayerInternal;
        end




        function set.UIContextMenu(self,uimenu)





            self.ContextMenu=uimenu;
        end

        function uimenu=get.UIContextMenu(self)
            uimenu=self.ContextMenu;
        end

    end

    methods(Static,Hidden)


        function varargout=doloadobj(self)

            setUpROI(self);
            varargout{1}=self;

        end

    end

end
