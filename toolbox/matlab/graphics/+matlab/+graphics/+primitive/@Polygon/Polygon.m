classdef(ConstructOnLoad,Sealed)Polygon<matlab.graphics.primitive.Data...
    &matlab.graphics.mixin.Legendable...
    &matlab.graphics.mixin.AxesParentable...
    &matlab.graphics.mixin.Selectable...
    &matlab.graphics.internal.Legacy





    properties(SetObservable=true,AffectsDataLimits,AffectsLegend)
        Shape(1,1)polyshape;
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=false,AffectsObject,AffectsLegend)
        FaceAlpha matlab.internal.datatype.matlab.graphics.datatype.ZeroToOne=1
        FaceColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0.85,0.85,0.85]
        EdgeColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,0]
        EdgeAlpha matlab.internal.datatype.matlab.graphics.datatype.ZeroToOne=1
        LineWidth matlab.internal.datatype.matlab.graphics.datatype.Positive=0.5
        LineStyle matlab.internal.datatype.matlab.graphics.datatype.LineStyle='-'
        LineJoin matlab.internal.datatype.matlab.graphics.datatype.LineJoin='round'
        AlignVertexCenters matlab.internal.datatype.matlab.graphics.datatype.on_off='off'
        Clipping matlab.internal.datatype.matlab.graphics.datatype.on_off='on'
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)
        HoleEdgeColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,0];
        HoleEdgeAlpha matlab.internal.datatype.matlab.graphics.datatype.ZeroToOne=1;
    end

    properties(AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsObject,AffectsLegend)
        HoleEdgeColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        HoleEdgeAlphaMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        HoleEdgeColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,0]
        HoleEdgeAlpha_I matlab.internal.datatype.matlab.graphics.datatype.ZeroToOne=1;
    end

    properties(Transient,Access=public,Hidden,NonCopyable)
        Face matlab.graphics.primitive.world.TriangleStrip
        Edge matlab.graphics.primitive.world.LineLoop
        HoleEdge matlab.graphics.primitive.world.LineLoop
        SelectionHandle matlab.graphics.interactor.ListOfPointsHighlight
    end

    methods
        function colorValueToCaller=get.HoleEdgeColor(hObj)

            colorValueToCaller=hObj.HoleEdgeColor_I;

        end

        function alphaValueToCaller=get.HoleEdgeAlpha(hObj)

            alphaValueToCaller=hObj.HoleEdgeAlpha_I;

        end

        function set.HoleEdgeColor(hObj,newValue)


            hObj.HoleEdgeColorMode='manual';


            hObj.HoleEdgeColor_I=newValue;

        end

        function set.HoleEdgeAlpha(hObj,newValue)


            hObj.HoleEdgeAlphaMode='manual';


            hObj.HoleEdgeAlpha_I=newValue;

        end
    end

    methods
        function hObj=Polygon(varargin)
            hObj.doSetup();


            if~isempty(varargin)
                set(hObj,varargin{:});
            end
        end
    end

    methods(Hidden)

        function doUpdate(hObj,us)

            try

                doDraw=strcmp(hObj.Visible,'on')||strcmp(hObj.PickableParts,'all');

                if(~doDraw||isempty(hObj.Shape)||numboundaries(hObj.Shape)==0)
                    hObj.Face.Visible='off';
                    hObj.Edge.Visible='off';
                    hObj.HoleEdge.Visible='off';
                    if~isempty(hObj.SelectionHandle)
                        hObj.SelectionHandle.Visible='off';
                    end
                    return;
                end


                [EdgeVerts,EdgeStripData,HoleVerts,HoleStripData]=matlab.graphics.primitive.polygon.internal.getPolygonEdgeVertexData(hObj);


                iter=matlab.graphics.axis.dataspace.IndexPointsIterator;
                iter.Vertices=EdgeVerts;
                sevd=TransformPoints(us.DataSpace,...
                us.TransformUnderDataSpace,...
                iter);
                hObj.Edge.VertexData=sevd;
                hObj.Edge.StripData=EdgeStripData;


                color=hObj.EdgeColor;
                if(strcmp(color,'none'))
                    hObj.Edge.Visible='off';
                else
                    hObj.Edge.Visible='on';
                    alpha=hObj.EdgeAlpha;
                    color(4)=alpha;
                    hgfilter('RGBAColorToGeometryPrimitive',hObj.Edge,color);
                    if alpha==1
                        hObj.Edge.ColorType_I='truecolor';
                    else
                        hObj.Edge.ColorType_I='truecoloralpha';
                    end
                end


                iter=matlab.graphics.axis.dataspace.IndexPointsIterator;
                iter.Vertices=HoleVerts;
                sevdHoles=TransformPoints(us.DataSpace,...
                us.TransformUnderDataSpace,...
                iter);
                hObj.HoleEdge.VertexData=sevdHoles;
                hObj.HoleEdge.StripData=HoleStripData;


                holeColorMode=hObj.HoleEdgeColorMode;
                holeAlphaMode=hObj.HoleEdgeAlphaMode;

                if(strcmp(holeColorMode,'auto'))

                    holeColor=hObj.EdgeColor;
                else
                    holeColor=hObj.HoleEdgeColor;
                end

                if(strcmp(holeAlphaMode,'auto'))

                    holeAlpha=hObj.EdgeAlpha;
                else
                    holeAlpha=hObj.HoleEdgeAlpha;
                end

                if(strcmp(holeColor,'none'))
                    hObj.HoleEdge.Visible='off';
                else
                    hObj.HoleEdge.Visible='on';
                    holeColor(4)=holeAlpha;
                    hgfilter('RGBAColorToGeometryPrimitive',hObj.HoleEdge,holeColor);
                    if holeAlpha==1
                        hObj.HoleEdge.ColorType_I='truecolor';
                    else
                        hObj.HoleEdge.ColorType_I='truecoloralpha';
                    end
                end

                hgfilter('LineStyleToPrimLineStyle',hObj.Edge,hObj.LineStyle);
                hgfilter('LineStyleToPrimLineStyle',hObj.HoleEdge,hObj.LineStyle);
                hObj.Edge.LineWidth=hObj.LineWidth;
                hObj.HoleEdge.LineWidth=hObj.LineWidth;
                hObj.Edge.LineJoin=hObj.LineJoin;
                hObj.HoleEdge.LineJoin=hObj.LineJoin;
                hObj.Edge.Clipping=hObj.Clipping;
                hObj.HoleEdge.Clipping=hObj.Clipping;
                hObj.Edge.AlignVertexCenters=hObj.AlignVertexCenters;
                hObj.HoleEdge.AlignVertexCenters=hObj.AlignVertexCenters;
                hObj.Edge.PickableParts=hObj.PickableParts;
                hObj.HoleEdge.PickableParts=hObj.PickableParts;


                try
                    tri=triangulation(hObj.Shape);
                    iter=matlab.graphics.axis.dataspace.IndexPointsIterator;
                    iter.Vertices=tri.Points;
                    vd=TransformPoints(us.DataSpace,...
                    us.TransformUnderDataSpace,...
                    iter);

                    hObj.Face.VertexData=vd;
                    connectivity=tri.ConnectivityList';
                    hObj.Face.VertexIndices=uint32(connectivity(:)');


                    color=hObj.FaceColor;
                    if(strcmp(color,'none'))
                        hObj.Face.Visible='off';
                    else
                        hObj.Face.Visible='on';
                        alpha=hObj.FaceAlpha;
                        color(4)=alpha;
                        hgfilter('RGBAColorToGeometryPrimitive',hObj.Face,color);
                        if alpha==1
                            hObj.Face.ColorType_I='truecolor';
                        else
                            hObj.Face.ColorType_I='truecoloralpha';
                        end
                    end
                    hObj.Face.Clipping=hObj.Clipping;
                    hObj.Face.PickableParts=hObj.PickableParts;
                catch ex1
                    if strcmp(ex1.identifier,'MATLAB:triangulation:EmptyInputTriErrId')
                        hObj.Face.Visible='off';
                    else
                        rethrow(ex1);
                    end
                end


                if strcmp(hObj.Visible,'on')&&strcmp(hObj.Selected,'on')&&strcmp(hObj.SelectionHighlight,'on')
                    if isempty(hObj.SelectionHandle)
                        createSelectionHandle(hObj);
                    end
                    if numboundaries(hObj.Shape)==0
                        hObj.SelectionHandle.VertexData=[];
                    else


                        shVDEdges=matlab.graphics.primitive.polygon.internal.calculatePolygonSelectionHandles(EdgeStripData,sevd,10);
                        shVDHoles=matlab.graphics.primitive.polygon.internal.calculatePolygonSelectionHandles(HoleStripData,sevdHoles,10);
                        shVD=[shVDEdges,shVDHoles];
                        hObj.SelectionHandle.VertexData=shVD;
                        hObj.SelectionHandle.MaxNumPoints=size(shVD,2);
                    end
                    hObj.SelectionHandle.Visible=hObj.Selected;
                    hObj.SelectionHandle.Clipping=hObj.Clipping;
                else
                    if~isempty(hObj.SelectionHandle)
                        hObj.SelectionHandle.VertexData=[];
                        hObj.SelectionHandle.Visible='off';
                    end
                end

            catch ex


                hObj.Face.Visible='off';
                hObj.Edge.Visible='off';
                hObj.HoleEdge.Visible='off';
                if~isempty(hObj.SelectionHandle)
                    hObj.SelectionHandle.Visible='off';
                end

                if strcmp(ex.message,'DataSpace or ColorSpace transform method failed')&&...
                    strcmp(us.DataSpace.isLinear(),'off')


                    error(message('MATLAB:graphics:polygon:InvalidVertex'));
                else
                    rethrow(ex);
                end
            end
        end

        function ex=getXYZDataExtents(hObj)

            ex=matlab.graphics.primitive.polygon.internal.getPolygonXYZDataExtents(hObj);
        end

        function graphic=getLegendGraphic(hObj)

            graphic=matlab.graphics.primitive.polygon.internal.getPolygonLegendIcon(hObj);
        end

        function mcodeConstructor(hObj,hCode)

            setConstructorName(hCode,'plot');

            hFun=getConstructor(hCode);

            hArg=codegen.codeargument(...
            'Value',hObj.Shape,...
            'Name','polyshape','IsParameter',true,...
            'Comment','polyshape object');
            addArgin(hFun,hArg);

            generateDefaultPropValueSyntax(hCode);
        end
    end

    methods(Access=protected,Hidden)
        function group=getPropertyGroups(~)
            group=matlab.graphics.primitive.polygon.internal.getPolygonPropertyGroups();
        end
    end

    methods(Access='private',Hidden=true)
        function doSetup(hObj)


            hObj.Type='polygon';
            addDependencyConsumed(hObj,{'hgtransform_under_dataspace'});


            hObj.Face=matlab.graphics.primitive.world.TriangleStrip;
            hObj.Face.Description_I='Polygon Face';
            hObj.Face.Internal=true;
            hObj.addNode(hObj.Face);

            hObj.Edge=matlab.graphics.primitive.world.LineLoop;
            hObj.Edge.Description_I='Polygon Edge';
            hObj.Edge.Internal=true;
            hObj.addNode(hObj.Edge);

            hObj.HoleEdge=matlab.graphics.primitive.world.LineLoop;
            hObj.HoleEdge.Description_I='Polygon Hole';
            hObj.HoleEdge.Internal=true;
            hObj.addNode(hObj.HoleEdge);

        end

        function createSelectionHandle(hObj)

            hObj.SelectionHandle=matlab.graphics.interactor.ListOfPointsHighlight('Internal',true);
            hObj.addNode(hObj.SelectionHandle);


            hObj.SelectionHandle.Description='Polygon SelectionHandle';
        end
    end

end

