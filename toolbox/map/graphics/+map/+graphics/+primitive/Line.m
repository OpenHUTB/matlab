classdef(Sealed,ConstructOnLoad,UseClassDefaultsOnLoad)Line<map.graphics.globe.Data...
    &matlab.graphics.internal.GraphicsBaseFunctions



    properties(Dependent,AffectsObject,SetObservable)
        Color matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,0]
        LineStyle{mustBeLineStyle}='-'
        LineWidth matlab.internal.datatype.matlab.graphics.datatype.Positive=.5
        Marker{mustBeMarker}='none'
        MarkerSize matlab.internal.datatype.matlab.graphics.datatype.Positive=6


        MarkerIndices matlab.internal.datatype.matlab.graphics.datatype.IndexVector=uint64.empty(0,1)
        LatitudeData{mustBeLatitude}
        LongitudeData{mustBeLongitude}
        HeightData{mustBeHeight}
    end

    properties(Dependent,AffectsObject,SetObservable,NeverAmbiguous)
        HeightReference{mustBeHeightReference}='geoid'
    end


    properties(Dependent)
        SeriesIndex matlab.internal.datatype.matlab.graphics.datatype.PositiveIntegerWithZero
    end

    properties(Hidden,AffectsObject)
        ColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        LineStyleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        LineWidthMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        MarkerMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        MarkerSizeMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'


        MarkerIndicesMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        LatitudeDataMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        LongitudeDataMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        HeightDataMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'


        SeriesIndexMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
    end

    properties(Hidden,AffectsObject,NeverAmbiguous)
        HeightReferenceMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
    end

    properties(Access=private)
        Color_I matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,0]
        LineStyle_I matlab.internal.datatype.matlab.graphics.datatype.LineStyle='-'
        LineWidth_I matlab.internal.datatype.matlab.graphics.datatype.Positive=.5
        Marker_I matlab.internal.datatype.matlab.graphics.datatype.MarkerStyle='none'
        MarkerSize_I matlab.internal.datatype.matlab.graphics.datatype.Positive=6


        MarkerIndices_I matlab.internal.datatype.matlab.graphics.datatype.IndexVector=uint64.empty(0,1)
        HeightReference_I='geoid'

        LatitudeData_I(1,:)=double.empty(0,1)
        LongitudeData_I(1,:)=double.empty(0,1)
        HeightData_I(1,:)=double.empty(0,1)


        SeriesIndex_I matlab.internal.datatype.matlab.graphics.datatype.PositiveIntegerWithZero
    end

    properties(Access=?tHeightReference)
        LatitudeDataCache(:,1)=double.empty(1,0)
        LongitudeDataCache(:,1)=double.empty(1,0)
        HeightDataCache(:,1)=double.empty(1,0)
    end

    properties(Access=private,Dependent)
MaxCoordinateLength
    end

    properties(Access=private,NonCopyable,Transient)
        LineGraphicsID=''
        MarkerGraphicsID=''
