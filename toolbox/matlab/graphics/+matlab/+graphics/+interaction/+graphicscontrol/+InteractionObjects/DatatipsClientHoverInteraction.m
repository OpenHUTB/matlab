

classdef DatatipsClientHoverInteraction<matlab.graphics.interaction.graphicscontrol.InteractionObjects.InteractionBase




    properties
ResponseData
    end

    properties(Access=private)
LocatorHandle
CachedVisibilityForPrint
MarkerHandle
UpdateInteractionsListener
    end

    properties(Access={?tDataTipInteraction},SetObservable)
SnapToDataVertex
    end

    properties(Constant)
        MARKER_DESCRIPTION='DataTipHoverMarker';
    end

    methods
        function this=DatatipsClientHoverInteraction(ax)
            this.Type='hover';
            this.ResponseData=[];
            this.Object=ax;
            this.Actions=matlab.graphics.interaction.graphicscontrol.Enumerations.Actions.Hover;
            hFig=ancestor(ax,'figure','node');
            if~isempty(hFig)
                dm=datacursormode(hFig,'-nocontextmenu');
                this.SnapToDataVertex=dm.SnapToDataVertex;


                this.UpdateInteractionsListener=event.proplistener(dm,findprop(dm,'SnapToDataVertex'),'PostSet',@(e,d)this.refreshInteractions(e,d));
                this.initMarker(dm.SnapToDataVertex);
            end

        end

        function response(obj,eventdata)
        end
    end

    methods(Access=public)

        function delete(this)
            delete(this.LocatorHandle);
            delete(this.MarkerHandle);
            delete(this.UpdateInteractionsListener);
        end
    end

    methods(Access=private)

        function refreshInteractions(this,~,d)

            if~isequal(d.AffectedObject.SnapToDataVertex,this.SnapToDataVertex)
                this.SnapToDataVertex=d.AffectedObject.SnapToDataVertex;

                ax=this.Object;
                ax.InteractionContainer.clearList;
                ax.InteractionContainer.updateInteractions;
            end
        end

        function initMarker(this,snapToVertex)
            if isempty(this.MarkerHandle)||~isvalid(this.MarkerHandle)

                canvasContainingAncestor=localGetCanvasContainingAncestor(this.Object);
                ap=matlab.graphics.annotation.internal.getDefaultCamera(canvasContainingAncestor,'overlay','-peek');

                this.LocatorHandle=matlab.graphics.shape.internal.PointTipLocator('HandleVisibility','off',...
                'FaceColor',matlab.graphics.shape.internal.PointTipLocator.TRANSIENT_MARKERCOLOR);

                sb=this.LocatorHandle.ScribeHost;
                sp=sb.getScribePeer();

                sp.DisplayHandle=this.LocatorHandle.ScribeHost.DisplayHandle;
                ap.addNode(sp);




                this.Object.addNode(this.LocatorHandle);

                this.MarkerHandle=sp.DisplayHandle;
                this.MarkerHandle.Description=this.MARKER_DESCRIPTION;

                this.LocatorHandle.setPickability('none')
                this.LocatorHandle.setTransparency(uint8(0));

                this.LocatorHandle.Internal=true;






                xPoint=this.Object.DataSpace.XLim(this.Object.DataSpace.XLim>0);
                if isempty(xPoint)
                    xPoint=this.Object.DataSpace.XLim(1);
                end

                yPoint=this.Object.DataSpace.YLim(this.Object.DataSpace.YLim>0);
                if isempty(yPoint)
                    yPoint=this.Object.DataSpace.YLim(1);
                end

                zPoint=this.Object.DataSpace.ZLim(this.Object.DataSpace.ZLim>0);
                if isempty(zPoint)
                    zPoint=this.Object.DataSpace.ZLim(1);
                end

                this.LocatorHandle.Position=[xPoint(1),yPoint(1),zPoint(1)];



                this.setupPrintBehavior(this.MarkerHandle);

                controlFactory=matlab.graphics.interaction.graphicscontrol.ControlFactory(canvasContainingAncestor.getCanvas());
                controlFactory.createControl(this.MarkerHandle);
            end

            this.ResponseData.ObjectID=getObjectID(this.MarkerHandle);
            this.ResponseData.SnapToDataVertex=char(snapToVertex);

        end

        function setupPrintBehavior(this,obj)



            behaviorProp=findprop(obj,'Behavior');
            if isempty(behaviorProp)
                behaviorProp=addprop(obj,'Behavior');
                behaviorProp.Hidden=true;
                behaviorProp.Transient=true;
            end
            hBehavior=hggetbehavior(obj,'print');
            hBehavior.PrePrintCallback=@(e,d)this.printCallback(d);
            hBehavior.PostPrintCallback=@(e,d)this.printCallback(d);
        end

        function printCallback(this,type)

            if strcmp(type,'PrePrintCallback')
                this.CachedVisibilityForPrint=this.LocatorHandle.Visible_I;
                this.LocatorHandle.Visible_I='off';
            elseif strcmp(type,'PostPrintCallback')&&...
                ~isempty(this.CachedVisibilityForPrint)
                this.LocatorHandle.Visible_I=this.CachedVisibilityForPrint;
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
