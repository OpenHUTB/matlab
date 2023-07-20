classdef(ConstructOnLoad,Sealed)PointTipLocator<matlab.graphics.shape.internal.TipLocator





    properties

        Position=[0,0,0]


        Size=5


        Marker='o'


        FaceColor=matlab.graphics.shape.internal.PointTipLocator.PINNED_MARKERCOLOR


        EdgeColor=[1,1,220/255]
    end

    properties(Constant,Hidden)
        TRANSIENT_MARKERCOLOR matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[.5,.5,.5]
        PINNED_MARKERCOLOR matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[.15,.15,.15]
    end

    properties(SetAccess=private,GetAccess=public,Hidden,Transient,NonCopyable)
ScribeMarkerHandleFace
ScribeMarkerHandleEdge
ScribeHost
    end

    properties(Hidden=true)
        ParentLayer='overlay';
    end

    methods
        function obj=PointTipLocator(varargin)











            obj.ScribeMarkerHandleFace=matlab.graphics.primitive.world.Marker(...
            'Description','PointTipLocator Marker',...
            'Internal',true,...
            'Clipping','off',...
            'Layer','middle',...
            'EdgeColorBinding','none',...
            'VertexData',single([0;0;0]));

            obj.ScribeMarkerHandleEdge=matlab.graphics.primitive.world.Marker(...
            'Description','PointTipLocator Marker',...
            'Internal',true,...
            'Clipping','off',...
            'Layer','middle',...
            'FaceColorBinding','none',...
            'VertexData',single([0;0;0]));
            scribeGroup=matlab.graphics.primitive.world.CompositeMarker(...
            'Description','PointTipLocator Marker Group',...
            'Internal',true);
            scribeGroup.addNode(obj.ScribeMarkerHandleFace);
            scribeGroup.addNode(obj.ScribeMarkerHandleEdge);

            obj.ScribeHost=matlab.graphics.shape.internal.ScribeHost(...
            'DisplayHandle',scribeGroup,...
            'PositionProperty','VertexData',...
            'PerformTransform',true,...
            'Internal',true,...
            'Tag','PointTipLocator');
            obj.addNode(obj.ScribeHost);


            obj.forwardMarker(obj.Marker);
            obj.forwardSize(obj.Size);
            obj.forwardFaceColor(obj.FaceColor);
            obj.forwardEdgeColor(obj.EdgeColor);

            obj.ScribeHost.addlistener('Hit',@(s,e)obj.notify('Hit',e));

            if nargin
                set(obj,varargin{:});
            end
        end


        function set.Position(obj,newValue)
            obj.Position=newValue;


            obj.MarkDirty('all');
        end

        function set.ParentLayer(hObj,newValue)
            hObj.ParentLayer=newValue;



            if strcmp(hObj.ParentLayer,'middle')
                hObj.ScribeMarkerHandleEdge.Clipping='on';%#ok<MCSUP>
                hObj.ScribeMarkerHandleFace.Clipping='on';%#ok<MCSUP>
            end
        end

        function set.Size(obj,newValue)
            obj.Size=newValue;
            obj.forwardSize(newValue);
        end

        function set.Marker(obj,newValue)
            obj.Marker=newValue;
            obj.forwardMarker(newValue);
        end

        function set.FaceColor(obj,newValue)
            obj.FaceColor=newValue;
            obj.forwardFaceColor(newValue);
        end

        function set.EdgeColor(obj,newValue)
            obj.EdgeColor=newValue;
            obj.forwardEdgeColor(newValue);
        end

        doUpdate(obj,updateState);
    end

    methods(Hidden)





        function setMarkerPickableParts(hObj,newValue)



            hObj.ScribeMarkerHandleFace.PickableParts=newValue;
            hObj.ScribeMarkerHandleEdge.PickableParts=newValue;

            hObj.setPickability(newValue);
        end

        function setPickability(hObj,newValue)
            scribePeer=hObj.ScribeHost.getScribePeer();
            scribePeer.PickableParts=newValue;
        end

        function setTransparency(hObj,newValue)

            hObj.ScribeMarkerHandleEdge.EdgeColorType='truecoloralpha';
            hObj.ScribeMarkerHandleFace.FaceColorType='truecoloralpha';
            hObj.ScribeMarkerHandleFace.FaceColorData(4)=newValue;
            hObj.ScribeMarkerHandleEdge.EdgeColorData(4)=newValue;

        end

    end

    methods(Access=private)

        function forwardMarker(obj,marker)

            hgfilter('MarkerStyleToPrimMarkerStyle',obj.ScribeMarkerHandleFace,marker);
            hgfilter('MarkerStyleToPrimMarkerStyle',obj.ScribeMarkerHandleEdge,marker);
        end

        function forwardSize(obj,sz)
            obj.ScribeMarkerHandleEdge.Size=sz;


            obj.ScribeMarkerHandleFace.Size=sz-obj.ScribeMarkerHandleEdge.LineWidth;
        end

        function forwardFaceColor(obj,fc)

            hgfilter('FaceColorToMarkerPrimitive',obj.ScribeMarkerHandleFace,fc);
        end

        function forwardEdgeColor(obj,ec)


            hgfilter('EdgeColorToMarkerPrimitive',obj.ScribeMarkerHandleEdge,ec);
        end
    end
end
