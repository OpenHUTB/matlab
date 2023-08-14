classdef(ConstructOnLoad,UseClassDefaultsOnLoad,Sealed)Point<map.graphics.primitive.Data...
    &matlab.graphics.mixin.DataProperties...
    &map.graphics.mixin.GeographicAxesParentable...
    &map.graphics.mixin.MapAxesParentable...
    &map.graphics.mixin.AxesParentableHelper...
    &map.graphics.mixin.Legendable...
    &map.graphics.mixin.Selectable...
    &map.graphics.mixin.ColorOrderUser...
    &matlab.graphics.internal.GraphicsUIProperties




    properties(Dependent)
        Marker matlab.internal.datatype.matlab.graphics.datatype.MarkerStyle='.'
        MarkerSize matlab.internal.datatype.matlab.graphics.datatype.Positive=6
        MarkerFaceColor matlab.internal.datatype.matlab.graphics.datatype.RGBFlatNoneColor='none'
        MarkerFaceAlpha matlab.internal.datatype.matlab.graphics.datatype.ZeroToOne=1
        MarkerEdgeColor matlab.internal.datatype.matlab.graphics.datatype.RGBFlatNoneColor=[0,0,0]
        MarkerEdgeAlpha matlab.internal.datatype.matlab.graphics.datatype.ZeroToOne=1
    end

    properties(Hidden,NeverAmbiguous)
        MarkerMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        MarkerSizeMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        MarkerFaceColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        MarkerFaceAlphaMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        MarkerEdgeColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        MarkerEdgeAlphaMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
    end

    properties(AffectsObject,AffectsLegend,AbortSet,Hidden)
        Marker_I matlab.internal.datatype.matlab.graphics.datatype.MarkerStyle='.'
        MarkerSize_I matlab.internal.datatype.matlab.graphics.datatype.Positive=6
        MarkerFaceColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBFlatNoneColor='none'
        MarkerFaceAlpha_I matlab.internal.datatype.matlab.graphics.datatype.ZeroToOne=1
        MarkerEdgeColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBFlatNoneColor=[0,0,0]
        MarkerEdgeAlpha_I matlab.internal.datatype.matlab.graphics.datatype.ZeroToOne=1
    end

    properties(Dependent)
        ShapeData=geopointshape.empty(1,0)
        ColorData=double.empty(1,0)
    end

    properties(AffectsDataLimits,Hidden,AffectsLegend)
        ShapeData_I=geopointshape.empty(1,0)
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
MarkerHandle
VertexDataCache
DataIndexCache
    end

    methods
        function val=get.Marker(hObj)
            val=hObj.Marker_I;
        end

        function set.Marker(hObj,val)
            hObj.MarkerMode='manual';
            hObj.Marker_I=val;
        end

        function val=get.MarkerSize(hObj)
            val=hObj.MarkerSize_I;
        end

        function set.MarkerSize(hObj,val)
            hObj.MarkerSizeMode='manual';
            hObj.MarkerSize_I=val;
        end

        function val=get.MarkerFaceColor(hObj)
            val=hObj.MarkerFaceColor_I;
        end

        function set.MarkerFaceColor(hObj,val)
            hObj.MarkerFaceColorMode='manual';
            hObj.MarkerFaceColor_I=val;
        end

        function set.MarkerFaceColorMode(hObj,val)
            hObj.MarkerFaceColorMode=val;
        end

        function val=get.MarkerFaceAlpha(hObj)
            val=hObj.MarkerFaceAlpha_I;
        end

        function set.MarkerFaceAlpha(hObj,val)
            hObj.MarkerFaceAlphaMode='manual';
            hObj.MarkerFaceAlpha_I=val;
        end

        function set.MarkerFaceAlphaMode(hObj,val)
            hObj.MarkerFaceAlphaMode=val;
        end

        function val=get.MarkerEdgeColor(hObj)
            if strcmp(hObj.MarkerEdgeColorMode,'auto')
                forceFullUpdate(hObj,'all','MarkerEdgeColor');
            end
            val=hObj.MarkerEdgeColor_I;
        end

        function set.MarkerEdgeColor(hObj,val)
            hObj.MarkerEdgeColorMode='manual';
            hObj.MarkerEdgeColor_I=val;
        end

        function set.MarkerEdgeColorMode(hObj,val)
            hObj.MarkerEdgeColorMode=val;
        end

        function val=get.MarkerEdgeAlpha(hObj)
            val=hObj.MarkerEdgeAlpha_I;
        end

        function set.MarkerEdgeAlpha(hObj,val)
            hObj.MarkerEdgeAlphaMode='manual';
            hObj.MarkerEdgeAlpha_I=val;
        end

        function set.MarkerEdgeAlphaMode(hObj,val)
            hObj.MarkerEdgeAlphaMode=val;
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
        function hObj=Point(varargin)


            hObj.MarkerHandle=matlab.graphics.primitive.world.Marker;
            hgfilter('MarkerStyleToPrimMarkerStyle',hObj.MarkerHandle,hObj.Marker_I);
            set(hObj.MarkerHandle,'Internal',true)
            hObj.addNode(hObj.MarkerHandle);

            hObj.SelectionHandle=matlab.graphics.interactor.ListOfPointsHighlight;
            set(hObj.SelectionHandle,'Internal',true)
            hObj.addNode(hObj.SelectionHandle);

            hObj.Type='point';
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
            if strcmp(hObj.MarkerEdgeColorMode,'auto')&&~isempty(updatedColor)
                hObj.MarkerEdgeColor_I=updatedColor;
            end

            mkr=hObj.MarkerHandle;
            if hObj.Visible

                shape=hObj.ShapeDataCache;
                cdata=hObj.ColorDataCache;
                if~isempty(cdata)&&(numel(shape)~=numel(cdata))
                    error(message('MATLAB:graphics:geoplot:DataLengthMismatch','ColorData','ShapeData'))
                end


                if isempty(hObj.VertexDataCache)
                    [vdata,shapeidx]=markerData(shape);
                    hObj.VertexDataCache=vdata;
                    hObj.DataIndexCache=shapeidx;
                else
                    vdata=hObj.VertexDataCache;
                    shapeidx=hObj.DataIndexCache;
                end

                iter=matlab.graphics.axis.dataspace.IndexPointsIterator;
                iter.Vertices=vdata;
                vertexData=TransformPoints(updateState.DataSpace,...
                updateState.TransformUnderDataSpace,iter);
                set(mkr,'VertexData',vertexData,'Size',hObj.MarkerSize_I)
                hgfilter('MarkerStyleToPrimMarkerStyle',mkr,hObj.Marker_I)


                faceColorType='truecolor';
                if strcmp(hObj.MarkerFaceColor_I,'flat')&&~isempty(cdata)

                    colorIter=matlab.graphics.axis.colorspace.IndexColorsIterator;
                    colorIter.Colors=hObj.ColorDataCache(shapeidx);
                    colorIter.Indices=1:length(shapeidx);

                    if hObj.MarkerFaceAlpha_I<1
                        colorIter.AlphaData=hObj.MarkerFaceAlpha_I;
                        faceColorType='truecoloralpha';
                    end
                    tColors=updateState.ColorSpace.TransformColormappedToTrueColor(colorIter);
                    set(hObj.MarkerHandle,'FaceColorBinding_I','discrete','FaceColorData_I',tColors.Data)


                    nanColors=isnan(colorIter.Colors);
                    if any(nanColors)
                        hObj.MarkerHandle.FaceColorData_I(4,nanColors)=uint8(0);
                        faceColorType='truecoloralpha';
                    end
                else

                    hgfilter('FaceColorToMarkerPrimitive',mkr,hObj.MarkerFaceColor_I)


                    if~strcmp(hObj.MarkerFaceColor_I,'none')&&hObj.MarkerFaceAlpha_I<1
                        hObj.MarkerHandle.FaceColorData_I(4,:)=uint8(255*hObj.MarkerFaceAlpha_I);
                        faceColorType='truecoloralpha';
                    end
                end
                set(hObj.MarkerHandle,'FaceColorType_I',faceColorType)


                edgeColorType='truecolor';
                if strcmp(hObj.MarkerEdgeColor_I,'flat')&&~isempty(cdata)

                    colorIter=matlab.graphics.axis.colorspace.IndexColorsIterator;
                    colorIter.Colors=hObj.ColorDataCache(shapeidx);
                    colorIter.Indices=1:length(shapeidx);

                    if hObj.MarkerEdgeAlpha_I<1
                        colorIter.AlphaData=hObj.MarkerEdgeAlpha_I;
                        edgeColorType='truecoloralpha';
                    end
                    tColors=updateState.ColorSpace.TransformColormappedToTrueColor(colorIter);
                    set(hObj.MarkerHandle,'EdgeColorBinding_I','discrete','EdgeColorData_I',tColors.Data)


                    nanColors=isnan(colorIter.Colors);
                    if any(nanColors)
                        hObj.MarkerHandle.EdgeColorData_I(4,nanColors)=uint8(0);
                        edgeColorType='truecoloralpha';
                    end
                else

                    hgfilter('EdgeColorToMarkerPrimitive',mkr,hObj.MarkerEdgeColor_I)


                    if~strcmp(hObj.MarkerEdgeColor_I,'none')&&hObj.MarkerEdgeAlpha_I<1
                        hObj.MarkerHandle.EdgeColorData_I(4,:)=uint8(255*hObj.MarkerEdgeAlpha_I);
                        edgeColorType='truecoloralpha';
                    end
                end
                set(hObj.MarkerHandle,'EdgeColorType_I',edgeColorType)
            end
            drawSelectionHighlight(hObj,mkr.VertexData)
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
            mkr=matlab.graphics.primitive.world.Marker;
            mkr.Parent=graphic;
            mkr.VertexData=single([.5;.5;0]);
            hgfilter('MarkerStyleToPrimMarkerStyle',mkr,hObj.Marker_I)
            neutralColor=[.4,.4,.4];
            if strcmp(hObj.MarkerFaceColor_I,'flat')
                hgfilter('FaceColorToMarkerPrimitive',mkr,neutralColor)
            else
                hgfilter('FaceColorToMarkerPrimitive',mkr,hObj.MarkerFaceColor_I)
            end
            if strcmp(hObj.MarkerEdgeColor_I,'flat')
                hgfilter('EdgeColorToMarkerPrimitive',mkr,neutralColor)
            else
                hgfilter('EdgeColorToMarkerPrimitive',mkr,hObj.MarkerEdgeColor_I)
            end
        end
    end

    methods(Access=protected)
        function groups=getPropertyGroups(hObj)
            suffix=["Data","Variable"];
            dvars{1}='ShapeData';
            dvars{2}=char("Color"+suffix(1+hObj.isDataComingFromDataSource('Color')));
            groups=matlab.mixin.util.PropertyGroup(...
            [dvars,'Marker','MarkerSize','MarkerEdgeColor','MarkerFaceColor']);
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
                hObj.VertexDataCache=[];
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
                mustBeA(dataValue,{'geopointshape','mappointshape'})
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
            if strcmp(hObj.Visible,'on')&&strcmp(hObj.Selected,'on')&&strcmp(hObj.SelectionHighlight,'on')
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