LineLocations
MarkerLocations
        DataHasChanged(1,1)logical=true
        MaxCoordinateLength_I(1,1)double=0
    end

    properties(Access=private,Constant)

        MaxNumTerrainValuesPerQuery=500
    end


    methods

        function obj=Line(varargin)
            matlab.graphics.chart.internal.ctorHelper(obj,varargin);
            obj.Type='line';
            obj.addDependencyConsumed({'colororder_linestyleorder','dataspace'});
        end

        function delete(obj)



            if~isempty(obj)
                parent=ancestor(obj,'globe.graphics.GeographicGlobe');
                if~isempty(parent)&&isvalid(parent)&&isprop(parent,'GlobeViewer')
                    gv=parent.GlobeViewer;
                    if~isempty(gv)&&isvalid(gv)
                        if~isempty(obj.LineGraphicsID)
                            remove(gv,{obj.LineGraphicsID});
                        end

                        if~isempty(obj.MarkerGraphicsID)
                            remove(gv,{obj.MarkerGraphicsID});
                        end
                    end
                end
            end
        end

        function set.LatitudeData(obj,data)
            obj.LatitudeData_I=data;
            obj.LatitudeDataMode='manual';
            obj.DataHasChanged=true;
        end

        function data=get.LatitudeData(obj)
            data=obj.LatitudeData_I;
        end

        function set.LongitudeData(obj,data)
            obj.LongitudeData_I=data;
            obj.LongitudeDataMode='manual';
            obj.DataHasChanged=true;
        end

        function data=get.LongitudeData(obj)
            data=obj.LongitudeData_I;
        end

        function set.HeightData(obj,data)
            obj.HeightData_I=data;
            obj.HeightDataMode='manual';
            obj.DataHasChanged=true;
        end

        function data=get.HeightData(obj)
            data=obj.HeightData_I;
        end

        function set.HeightReference(obj,value)
            obj.HeightReference_I=mustBeHeightReference(value);
            obj.HeightReferenceMode='manual';
            obj.DataHasChanged=true;
        end

        function value=get.HeightReference(obj)
            value=obj.HeightReference_I;
        end

        function set.LineStyle(obj,value)
            obj.LineStyle_I=value;
            obj.LineStyleMode='manual';
        end

        function value=get.LineStyle(obj)
            value=obj.LineStyle_I;
        end

        function set.LineWidth(obj,value)
            obj.LineWidth_I=value;
            obj.LineWidthMode='manual';
        end

        function value=get.LineWidth(obj)
            value=obj.LineWidth_I;
        end

        function set.Color(obj,value)
            obj.Color_I=value;
            obj.ColorMode='manual';
        end

        function value=get.Color(obj)
            if strcmpi(obj.ColorMode,'auto')
                forceFullUpdate(obj,'all','Color');
            end
            value=obj.Color_I;
        end

        function set.Marker(obj,value)
            obj.Marker_I=value;
            obj.MarkerMode='manual';
        end

        function value=get.Marker(obj)
            value=obj.Marker_I;
        end

        function set.MarkerSize(obj,value)
            obj.MarkerSize_I=value;
            obj.MarkerSizeMode='manual';
        end

        function value=get.MarkerSize(obj)
            value=obj.MarkerSize_I;
        end



















        function set.MarkerIndices(obj,value)
            len=obj.MaxCoordinateLength;
            if~isempty(len)&&(~isempty(value)&&max(value(:))>len)
                error(message('MATLAB:handle_graphics:Line:MarkerIndexOutOfRange'))
            end

            obj.MarkerIndices_I=value;
            obj.MarkerIndicesMode='manual';
        end

        function value=get.MarkerIndices(obj)
            updateMarkerIndices(obj)
            value=obj.MarkerIndices_I;
        end

        function set.SeriesIndex(obj,value)
            obj.SeriesIndex_I=value;
            obj.SeriesIndexMode='manual';
        end

        function value=get.SeriesIndex(obj)
            value=obj.SeriesIndex_I;
        end

        function len=get.MaxCoordinateLength(obj)
            if obj.DataHasChanged
                lenLat=length(obj.LatitudeData_I);
                lenLon=length(obj.LongitudeData_I);
                lenHeight=length(obj.HeightData_I);
                len=max([lenLat,lenLon,lenHeight]);
                obj.MaxCoordinateLength_I=len;
            else
                len=obj.MaxCoordinateLength_I;
            end
        end
    end

    methods(Hidden)

        function newParent=setParentImpl(obj,newParent)


            if~isempty(newParent)
                if~isa(newParent,'globe.graphics.GeographicGlobe')
                    childType="Line";
                    shortname=regexprep(class(newParent),'.*\.','');
                    err=MException("MATLAB:handle_graphics:exceptions:HandleGraphicsException",...
                    getString(message("MATLAB:HandleGraphics:hgError",childType,shortname)));
                    throwAsCaller(err);
                end
            end


            obj.DataHasChanged=true;
            oldParent=ancestor(obj,'globe.graphics.GeographicGlobe');
            if~isempty(oldParent)
                gv=oldParent.GlobeViewer;
                if~isempty(obj.LineGraphicsID)
                    remove(gv,{obj.LineGraphicsID})
                    obj.LineGraphicsID='';
                end

                if~isempty(obj.MarkerGraphicsID)
                    remove(gv,{obj.MarkerGraphicsID})
                    obj.MarkerGraphicsID='';
                end
            end
        end


        function doUpdate(obj,updateState)




            updateIfEmptyDataProperties(obj)


            validateDataProperties(obj)


            updateColor(obj,updateState)



            updateMarkerIndices(obj)


            parent=ancestor(obj,'globe.graphics.GeographicGlobe');
            if~isempty(parent)&&isvalid(parent)...
                &&isprop(parent,'GlobeViewer')...
                &&~isempty(parent.GlobeViewer)...
                &&isvalid(parent.GlobeViewer)
                plot(obj,updateState)
            end
        end

        function assignSeriesIndex(obj)
            if~isempty(obj.Parent)&&isvalid(obj.Parent)

                obj.SeriesIndex=getNextSeriesIndex(obj.Parent);
            end
        end
    end

    methods(Access=?globe.graphics.GeographicGlobe)


        function[latlim,lonlim]=getDataExtent(obj)
            buffer=.05;
            lat=obj.LatitudeData;
            lon=obj.LongitudeData;
            if~isempty(lat)&&~isempty(lon)
                [latlim,lonlim]=geoquadline(lat,lon);
                [latlim,lonlim]=bufgeoquad(latlim,lonlim,buffer,buffer);
            else
                latlim=[];
                lonlim=[];
            end
        end
    end

    methods(Access=protected,Hidden)
        function groups=getPropertyGroups(obj)%#ok<MANU>
            groups=matlab.mixin.util.PropertyGroup(...
            ["Color";"LineStyle";"LineWidth";...
            "Marker";"MarkerSize";...
            "LatitudeData";"LongitudeData";"HeightData"]);
        end
    end

    methods(Access=private)
        function updateIfEmptyDataProperties(obj)



            dataChangedToEmpty=obj.DataHasChanged&&...
            (isempty(obj.LatitudeData_I)||isempty(obj.LongitudeData_I));
            if dataChangedToEmpty
                parent=ancestor(obj,'globe.graphics.GeographicGlobe');
                if~isempty(parent)
                    gv=parent.GlobeViewer;


                    if~isempty(obj.LineGraphicsID)
                        remove(gv,{obj.LineGraphicsID})
                        obj.LineGraphicsID='';
                    end

                    if~isempty(obj.MarkerGraphicsID)
                        remove(gv,{obj.MarkerGraphicsID})
                        obj.MarkerGraphicsID='';
                    end




                    updateViewExtent(parent)
                end
            end
        end


        function validateDataProperties(obj)
            v=map.graphics.internal.globe.GeographicGlobeDataValidator("properties");
            validateSizeConsistency(v,...
            obj.LatitudeData,obj.LongitudeData,obj.HeightData)
        end


        function color=getColor(obj,updateState)%#ok<INUSD>
            color=[];
        end

        function updateColor(obj,updateState)
            if strcmp(obj.ColorMode,'auto')
                updatedColor=getColor(obj,updateState);
                if~isempty(updatedColor)
                    obj.Color_I=updatedColor;
                else
                    obj.Color_I=getColorFromColorOrder(obj);
                end
            end
        end

        function color=getColorFromColorOrder(obj)




            color=obj.Color_I;
            parent=ancestor(obj,'globe.graphics.GeographicGlobe');
            if obj.SeriesIndex>0&&~isempty(parent)&&isvalid(parent)
                colorOrder=obj.Parent.ColorOrder;
                if~isempty(colorOrder)
                    n=length(colorOrder);
                    seriesIndex=mod(obj.SeriesIndex,n);
                    if seriesIndex==0
                        seriesIndex=n;
                    end
                    color=colorOrder(seriesIndex,:);
                else













                end
            end
        end


        function updateMarkerIndices(obj)
            if strcmpi(obj.MarkerIndicesMode,'auto')
                len=obj.MaxCoordinateLength;
                if~isempty(len)
                    obj.MarkerIndices_I=uint64(1:len);
                end
            end
        end


        function updateTerrainClipping(obj)

            parent=ancestor(obj,'globe.graphics.GeographicGlobe');
            if~isempty(parent)&&isvalid(parent)
                controller=parent.GlobeViewer.Controller;
                if~strcmpi(parent.Terrain,'none')
                    controller.TerrainClipping='on';
                end
            end
        end

        function plot(obj,updateState)


            isNotEmptyData=~isempty(obj.LatitudeData_I)&&~isempty(obj.LongitudeData_I);
            if isNotEmptyData
                if obj.DataHasChanged

                    preprocessData(obj);
                end


                lat=obj.LatitudeDataCache;
                lon=obj.LongitudeDataCache;
                height=obj.HeightDataCache;




                viewRequiresUpdate=obj.DataHasChanged;
                if~all(isnan(lat))
                    updateTerrainClipping(obj)
                    plotLineData(obj,lat,lon,height,updateState)
                    plotMarkerData(obj,lat,lon,height,updateState)

                    if viewRequiresUpdate
                        updateViewExtent(obj.Parent_I)
                    end
                end
            end
            obj.DataHasChanged=false;
        end

        function preprocessData(obj)














            parent=ancestor(obj,'globe.graphics.GeographicGlobe');
            if~isempty(parent)
                lat=double(obj.LatitudeData_I);
                lon=double(obj.LongitudeData_I);
                height=double(obj.HeightData_I);

                if isempty(height)
                    height=zeros(1,length(lat));
                elseif isscalar(height)
                    height(2:length(lat))=height(1);
                end

                latNanIndex=isnan(lat);
                lonNanIndex=isnan(lon);
                heightNanIndex=isnan(height);
                nanIndex=latNanIndex|lonNanIndex|heightNanIndex;
                lat(nanIndex)=NaN;
                lon(nanIndex)=NaN;
                height(nanIndex)=NaN;


                controller=parent.GlobeViewer.Controller;
                heightReference=obj.HeightReference_I;
                terrain=parent.Terrain;
                maxNumPerQuery=obj.MaxNumTerrainValuesPerQuery;

                height=heightReferenceToEllipsoidal(controller,...
                lat,lon,height,heightReference,terrain,maxNumPerQuery);


                obj.LatitudeDataCache=lat;
                obj.LongitudeDataCache=lon;
                obj.HeightDataCache=height;
            end
        end

        function plotLineData(obj,lat,lon,height,updateState)


            parent=ancestor(obj,'globe.graphics.GeographicGlobe');
            if~isempty(parent)
                gv=parent.GlobeViewer;





                isVisible=isequal(obj.Visible_I,matlab.lang.OnOffSwitchState.on);
                lineStyleIsNone=strcmp(obj.LineStyle_I,'none');
                removeGraphics=obj.DataHasChanged||~isVisible||lineStyleIsNone;

                if~isempty(obj.LineGraphicsID)&&removeGraphics
                    remove(gv,{obj.LineGraphicsID})
                    obj.LineGraphicsID='';
                end


                [lat,lon,height]=removeExtraAndTrailingNaN(...
                lat,lon,height);

                if~isempty(lat)&&~isscalar(lat)&&isVisible&&~lineStyleIsNone
                    if isempty(obj.LineGraphicsID)
                        locations=buildLocations(lat,lon,height);
                        obj.LineLocations=locations;

                        id="line_"+string(parent.ChildGraphicsID);
                        id=char(id);
                        obj.LineGraphicsID=id;
                    else
                        locations=obj.LineLocations;
                    end

                    lineWidthPerPoint=updateState.PixelsPerPoint*obj.LineWidth_I;
                    lineCollection(gv,locations,...
                    'Animation','none',...
                    'Color',obj.Color_I,...
                    'Width',lineWidthPerPoint,...
                    'ID',obj.LineGraphicsID);
                end
            end
        end

        function plotMarkerData(obj,lat,lon,height,updateState)


            parent=ancestor(obj,'globe.graphics.GeographicGlobe');
            if~isempty(parent)
                gv=parent.GlobeViewer;
                markerIsNone=strcmpi(obj.Marker_I,'none');
                isManualMode=strcmpi(obj.MarkerIndicesMode,'manual');
                if~isempty(obj.MarkerGraphicsID)&&...
                    (obj.DataHasChanged||markerIsNone||isManualMode)
                    remove(gv,{obj.MarkerGraphicsID})
                    obj.MarkerGraphicsID='';
                end



                markerIndex=obj.MarkerIndices_I;
                len=obj.MaxCoordinateLength;
                if~isempty(len)&&(~isempty(markerIndex)&&max(markerIndex(:))>len)
                    error(message('MATLAB:handle_graphics:Line:MarkerIndexOutOfRange'))
                end

                lat=lat(markerIndex);
                lon=lon(markerIndex);
                height=height(markerIndex);

                nanIndex=isnan(lat);
                lat(nanIndex)=[];
                lon(nanIndex)=[];
                height(nanIndex)=[];

                if~isempty(lat)&&~markerIsNone
                    color=[1,1,1];
                    transparency=0;
                    pixelSize=updateState.PixelsPerPoint*obj.MarkerSize_I;
                    outlineColor=obj.Color_I;
                    outlineWidth=obj.LineWidth_I;
                    outlineTransparency=...
                    double(matlab.lang.OnOffSwitchState(obj.Visible_I));

                    if isempty(obj.MarkerGraphicsID)
                        locations=[lat(:),lon(:),height(:)];
                        obj.MarkerLocations=locations;

                        id="marker_"+string(parent.ChildGraphicsID);
                        id=char(id);
                        obj.MarkerGraphicsID=id;
                        indices=0;
                    else
                        locations=obj.MarkerLocations;

                        indices=markerIndex;
                        if isscalar(indices)

                            indices(2)=indices(1);
                        end
                    end

                    pointCollection(gv,locations,...
                    'Transparency',transparency,...
                    'Color',color,...
                    'PixelSize',pixelSize,...
                    'OutlineColor',outlineColor,...
                    'OutlineTransparency',outlineTransparency,...
                    'OutlineWidth',outlineWidth,...
                    'ID',obj.MarkerGraphicsID,...
                    'Indices',indices);
                end
            end
        end
    end
