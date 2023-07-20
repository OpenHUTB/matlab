classdef(ConstructOnLoad,UseClassDefaultsOnLoad,Sealed)Polygon...
    <map.graphics.primitive.Data...
    &matlab.graphics.mixin.DataProperties...
    &map.graphics.mixin.GeographicAxesParentable...
    &map.graphics.mixin.MapAxesParentable...
    &map.graphics.mixin.AxesParentableHelper...
    &map.graphics.mixin.Legendable...
    &map.graphics.mixin.Selectable...
    &map.graphics.mixin.ColorOrderUser...
    &matlab.graphics.internal.GraphicsUIProperties




    properties(Dependent)
        FaceColor matlab.internal.datatype.matlab.graphics.datatype.RGBFlatNoneColor=[0,0,0]
        FaceAlpha matlab.internal.datatype.matlab.graphics.datatype.ZeroToOne=0.35
        EdgeColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,0]
        EdgeAlpha matlab.internal.datatype.matlab.graphics.datatype.ZeroToOne=1
        LineStyle matlab.internal.datatype.matlab.graphics.datatype.LineStyle='-'
        LineWidth matlab.internal.datatype.matlab.graphics.datatype.Positive=0.5
    end

    properties(Hidden,NeverAmbiguous)
        FaceColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        FaceAlphaMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        EdgeColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        EdgeAlphaMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        LineStyleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        LineWidthMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
    end

    properties(AffectsObject,AffectsLegend,AbortSet,Hidden)
        FaceColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBFlatNoneColor=[0,0,0]
        FaceAlpha_I matlab.internal.datatype.matlab.graphics.datatype.ZeroToOne=0.35
        EdgeColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,0]
        EdgeAlpha_I matlab.internal.datatype.matlab.graphics.datatype.ZeroToOne=1
        LineStyle_I matlab.internal.datatype.matlab.graphics.datatype.LineStyle='-'
        LineWidth_I matlab.internal.datatype.matlab.graphics.datatype.Positive=0.5
    end

    properties(Dependent)
        ShapeData=geopolyshape.empty(1,0)
        ColorData=double.empty(1,0)
    end

    properties(AffectsDataLimits,Hidden,AffectsLegend)
        ShapeData_I=geopolyshape.empty(1,0)
        ColorData_I=double.empty(1,0)
    end

    properties(NeverAmbiguous)
        ShapeDataMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        ColorDataMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
    end

    properties(Dependent)
        ShapeVariable=''
        ColorVariable=''
    end

    properties(Hidden,Dependent)
        ShapeVariable_I=''
        ColorVariable_I=''
    end

    properties(Hidden,Dependent,NeverAmbiguous,SetAccess=protected)
ShapeDataCache
ColorDataCache
    end

    properties(Hidden,Transient,NonCopyable,SetAccess=protected)
        SelectionHandle matlab.graphics.interactor.ListOfPointsHighlight
