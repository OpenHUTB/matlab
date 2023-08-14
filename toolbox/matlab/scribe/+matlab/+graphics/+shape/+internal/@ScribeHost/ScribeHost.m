classdef(ConstructOnLoad=true,Sealed,Hidden)ScribeHost<matlab.graphics.primitive.Data&matlab.graphics.mixin.AxesParentable&matlab.graphics.mixin.Selectable








    properties(AbortSet,DeepCopy)

        DisplayHandle matlab.internal.datatype.matlab.graphics.primitive.world.SceneNode

        PositionProperty{matlab.internal.validation.mustBeASCIICharRowVector(PositionProperty,'PositionProperty')}='';






        Position=[0,0,0];








        PerformTransform(1,1)logical=false;





        Tag{matlab.internal.validation.mustBeCharRowVector(Tag,'Tag')}='';
    end

    properties(SetAccess=private,GetAccess=public,Transient,NonCopyable,Hidden)

PeerHandle
    end

    properties(Access=private,Transient,NonCopyable)


        PeerReparentPending=false


AncestorListener


PeerHitListener


PeerDestroyListener



AnnotationPaneDeleteListener
    end

    methods
        function obj=ScribeHost(varargin)




            obj.addDependencyConsumed({'view','dataspace','hgtransform_under_dataspace','xyzdatalimits'});






            addlistener(obj,'ObjectChildAdded',@(s,e)obj.setDisplayhandle(s,e));



            if nargin>1
                set(obj,varargin{:});
            end
        end





        function setDisplayhandle(obj,~,e)
            val=e.Child;
            if~isa(val,'matlab.graphics.shape.internal.ScribePeer')
                set(obj,'DisplayHandle',val);
            end
        end

        function delete(obj)


            if~isempty(obj.DisplayHandle)&&isvalid(obj.DisplayHandle)
                delete(obj.DisplayHandle);
            end


            if~isempty(obj.PeerHandle)&&isvalid(obj.PeerHandle)
                delete(obj.PeerHandle);
            end
        end

        function set.DisplayHandle(obj,val)
            obj.DisplayHandle=val;
            obj.MarkDirty('all');
        end

        function set.Position(obj,val)
            obj.Position=val;
            obj.MarkDirty('all');
        end

        function set.PositionProperty(obj,val)
            val=matlab.internal.validation.makeCharRowVector(val);
            obj.PositionProperty=val;
            obj.MarkDirty('all');
        end

        function set.PerformTransform(obj,val)
            obj.PerformTransform=val;
            obj.MarkDirty('all');
        end

        function set.Tag(obj,val)
            val=matlab.internal.validation.makeCharRowVector(val);
            obj.Tag=val;
            if~isempty(obj.PeerHandle)&&isvalid(obj.PeerHandle)
                obj.PeerHandle.Tag=val;
            end
        end
    end


    methods(Hidden)

        function hParent=setParentImpl(obj,hParent)


            obj.doReparent(hParent);
        end

        function setPeerParentSerializable(obj)





            peerParent=obj.PeerHandle.Parent;
            if~isempty(peerParent)&&strcmp(peerParent.Serializable,'off')
                peerParent.Serializable='on';
            end
        end


        function bringToFront(obj)





            if isprop(obj.Parent,'ParentLayer')&&...
                strcmp(obj.Parent.ParentLayer,'middle')
                hChild=obj.Parent;
            else
                hChild=obj.PeerHandle;
            end

            obj.makeFirstChild(hChild);
        end

        function makeFirstChild(~,hObj)


            hParent=hObj.Parent;
            hObj.Parent=[];
            hObj.Parent=hParent;
        end

        function sc=getScribePeer(obj)
            sc=obj.PeerHandle;
        end


        function doUpdate(obj,updateState)





            obj.checkPeer(false);

            if~isempty(obj.PeerHandle)

                iter=matlab.graphics.axis.dataspace.IndexPointsIterator;
                iter.Vertices=obj.Position;





                if strcmp(updateState.Visible,'off')||strcmp(obj.Visible,'off')
                    peerVis='off';
                else
                    peerVis='on';
                end
                try
                    vd=TransformPoints(updateState.DataSpace,...
                    updateState.TransformUnderDataSpace,iter);
                catch E
                    vd=single([0;0;0]);
                    peerVis='off';
                end


                pixPos=matlab.graphics.internal.transformWorldToViewer(...
                updateState.Camera,...
                updateState.TransformAboveDataSpace,...
                updateState.DataSpace,...
                updateState.TransformUnderDataSpace,...
                vd,true);
                pixPos=double(pixPos.');



                obj.PeerHandle.PositionProperty=obj.PositionProperty;
                obj.PeerHandle.DisplayHandle=obj.DisplayHandle;
                obj.PeerHandle.PerformTransform=obj.PerformTransform;
                obj.PeerHandle.Visible=peerVis;
                if isprop(obj.Parent,'ParentLayer')...
                    &&strcmp(obj.Parent.ParentLayer,'middle')...
                    &&strcmp(obj.Parent.PinnedView,'on')
                    obj.PeerHandle.PixelPosition=vd;
                else
                    obj.PeerHandle.PixelPosition=pixPos;
                end
            end
        end
    end


    methods(Access=private)

        function hPeer=createPeer(obj)

            hPeer=matlab.graphics.shape.internal.ScribePeer('Tag',obj.Tag);
            obj.PeerDestroyListener=event.listener(hPeer,'ObjectBeingDestroyed',@obj.handlePeerDeletion);
            obj.PeerHitListener=event.listener(hPeer,'Hit',@obj.handlePeerHit);
        end

        function handleAnnotationPaneDeletion(obj,~,~)


            delete(obj.PeerHandle);
        end

        function handlePeerDeletion(obj,~,~)



            if isvalid(obj)&&~isempty(obj.DisplayHandle)&&isvalid(obj.DisplayHandle)
                obj.DisplayHandle.Parent=matlab.graphics.primitive.world.Group.empty;
            end
        end

        function handlePeerHit(obj,~,evt)
            if isvalid(obj)

                newEvt=matlab.graphics.shape.internal.TipHitEvent(...
                evt.Button,evt.IntersectionPoint,evt.Primitive);
                obj.notify('Hit',newEvt);
            end
        end

        function checkPeer(obj,DoFixNow,hParent)



            if nargin<3

                hParent=obj.Parent;
            end


            if isempty(obj.PeerHandle)||~isvalid(obj.PeerHandle)
                obj.PeerHandle=createPeer(obj);
            end


            if~areInSamePanel(hParent,obj.PeerHandle)
                if DoFixNow

                    obj.setPeerParent(hParent);
                elseif~obj.PeerReparentPending



                    obj.PeerReparentPending=true;
                    ReparentListener=addlistener(obj,'MarkedClean',@(s,e)nDelayedReparent());
                end
            end

            function nDelayedReparent()
                delete(ReparentListener);

                obj.setPeerParent(hParent);
                if isvalid(obj)
                    obj.PeerReparentPending=false;
                end
            end
        end

        function setPeerParent(obj,hParent)

            ap=findAnnotationPane(hParent);
            hFig=ancestor(obj,'figure','node');
            if isvalid(obj)&&isvalid(obj.PeerHandle)
                if matlab.ui.internal.isUIFigure(hFig)...
                    &&~isempty(obj.Parent)&&isvalid(obj.Parent)...
                    &&isprop(obj.Parent,'PinnedView')...
                    &&strcmp(obj.Parent.PinnedView,'on')...
                    &&strcmp(obj.Parent.ParentLayer,'middle')
                    obj.Parent.setParentToMiddleLayer(hFig);
                else
                    obj.PeerHandle.Parent=ap;
                end
                obj.AnnotationPaneDeleteListener=event.listener(obj.PeerHandle.Parent,'ObjectBeingDestroyed',@obj.handleAnnotationPaneDeletion);
            end
        end

        function createAncestorListener(obj,hParent)



            h=gobjects(1,0);
            viewer=ancestor(hParent,'matlab.ui.internal.mixin.CanvasHostMixin');
            p=hParent;
            while~isempty(p)&&(isempty(viewer)||p~=viewer)
                h(end+1)=p;
                p=p.Parent;
            end

            if~isempty(h)

                obj.AncestorListener=event.proplistener(h,h(1).findprop('Parent'),...
                'PostSet',@obj.handleAncestorReparent);
            else

                obj.AncestorListener=[];
            end
        end

        function handleAncestorReparent(obj,~,~)
            obj.doReparent(obj.Parent);
        end

        function doReparent(obj,hParent)

            obj.checkPeer(true,hParent);


            obj.createAncestorListener(hParent);



            obj.MarkDirty('all')
        end
    end

    methods(Hidden)
        function setClippingAndlayer(obj)

            cm=obj.PeerHandle.NodeChildren;

            for i=1:length(cm.NodeChildren)


                cm.NodeChildren(i).Clipping='on';






                if isprop(cm.NodeChildren(i),'Layer')
                    cm.NodeChildren(i).Layer='front';
                end
            end
        end
    end
end


function ret=areInSamePanel(obj1,obj2)

    P1=ancestor(obj1,'matlab.ui.internal.mixin.CanvasHostMixin');
    P2=ancestor(obj2,'matlab.ui.internal.mixin.CanvasHostMixin');
    ret=(isempty(P1)&&isempty(P2))||(~isempty(P1)&&~isempty(P2)&&P1==P2);
end


function hAP=findAnnotationPane(obj)

    hPanel=ancestor(obj,'matlab.ui.internal.mixin.CanvasHostMixin');
    if~isempty(hPanel)
        hCanvas=findobjinternal(hPanel,'-isa','matlab.graphics.primitive.canvas.Canvas','-depth',1);

        ssm=hCanvas.StackManager;
        if isempty(ssm)
            ssm=matlab.graphics.shape.internal.ScribeStackManager.getInstance();
            hCanvas.StackManager=ssm;
        end
        layer=ssm.getLayer(hCanvas,'overlay');
        hAP=layer.Pane;
    else
        hAP=matlab.graphics.primitive.world.SceneNode.empty;
    end
end
