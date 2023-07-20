classdef(ConstructOnLoad=true,Sealed)SelectionHandles<matlab.graphics.primitive.world.Group&matlab.graphics.mixin.OverlayParentable&matlab.graphics.internal.Legacy









    properties(SetObservable=true,SetAccess='protected',GetAccess='public',Dependent=false,Hidden=true)

TrueParent
    end
    methods
        function storedValue=get.TrueParent(hObj)
            storedValue=hObj.TrueParent;
        end

        function set.TrueParent(hObj,newValue)
            reallyDoCopy=~isequal(hObj.TrueParent,newValue);
            if reallyDoCopy
                hObj.TrueParent=newValue;
            end

            hObj.MarkDirty('all');
        end
    end


    properties(SetObservable=true,SetAccess='protected',GetAccess='public',Dependent=false,Hidden=true)

        Markers matlab.graphics.interactor.ListOfPointsHighlight{matlab.internal.validation.mustBeVector(Markers)}=matlab.graphics.interactor.ListOfPointsHighlight.empty;
    end
    methods
        function storedValue=get.Markers(hObj)
            storedValue=hObj.Markers;
        end

        function set.Markers(hObj,newValue)
            reallyDoCopy=~isequal(hObj.Markers,newValue);
            if reallyDoCopy
                hObj.Markers=newValue;
            end

            hObj.MarkDirty('all');
        end
    end


    properties(SetObservable=true,SetAccess='protected',GetAccess='protected',Dependent=false,Hidden=true)

        Lines matlab.graphics.primitive.Line{matlab.internal.validation.mustBeVector(Lines)}=matlab.graphics.primitive.Line.empty;
    end
    methods
        function storedValue=get.Lines(hObj)
            storedValue=hObj.Lines;
        end

        function set.Lines(hObj,newValue)
            reallyDoCopy=~isequal(hObj.Lines,newValue);
            if reallyDoCopy
                hObj.Lines=newValue;
            end

            hObj.MarkDirty('all');
        end
    end


    properties(SetObservable=true,SetAccess='protected',GetAccess='protected',Dependent=false,Hidden=true)

ParentSizeChangedListener
    end





    properties(SetObservable=true,SetAccess='protected',GetAccess='protected',Dependent=false,Hidden=true)

ParentLocationChangedListener
    end


    properties(SetObservable=true,SetAccess='protected',GetAccess='protected',Dependent=false,Hidden=true)

ContainerSizeChangedListener
ContainerLocationChangedListener
ContainerVisibilityChangedListener
ObjectBeingDestroyedListener
ContainerSelectionChangedListener
ParentChangedListener
    end



    properties(SetObservable=true,SetAccess='protected',GetAccess='public',Dependent=true,Hidden=false)

