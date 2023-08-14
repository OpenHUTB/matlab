classdef(ConstructOnLoad,UseClassDefaultsOnLoad,Sealed)Line...
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
        Color matlab.internal.datatype.matlab.graphics.datatype.RGBFlatNoneColor=[0,0,0]
        LineStyle matlab.internal.datatype.matlab.graphics.datatype.LineStyle='-'
        LineWidth matlab.internal.datatype.matlab.graphics.datatype.Positive=0.5
    end

    properties(Hidden,NeverAmbiguous)
        ColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        LineStyleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        LineWidthMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
    end

    properties(AffectsObject,AffectsLegend,AbortSet,Hidden)
        Color_I matlab.internal.datatype.matlab.graphics.datatype.RGBFlatNoneColor=[0,0,0]
        LineStyle_I matlab.internal.datatype.matlab.graphics.datatype.LineStyle='-'
        LineWidth_I matlab.internal.datatype.matlab.graphics.datatype.Positive=0.5
    end

    properties(Dependent)
        ShapeData=geolineshape.empty(1,0)
        ColorData=double.empty(1,0)
    end

    properties(AffectsDataLimits,Hidden,AffectsLegend)
        ShapeData_I=geolineshape.empty(1,0)
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
VertexDataCache
StripDataCache
DataIndexCache
    end

    methods
        function val=get.Color(hObj)
            if strcmp(hObj.ColorMode,'auto')
                forceFullUpdate(hObj,'all','Color');
            end
            val=hObj.Color_I;
        end

        function set.Color(hObj,val)
            hObj.ColorMode='manual';
            hObj.Color_I=val;
        end

        function set.ColorMode(hObj,val)
            hObj.ColorMode=val;
        end

        function val=get.LineStyle(hObj)
            val=hObj.LineStyle_I;
        end

        function set.LineStyle(hObj,val)
            hObj.LineStyleMode='manual';
            hObj.LineStyle_I=val;
        end

        function set.LineStyleMode(hObj,val)
            hObj.LineStyleMode=val;
        end

        function val=get.LineWidth(hObj)
            val=hObj.LineWidth_I;
        end

        function set.LineWidth(hObj,val)
            hObj.LineWidthMode='manual';
            hObj.LineWidth_I=val;
        end

        function set.LineWidthMode(hObj,val)
            hObj.LineWidthMode=val;
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
        function hObj=Line(varargin)


            hObj.LineHandle=matlab.graphics.primitive.world.LineStrip;
            set(hObj.LineHandle,'Internal',true)
            hObj.addNode(hObj.LineHandle);

            hObj.SelectionHandle=matlab.graphics.interactor.ListOfPointsHighlight;
            set(hObj.SelectionHandle,'Internal',true)
            hObj.addNode(hObj.SelectionHandle);

            hObj.Type='line';
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
            if strcmp(hObj.ColorMode,'auto')&&isempty(hObj.ColorData_I)&&~isempty(updatedColor)
                hObj.Color_I=updatedColor;
            end

            vdata=[];
            if hObj.Visible

                shape=hObj.ShapeDataCache;
                cdata=hObj.ColorDataCache;
                if~isempty(cdata)&&(numel(shape)~=numel(cdata))
                    error(message('MATLAB:graphics:geoplot:DataLengthMismatch','ColorData','ShapeData'))
                end


                if isempty(hObj.VertexDataCache)
                    [vdata,sdata,shapeidx]=lineStripData(shape);
                    hObj.VertexDataCache=vdata;
                    hObj.StripDataCache=sdata;
                    hObj.DataIndexCache=shapeidx;
                else
                    vdata=hObj.VertexDataCache;
                    sdata=hObj.StripDataCache;
                    shapeidx=hObj.DataIndexCache;
                end

                if strcmp(hObj.Color_I,'flat')&&~isempty(cdata)




                    ivdata=stripDataToVertexIndices(sdata);
                    vdataDiscrete=vdata(ivdata,:);
                    vdata=vdataDiscrete;
                    sdata=[];
                end

                if strcmp(hObj.Color_I,'none')
                    set(hObj.LineHandle,'Visible_I','off')
                else
                    vIter=matlab.graphics.axis.dataspace.IndexPointsIterator;
                    vIter.Vertices=vdata;
                    vdata=TransformPoints(updateState.DataSpace,...
                    updateState.TransformUnderDataSpace,vIter);
                    set(hObj.LineHandle,'Visible_I','on','VertexData',vdata,...
                    'StripData',sdata,'LineWidth',hObj.LineWidth_I)
                    hgfilter('LineStyleToPrimLineStyle',hObj.LineHandle,hObj.LineStyle_I)

                    colorType='truecolor';
                    if strcmp(hObj.Color_I,'flat')&&~isempty(cdata)

                        colorIter=matlab.graphics.axis.colorspace.IndexColorsIterator;
                        colorIter.Colors=hObj.ColorDataCache(shapeidx);
                        tColors=updateState.ColorSpace.TransformColormappedToTrueColor(colorIter);
                        set(hObj.LineHandle,'ColorBinding_I','discrete','ColorData_I',tColors.Data)


                        nanColors=isnan(colorIter.Colors);
                        if any(nanColors)
                            hObj.LineHandle.ColorData_I(4,nanColors)=uint8(0);
                            colorType='truecoloralpha';
                        end
                    elseif strcmp(hObj.Color_I,'flat')


                        set(hObj.LineHandle,'ColorBinding_I','object')
                        hgfilter('RGBAColorToGeometryPrimitive',hObj.LineHandle,[updatedColor,1])
                    else

                        set(hObj.LineHandle,'ColorBinding_I','object')
                        hgfilter('RGBAColorToGeometryPrimitive',hObj.LineHandle,[hObj.Color_I,1])
                    end
                    set(hObj.LineHandle,'ColorType_I',colorType)
                end
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
            lstrip=matlab.graphics.primitive.world.LineStrip;
            lstrip.Parent=graphic;
            lstrip.VertexData=single([0,1;.5,.5;0,0]);
            hgfilter('LineStyleToPrimLineStyle',lstrip,hObj.LineStyle_I)
            lstrip.LineWidth=hObj.LineWidth_I;
            if strcmp(hObj.Color_I,'flat')
                neutralColor=[.4,.4,.4];
                hgfilter('RGBAColorToGeometryPrimitive',lstrip,[neutralColor,1])
            elseif strcmp(hObj.Color_I,'none')
                hgfilter('RGBAColorToGeometryPrimitive',lstrip,'none')
            else
                hgfilter('RGBAColorToGeometryPrimitive',lstrip,[hObj.Color_I,1])
            end
        end
    end

    methods(Access=protected)
        function groups=getPropertyGroups(hObj)
            suffix=["Data","Variable"];
            dvars{1}='ShapeData';
            dvars{2}=char("Color"+suffix(1+hObj.isDataComingFromDataSource('Color')));
            groups=matlab.mixin.util.PropertyGroup(...
            [dvars,'LineStyle','LineWidth','Color']);
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
                hObj.StripDataCache=[];
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
                mustBeA(dataValue,{'geolineshape','maplineshape'})
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


function ivdata=stripDataToVertexIndices(sdata)


    numVertices=sdata(end)-1;
    connectivity=[(1:numVertices-1)',(2:numVertices)'];
    connectivity(sdata(2:end-1)-1,:)=[];
    ivdata=reshape(connectivity',[1,numel(connectivity)]);
end