end

function mustBeLatitude(lat)
    v=map.graphics.internal.globe.GeographicGlobeDataValidator("properties");
    validateLatitude(v,lat);
end

function mustBeLongitude(lon)
    v=map.graphics.internal.globe.GeographicGlobeDataValidator("properties");
    validateLongitude(v,lon);
end

function mustBeHeight(height)
    v=map.graphics.internal.globe.GeographicGlobeDataValidator("properties");
    validateHeight(v,height);
end

function mustBeLineStyle(lineStyle)
    lineStyle=convertCharsToStrings(lineStyle);
    supportedLineSytles=["-","none"];
    if~isstring(lineStyle)||~isscalar(lineStyle)||~any(contains(supportedLineSytles,lineStyle))
        values=sprintf('''%s',supportedLineSytles+"' | ");
        values(end-2:end)='';
        error(message('MATLAB:datatypes:InvalidEnumValueFor',values))
    end
end

function mustBeMarker(marker)
    marker=convertCharsToStrings(marker);
    supportedMarkers=["none","o"];
    if~isstring(marker)||~isscalar(marker)||~any(contains(supportedMarkers,marker))
        values=sprintf('''%s',supportedMarkers+"' | ");
        values(end-2:end)='';
        error(message('MATLAB:datatypes:InvalidEnumValueFor',values))
    end
end

function heightReference=mustBeHeightReference(heightReference)
    heightReference=validatestring(heightReference,{'terrain','geoid','ellipsoid'});
end


function[lat,lon,height]=removeExtraAndTrailingNaN(lat,lon,height)


    [lat,lon,height]=removeExtraNanSeparators(...
    lat,lon,height);
    if~isempty(lat)&&isnan(lat(end))
        lat(end)=[];
        lon(end)=[];
        height(end)=[];
    end
end


function locations=buildLocations(lat,lon,height)



    [first,last]=internal.map.findFirstLastNonNan(lat);


    index=first==last;
    first(index)=[];
    last(index)=[];


    locations=cell(1,length(first));
    for k=1:length(first)
        clat=lat(first(k):last(k));
        clon=lon(first(k):last(k));
        cheight=height(first(k):last(k));
        locations{1,k}=[clat(:),clon(:),cheight(:)];
    end
end


function height=heightReferenceToEllipsoidal(controller,...
    lat,lon,height,heightReference,terrainSource,maxNumPerQuery)



    nanIndex=isnan(lat);
    lat(nanIndex)=0;
    lon(nanIndex)=0;

    switch heightReference
    case 'terrain'
        Z=terrainToEllipsoidal(controller,lat,lon,terrainSource,maxNumPerQuery);
        height=Z(:)+height(:);

    case 'geoid'
        height=terrain.internal.HeightTransformation.orthometricToEllipsoidal(...
        height,lat,lon);

    case 'ellipsoid'

    end
end


function Z=terrainToEllipsoidal(controller,lat,lon,terrainSource,...
    maxNumPerQuery)




    terrainIsGMTED2010=strcmpi(terrainSource,'gmted2010');
    if terrainIsGMTED2010
        msg=message('map:graphics:GettingTerrainData').getString;
        showBusyMessage(controller,msg);
        cleanObj=onCleanup(@()closeBusyMessage(controller));
    end

    model=controller.GlobeModel;
    lat=lat(:);
    lon=lon(:);
    numpts=length(lat);
    try
        if numpts>maxNumPerQuery

            Z=zeros(numpts,1);
            for k=1:maxNumPerQuery:numpts
                endIndex=min(k+maxNumPerQuery-1,numpts);
                Z(k:endIndex,1)=...
                queryTerrainHeightReferencedToEllipsoid(model,...
                lat(k:endIndex,1),lon(k:endIndex,1));
            end
        else
            Z=queryTerrainHeightReferencedToEllipsoid(model,lat,lon);
        end
    catch e
        if~isempty(controller)&&isvalid(controller)
            w=warning('backtrace','off');
            warning(message('map:graphics:UnableToGetTerrainData'))
            warning(w)
        else

            throwAsCaller(e)
        end
        Z=zeros(size(lat));
    end
end

function closeBusyMessage(controller)
    if~isempty(controller)&&isvalid(controller)
        hideBusyMessage(controller)
    end
end