LineHandle
FaceHandle
EdgeVertexDataCache
EdgeStripDataCache
FaceVertexDataCache
FaceVertexIndicesCache
DataIndexCache
    end

    methods
        function val=get.FaceColor(hObj)
            if strcmp(hObj.FaceColorMode,'auto')
                forceFullUpdate(hObj,'all','FaceColor');
            end
            val=hObj.FaceColor_I;
        end

        function set.FaceColor(hObj,val)
            hObj.FaceColorMode='manual';
            hObj.FaceColor_I=val;
        end

        function set.FaceColorMode(hObj,val)
            hObj.FaceColorMode=val;
        end

        function val=get.FaceAlpha(hObj)
            val=hObj.FaceAlpha_I;
        end

        function set.FaceAlpha(hObj,val)
            hObj.FaceAlphaMode='manual';
            hObj.FaceAlpha_I=val;
        end

        function set.FaceAlphaMode(hObj,val)
            hObj.FaceAlphaMode=val;
        end

        function val=get.EdgeColor(hObj)
            val=hObj.EdgeColor_I;
        end

        function set.EdgeColor(hObj,val)
            hObj.EdgeColorMode='manual';
            hObj.EdgeColor_I=val;
        end

        function set.EdgeColorMode(hObj,val)
            hObj.EdgeColorMode=val;
        end

        function val=get.EdgeAlpha(hObj)
            val=hObj.EdgeAlpha_I;
        end

        function set.EdgeAlpha(hObj,val)
            hObj.EdgeAlphaMode='manual';
            hObj.EdgeAlpha_I=val;
        end

        function set.EdgeAlphaMode(hObj,val)
            hObj.EdgeAlphaMode=val;
        end

        function val=get.LineStyle(hObj)
            val=hObj.LineStyle_I;
        end

        function set.LineStyle(hObj,val)
            hObj.LineStyleMode='manual';
            hObj.LineStyle_I=val;
        end

        function val=get.LineWidth(hObj)
            val=hObj.LineWidth_I;
        end

        function set.LineWidth(hObj,val)
            hObj.LineWidthMode='manual';
            hObj.LineWidth_I=val;
        end

        function set.ColorData(hObj,value)
            hObj.setDataPropertyValue("Color",value,false);
        end

        function set.ColorData_I(hObj,value)
            hObj.setDataPropertyValue("Color",value,true);
        end

        function set.ColorVariable(hObj,value)
            hObj.setVariablePropertyValue("Color",value,false);
        end

        function set.ColorVariable_I(hObj,value)
            hObj.setVariablePropertyValue("Color",value,true);
        end

        function value=get.ColorData(hObj)
            value=hObj.getDataPropertyValue("Color",false);
        end

        function value=get.ColorData_I(hObj)
            value=hObj.getDataPropertyValue("Color",true);
        end

        function value=get.ColorVariable(hObj)
            value=hObj.getVariablePropertyValue("Color",false);
        end

        function value=get.ColorVariable_I(hObj)
            value=hObj.getVariablePropertyValue("Color",true);
        end

        function value=get.ColorDataCache(hObj)
            value=hObj.getDataPropertyNumericValue("Color",false);
        end

        function set.ShapeData(hObj,value)
            hObj.setDataPropertyValue("Shape",value,false);
        end

        function set.ShapeData_I(hObj,value)
            hObj.setDataPropertyValue("Shape",value,true);
        end

        function set.ShapeVariable(hObj,value)
            hObj.setVariablePropertyValue("Shape",value,false);
        end

        function set.ShapeVariable_I(hObj,value)
            hObj.setVariablePropertyValue("Shape",value,true);
        end

        function value=get.ShapeData(hObj)
            value=hObj.getDataPropertyValue("Shape",false);
        end

        function value=get.ShapeData_I(hObj)
            value=hObj.getDataPropertyValue("Shape",true);
        end

        function value=get.ShapeVariable(hObj)
            value=hObj.getVariablePropertyValue("Shape",false);
        end

        function value=get.ShapeVariable_I(hObj)
            value=hObj.getVariablePropertyValue("Shape",true);
        end

        function value=get.ShapeDataCache(hObj)
            value=hObj.getDataPropertyNumericValue("Shape",false);
        end
    end

    methods
        function hObj=Polygon(varargin)


            hObj.FaceHandle=matlab.graphics.primitive.world.TriangleStrip;
            hgfilter('RGBAColorToGeometryPrimitive',hObj.FaceHandle,[hObj.FaceColor_I,hObj.FaceAlpha_I]);
            set(hObj.FaceHandle,'Internal',true)
            hObj.addNode(hObj.FaceHandle);

            hObj.LineHandle=matlab.graphics.primitive.world.LineStrip;
            set(hObj.LineHandle,'Internal',true)
            hObj.addNode(hObj.LineHandle);

            hObj.SelectionHandle=matlab.graphics.interactor.ListOfPointsHighlight;
            set(hObj.SelectionHandle,'Internal',true)
            hObj.addNode(hObj.SelectionHandle);

            hObj.Type='polygon';
            hObj.addDependencyConsumed({'figurecolormap','colorspace','colororder_linestyleorder'});

            hObj.linkDataPropertyToChannel('ShapeData','Shape');
            hObj.linkDataPropertyToChannel('ColorData','Color');

            matlab.graphics.chart.internal.ctorHelper(hObj,varargin);
        end
    end

    methods(Hidden)
        function doUpdate(hObj,updateState)



            hObj.assignSeriesIndex();
            updatedColor=hObj.getColor(updateState);
            if strcmp(hObj.FaceColorMode,'auto')&&~isempty(updatedColor)
                hObj.FaceColor_I=updatedColor;
            end

            vdata=[];
            if hObj.Visible

                shape=hObj.ShapeDataCache;
                cdata=hObj.ColorDataCache;
                if~isempty(cdata)&&(numel(shape)~=numel(cdata))
                    error(message('MATLAB:graphics:geoplot:DataLengthMismatch','ColorData','ShapeData'))
                end


                hasNoVertexCache=isempty(hObj.EdgeVertexDataCache);
                if hasNoVertexCache
                    [vdata,sdata]=lineStripData(shape);
                    hObj.EdgeVertexDataCache=vdata;
                    hObj.EdgeStripDataCache=sdata;
                else
                    vdata=hObj.EdgeVertexDataCache;
                    sdata=hObj.EdgeStripDataCache;
                end

                if strcmp(hObj.EdgeColor_I,'none')
                    set(hObj.LineHandle,'Visible_I','off')
                else
                    iter=matlab.graphics.axis.dataspace.IndexPointsIterator;
                    iter.Vertices=vdata;
                    vdata=TransformPoints(updateState.DataSpace,...
                    updateState.TransformUnderDataSpace,iter);
                    set(hObj.LineHandle,'Visible_I','on','VertexData',vdata,'StripData',sdata,'LineWidth',hObj.LineWidth_I)
                    hgfilter('LineStyleToPrimLineStyle',hObj.LineHandle,hObj.LineStyle_I)
                    hgfilter('RGBAColorToGeometryPrimitive',hObj.LineHandle,[hObj.EdgeColor_I,hObj.EdgeAlpha_I])
                end

                if hasNoVertexCache
                    [vdata,ivdata,shapeidx]=triangleStripData(shape);
                    hObj.FaceVertexDataCache=vdata;
                    hObj.FaceVertexIndicesCache=ivdata;
                    hObj.DataIndexCache=shapeidx;
                else
                    vdata=hObj.FaceVertexDataCache;
                    ivdata=hObj.FaceVertexIndicesCache;
                    shapeidx=hObj.DataIndexCache;
                end

                if strcmp(hObj.FaceColor_I,'flat')&&~isempty(cdata)




                    vdataDiscrete=vdata(ivdata,:);
                    vdata=vdataDiscrete;
                    ivdata=[];
                end

                iter=matlab.graphics.axis.dataspace.IndexPointsIterator;
                iter.Vertices=vdata;
                vdata=TransformPoints(updateState.DataSpace,...
                updateState.TransformUnderDataSpace,iter);
                set(hObj.FaceHandle,'VertexData',vdata,'VertexIndices',ivdata)

                if hObj.FaceAlpha_I<1
                    faceColorType='truecoloralpha';
                else
                    faceColorType='truecolor';
                end
                if strcmp(hObj.FaceColor_I,'flat')&&~isempty(cdata)

                    colorIter=matlab.graphics.axis.colorspace.IndexColorsIterator;
                    colorIter.Colors=hObj.ColorDataCache(shapeidx);
                    colorIter.AlphaData=hObj.FaceAlpha_I;
                    tColors=updateState.ColorSpace.TransformColormappedToTrueColor(colorIter);
                    set(hObj.FaceHandle,'ColorBinding_I','discrete','ColorData_I',tColors.Data)


                    nanColors=isnan(colorIter.Colors);
                    if any(nanColors)
                        hObj.FaceHandle.ColorData_I(4,nanColors)=uint8(0);
                        faceColorType='truecoloralpha';
                    end
                elseif strcmp(hObj.FaceColor_I,'flat')


                    set(hObj.FaceHandle,'ColorBinding_I','object')
                    hgfilter('RGBAColorToGeometryPrimitive',hObj.FaceHandle,[updatedColor,hObj.FaceAlpha_I])
                else

                    set(hObj.FaceHandle,'ColorBinding_I','object')
                    hgfilter('RGBAColorToGeometryPrimitive',hObj.FaceHandle,[hObj.FaceColor_I,hObj.FaceAlpha_I])
                end
                set(hObj.FaceHandle,'ColorType_I',faceColorType)
            end
            drawSelectionHighlight(hObj,vdata)
        end

        function extents=getXYZDataExtents(hObj,~,constraints)
            S=exportShapeData(hObj.ShapeDataCache);
            lat=S.Coordinate2(:);
            lon=S.Coordinate1(:);
            [latD,lonD]=matlab.graphics.chart.primitive.utilities.preprocessextents(lat,lon);
            latlim=NaN(1,4);
            [latlim(1),latlim(4)]=bounds(latD);
            lonlim=NaN(1,4);
            [lonlim(1),lonlim(4)]=bounds(lonD);
            extents=[latlim;lonlim;NaN(1,4)];
        end

        function extents=getColorAlphaDataExtents(hObj)
            extents=NaN(2,4);

            useColorOrder=strcmp(hObj.ColorDataMode,'auto')&&...
            ~hObj.isDataComingFromDataSource('Color')&&hObj.SeriesIndex~=0;
            if strcmp(hObj.CLimInclude,'on')&&~useColorOrder
                c=hObj.ColorDataCache;
                if~isempty(c)
                    k=isfinite(c);
                    extents(1,:)=matlab.graphics.chart.primitive.utilities.arraytolimits(c(k));
                end
            end
        end

        function graphic=getLegendGraphic(hObj)
            graphic=matlab.graphics.primitive.world.Group;

            face=matlab.graphics.primitive.world.Quadrilateral;
            face.VertexData=single([0,0,1,1;0,1,1,0;0,0,0,0]);
            face.VertexIndices=[];
            face.StripData=[];
            face.Parent=graphic;
            if strcmp(hObj.FaceColor_I,'flat')
                neutralColor=[.4,.4,.4];
                hgfilter('RGBAColorToGeometryPrimitive',face,[neutralColor,hObj.FaceAlpha_I])
            else
                hgfilter('RGBAColorToGeometryPrimitive',face,[hObj.FaceColor_I,hObj.FaceAlpha_I])
            end

            edge=matlab.graphics.primitive.world.LineLoop('LineJoin','round');
            edge.VertexData=single([0,0,1,1;0,1,1,0;0,0,0,0]);
            edge.VertexIndices=[];
            edge.StripData=uint32([1,5]);
            edge.AlignVertexCenters='on';
            if strcmp(hObj.EdgeColor_I,'none')
                hgfilter('RGBAColorToGeometryPrimitive',edge,'none')
            else
                hgfilter('RGBAColorToGeometryPrimitive',edge,[hObj.EdgeColor_I,hObj.EdgeAlpha_I])
            end
            hgfilter('LineStyleToPrimLineStyle',edge,hObj.LineStyle_I)
            edge.LineWidth=hObj.LineWidth_I;
            edge.Parent=graphic;
        end
    end

    methods(Access=protected)
        function groups=getPropertyGroups(hObj)
            suffix=["Data","Variable"];
            dvars{1}='ShapeData';
            dvars{2}=char("Color"+suffix(1+hObj.isDataComingFromDataSource('Color')));
            groups=matlab.mixin.util.PropertyGroup(...
            [dvars,'FaceColor','FaceAlpha','EdgeColor']);
        end

        function[converter,converterFound]=getNonNumericConverterForChannel(hObj,channelName)







            channelName=string(channelName);
            if channelName=="Shape"


                converter=map.graphics.internal.ShapeDataCRSConverter;
                converterFound=~isempty(converter);
            else

                [converter,converterFound]=getNonNumericConverterForChannel@matlab.graphics.mixin.DataProperties(hObj,channelName);
            end
        end

        function dataPropertyValueChanged(hObj,channelName)
            if channelName=="Shape"
                hObj.EdgeVertexDataCache=[];
                hObj.EdgeStripDataCache=[];
                hObj.FaceVertexDataCache=[];
                hObj.FaceVertexIndicesCache=[];
                hObj.DataIndexCache=[];
            end
        end
    end

    methods(Static,Access=protected)
        function dataValue=validateDataPropertyValue(dataChannelName,dataValue)

            if isempty(dataValue)||isvector(dataValue)
                if~isrow(dataValue)
                    dataValue=dataValue';
                end
            else
                throwAsCaller(MException(message('MATLAB:graphics:chart:MustBeVector',dataChannelName)))
            end


            switch dataChannelName
            case 'Shape'
                mustBeA(dataValue,{'geopolyshape','mappolyshape'})
                if dataValue.CoordinateSystemType=="planar"&&isempty(dataValue.ProjectedCRS)
                    throwAsCaller(MException(message("map:graphics:MustSpecifyProjectedCRS")))
                end
            case 'Color'
                mustBeNumeric(dataValue)
                dataValue=validateDataPropertyValue@matlab.graphics.mixin.DataProperties(dataChannelName,dataValue);
            end
        end
    end

    methods(Access=private)
        function drawSelectionHighlight(hObj,vertexData)
            hSelection=hObj.SelectionHandle;
            if~isempty(vertexData)&&strcmp(hObj.Visible,'on')...
                &&strcmp(hObj.Selected,'on')&&strcmp(hObj.SelectionHighlight,'on')
                numVertices=width(vertexData);
                if numVertices>150

                    selectionIdx=round(linspace(1,numVertices,150));
                    selectionVertexData=vertexData(:,selectionIdx);
                else
                    selectionVertexData=vertexData;
                end
                hSelection.VertexData=selectionVertexData;
                hSelection.Visible='on';
            else
                hSelection.Visible='off';
            end
        end
    end
end