Position
    end
    methods
        function storedValue=get.Position(hObj)
            storedValue=get(hObj.Markers,'VertexData');
        end

        function set.Position(hObj,newValue)
            reallyDoCopy=~isequal(hObj.Position,newValue);
            if reallyDoCopy
                set(hObj.Markers,'VertexData',single(newValue));
                if matlab.graphics.internal.SelectionHandles.isUIContainer(hObj.TrueParent)
                    set(hObj.Lines,'Visible','on');
                    set(hObj.Lines(1),'XData',[newValue(1,1),newValue(1,4)],'YData',[newValue(2,1),newValue(2,4)]);
                    set(hObj.Lines(2),'XData',[newValue(1,4),newValue(1,2)],'YData',[newValue(2,4),newValue(2,2)]);
                    set(hObj.Lines(3),'XData',[newValue(1,2),newValue(1,3)],'YData',[newValue(2,2),newValue(2,3)]);
                    set(hObj.Lines(4),'XData',[newValue(1,3),newValue(1,1)],'YData',[newValue(2,3),newValue(2,1)]);
                else
                    set(hObj.Lines,'Visible','off');
                end
            end
        end
    end




    methods
        function hObj=SelectionHandles(varargin)




            hObj.Serializable='off';
            hObj.Internal=true;

            hMarkers=matlab.graphics.interactor.ListOfPointsHighlight;
            set(hMarkers,'Internal',true);
            hObj.Markers=hMarkers;
            hObj.setDefaultMarkerProperties();





            hMarkers.MarkerHandle.HitTest='on';
            hMarkers.MarkerHandle.PickableParts='all';

            hLines=matlab.graphics.primitive.Line.empty;
            for i=1:4
                hLines(i)=matlab.graphics.primitive.Line;
                hLines(i).HitTest='off';
                hLines(i).PickableParts='none';
                hLines(i).Internal=true;
                hObj.addNode(hLines(i));
            end
            set(hLines,'LineWidth',2,'LineStyle','--','Color',[10/256,76/256,119/256]);
            hObj.Lines=hLines;

            if nargin==1

                hObj.Parent_I=varargin{1};
            elseif~isempty(varargin)
                set(hObj,varargin{:});
            end
        end
    end


    methods(Access='public')

        function varargout=setParentImpl(hObj,hParent)



            hObj.TrueParent=hParent;


            hFig=ancestor(hParent,'figure');
            hObj.ParentSizeChangedListener=matlab.ui.internal.createListener(hFig,'SizeChanged',@(es,ed)hObj.MarkDirty('all'));
            if matlab.graphics.internal.SelectionHandles.isUIControl(hParent)||...
                matlab.graphics.internal.SelectionHandles.isUIContainer(hParent)






                hParent=hParent.Parent;
                if any(strcmp('SizeChanged',events(hObj.TrueParent)))
                    hObj.ContainerSizeChangedListener=matlab.ui.internal.createListener(hObj.TrueParent,'SizeChanged',@(es,ed)hObj.MarkDirty('all'));
                end
                if any(strcmp('LocationChanged',events(hObj.TrueParent)))
                    hObj.ContainerLocationChangedListener=matlab.ui.internal.createListener(hObj.TrueParent,'LocationChanged',@(es,ed)hObj.MarkDirty('all'));
                end
                hObj.ContainerVisibilityChangedListener=event.proplistener(hObj.TrueParent,hObj.TrueParent.findprop('Visible'),'PostSet',@(es,ed)hObj.MarkDirty('all'));

                hObj.ObjectBeingDestroyedListener=matlab.ui.internal.createListener(hObj.TrueParent,'ObjectBeingDestroyed',@(es,ed)delete(hObj));
            elseif isa(hParent,'scribe.scribeobject')||isa(hParent,'matlab.graphics.shape.internal.ScribeObject')
                hObj.ParentLocationChangedListener=matlab.ui.internal.createListener(hParent,'MarkedClean',@(es,ed)hObj.MarkDirty('all'));
            elseif isa(hParent,'matlab.graphics.chartcontainer.ChartContainer')
                lay=findobjinternal(hObj.TrueParent,'-isa','matlab.graphics.layout.TiledChartLayout','-depth',1);
                hObj.ParentLocationChangedListener=matlab.ui.internal.createListener(lay,'MarkedClean',@(es,ed)hObj.MarkDirty('all'));
                hParent=ancestor(hParent,'matlab.ui.internal.mixin.CanvasHostMixin');
            elseif isa(hParent,'matlab.graphics.chart.Chart')
                hObj.ParentLocationChangedListener=matlab.ui.internal.createListener(hObj.TrueParent,'MarkedClean',@(es,ed)hObj.MarkDirty('all'));
                hParent=ancestor(hParent,'matlab.ui.internal.mixin.CanvasHostMixin');
            end


            if isprop(hObj.TrueParent,'Selected')
                hObj.ContainerSelectionChangedListener=event.proplistener(hObj.TrueParent,hObj.TrueParent.findprop('Selected'),'PostSet',@(es,ed)hObj.MarkDirty('all'));
            end

            if~isempty(hObj.TrueParent)
                hObj.ParentChangedListener=event.proplistener(hObj.TrueParent,hObj.TrueParent.findprop('Parent'),'PostSet',@(es,ed)hObj.parentChanged(ed.AffectedObject));
            else
                hObj.ParentChangedListener=[];
            end


            if isa(hParent,'matlab.ui.internal.mixin.CanvasHostMixin')
                hViewer=getCanvas(hParent);
                hM=hViewer.StackManager;
                if isempty(hM)
                    hM=matlab.graphics.shape.internal.ScribeStackManager.getInstance;
                    hViewer.StackManager=hM;
                end
            end

            varargout{1}=setParentImpl@matlab.graphics.mixin.OverlayParentable(hObj,hParent);
            hObj.MarkDirty('all');
        end


        function doUpdate(hObj,updateState)


            isVisible=hObj.Visible;
            if strcmp('off',hObj.TrueParent.Visible)||strcmp('off',get(hObj.TrueParent,'Selected'))
                isVisible='off';
            end

            set(hObj.Markers,'Visible',isVisible);
            if matlab.graphics.internal.SelectionHandles.isUIContainer(hObj.TrueParent)&&...
                strcmp('on',isVisible)
                set(hObj.Lines,'Visible','on');
            else
                set(hObj.Lines,'Visible','off');
            end

            if strcmpi(isVisible,'off')
                return;
            end



            vertexData=getSelectionMarkerPos(hObj,updateState);
            hObj.Position=vertexData;
        end

        function setMarkerProperties(hObj,varargin)

            set(hObj.Markers,varargin{:});

            hObj.MarkDirty('all');
        end

        function setDefaultMarkerProperties(hObj)


            for k=1:length(hObj.Markers)
                hObj.addNode(hObj.Markers(k));
            end
            hObj.setMarkerProperties(...
            'Style','square',...
            'Size',6,...
            'EdgeColor',uint8([0,86,150,150]'),...
            'FaceColor',uint8([192,231,255,185]'));
        end

        function[propValue]=getMarkerProperty(hObj,property)


            propValue=get(hObj.Markers,property);
        end


    end


    methods(Access='protected')




        function[vertexData]=getSelectionMarkerPos(hObj,updateState)





            hFig=ancestor(hObj,'figure');
            if isempty(hFig)||isempty(hObj.TrueParent)
                return
            end
            hParent=hObj.TrueParent;



            figPosition=getpixelposition(hFig);

            parentPosition=figPosition;

            if hParent~=hFig
                parentPosition=matlab.graphics.internal.SelectionHandles.convertUnits(updateState,hParent.Position_I,hParent.Units,'Pixels');
            end


            markerSize=hObj.Markers.Size;
            if hParent==hFig

                lx=markerSize;
                rx=parentPosition(3)-markerSize;
                cx=0.5*parentPosition(3);
                px=[lx,rx,rx,lx,lx,cx,rx,cx];
                uy=markerSize;
                ly=parentPosition(4)-markerSize;
                cy=0.5*parentPosition(4);
                py=[uy,ly,uy,ly,cy,uy,cy,ly];
                pz=[0,0,0,0,0,0,0,0];
            else

                lx=parentPosition(1)-1;
                rx=parentPosition(1)+parentPosition(3)+1;
                cx=parentPosition(1)+0.5*parentPosition(3);
                px=[lx,rx,rx,lx,lx,cx,rx,cx];
                uy=parentPosition(2)-1;
                ly=parentPosition(2)+parentPosition(4)+1;
                cy=parentPosition(2)+0.5*parentPosition(4);
                py=[uy,ly,uy,ly,cy,uy,cy,ly];
                pz=[0,0,0,0,0,0,0,0];
            end


            p=[px;py;pz;ones(1,8)];


            for i=1:8
                p(:,i)=matlab.graphics.internal.SelectionHandles.convertUnits(updateState,p(:,i),'Pixels','Normalized');
            end


            iter=matlab.graphics.axis.dataspace.XYZPointsIterator;
            iter.XData=p(1,:);
            iter.YData=p(2,:);
            iter.ZData=p(3,:);
            vertexData=updateState.DataSpace.TransformPoints(updateState.TransformUnderDataSpace,iter);
        end
    end

    methods(Access=private)

        function parentChanged(hObj,newParent)



            hObj.Parent_I=[];
            hObj.Parent_I=newParent;
        end
    end

    methods(Static)
        function iscontrol=isUIComponent(hCheck)
            iscontrol=false;
            if isempty(hCheck)
                return;
            end

            type=get(hCheck,'type');
            switch type
            case{'uicontrol','uitable','uicontainer','uipanel','uitabgroup','uibuttongroup'}
                iscontrol=true;
            otherwise
                iscontrol=false;
            end
        end

        function iscontrol=isUIControl(hCheck)
            iscontrol=false;
            if isempty(hCheck)
                return;
            end


            type=get(hCheck,'type');
            switch type
            case{'uicontrol','uitable','uitabgroup','uibuttongroup'}
                iscontrol=true;
            otherwise
                iscontrol=false;
            end
        end

        function iscontrol=isUIContainer(hCheck)
            iscontrol=false;
            if isempty(hCheck)
                return;
            end

            type=get(hCheck,'type');
            switch type
            case{'uicontainer','uipanel','uibuttongroup'}
                iscontrol=true;
            otherwise
                iscontrol=false;
            end
        end



        function[convertedUnits]=convertUnits(updateState,origPosition,origUnits,newUnits)
            vp=updateState.Camera.Viewport;
            vp.Units=origUnits;
            vp.Position=origPosition;
            vp.Units=newUnits;
            convertedUnits=vp.Position;
        end
    end

end


