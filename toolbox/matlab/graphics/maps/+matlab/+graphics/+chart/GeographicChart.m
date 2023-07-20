classdef(ConstructOnLoad,Abstract,AllowedSubclasses={...
    ?matlab.graphics.chart.GeographicBubbleChart})...
    GeographicChart<matlab.graphics.chart.internal.SubplotPositionableChartWithAxes






















































    properties(Abstract,Transient,Hidden=true,GetAccess=public,SetAccess=protected,NonCopyable)
Type
    end

    properties(Hidden,Access={?matlab.graphics.chart.Chart,?ChartTestHelper},Transient,NonCopyable)
Axes
    end

    properties
        GridVisible matlab.lang.OnOffSwitchState=true


        Basemap=matlab.graphics.chart.internal.maps.defaultBasemap()
    end

    properties(AffectsObject)
        Title matlab.internal.datatype.matlab.graphics.datatype.NumericOrString=""
        MapLayout(1,1)matlab.graphics.maps.MapLayoutState="normal"
    end

    properties(AffectsObject,AbortSet)
        FontName matlab.internal.datatype.matlab.graphics.datatype.FontName
    end

    properties(Dependent)
MapCenter
ZoomLevel
        ScalebarVisible matlab.lang.OnOffSwitchState=true
    end

    properties(Dependent,AffectsObject)
        FontSize matlab.internal.datatype.matlab.graphics.datatype.Positive
    end

    properties(Hidden)

        FontSizeMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
    end

    properties(Dependent)

LatitudeLimits
LongitudeLimits
    end

    properties(Hidden)

        MapCenter_I=[0,0]
        ZoomLevel_I=1
        MapCenterMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        ZoomLevelMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        LatitudeLimitsRequest=[]
        LongitudeLimitsRequest=[]
    end

    properties(Access=protected,AbortSet)
        ScalebarVisible_I=true
        ScalebarVisibleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        FontSize_I=get(groot,'FactoryGeoaxesFontSize')
    end

    properties(Hidden)


PositionStorage
OuterPositionCache
        LooseInsetCache matlab.graphics.general.UnitPosition
    end

    properties(Dependent,Hidden,Access=protected)
LooseInsetCachePosition
    end

    properties(Transient,Hidden,Access=?tGeographicBubbleChart)
PrintSettingsCache
    end

    properties(Dependent,Hidden)




        GrayscaleTiles=false
    end


    methods
        function obj=GeographicChart()

            ax=matlab.graphics.axis.GeographicAxes();
            set(ax.LongitudeAxis,'LongitudeLabeling',"ewcyclic")
            disableAxesBehavior(ax)
            obj.Axes=ax;
            obj.addNode(ax);
            customizeToolbar(obj)


            obj.FontName=get(groot,'FactoryGeoaxesFontName');


            obj.addDependencyConsumed({'ref_frame','resolution'});



            ax.LatitudeLabel.Interactions=[];
            ax.LongitudeLabel.Interactions=[];




            addlistener(ax.Title,'String','PostSet',...
            @(~,~)set(obj,'Title',ax.Title.String_I));
        end
    end


    methods(Hidden)
        function doUpdate(obj,updateState)

            validateDataProperties(obj)


            layoutValues=matlab.graphics.internal.getSuggestedLayoutValues(obj,updateState);
            if(strcmp(obj.FontSizeMode,'auto'))
                obj.FontSize_I=layoutValues.FontSize;
            end


            units=obj.Units;
            outerPos=obj.OuterPosition_I;


            ax=obj.Axes;
            ax.Units_I=units;
            ax.OuterPosition_I=outerPos;


            if maximizeMap(obj)
                desiredLooseInset=[0,0,0,0];
                setAxesLooseInsetInPoints(obj,desiredLooseInset);
            end


            updateLegends(obj,updateState)


            updateDataObjects(obj)


            enableDefaultInteractivity(ax)


            vp=ax.Camera.Viewport;
            outerPosPixels=matlab.graphics.internal.convertUnits(vp,'pixels',units,outerPos);
            positionConstraint=string(obj.ActivePositionProperty);


            obj.setState(outerPosPixels,...
            "doUpdate",...
            positionConstraint);
        end


        function customizeToolbar(obj)

            [tb,btn]=axtoolbar(obj.Axes,{'stepzoomin','stepzoomout','restoreview'});
            if~isempty(tb)
                tb.HandleVisibility='off';
                set(btn,'HandleVisibility','off')
            end
        end


        function mcodeConstructor(obj,code)

            mcodeConstructor@matlab.graphics.chart.internal.SubplotPositionableChartWithAxes(obj,code)


            propsWithModes={'MapCenter','ZoomLevel','ScalebarVisible','FontSize'};
            for p=1:numel(propsWithModes)

                propName=propsWithModes{p};
                modePropName=[propName,'Mode'];


                if obj.(modePropName)=="auto"

                    ignoreProperty(code,propName);
                end
            end



            if obj.MapLayout=="normal"
                ignoreProperty(code,'MapLayout');
                if obj.GridVisible=="on"
                    ignoreProperty(code,'GridVisible');
                end
            else

                ignoreProperty(code,'GridVisible');
            end
            if obj.Basemap==string(matlab.graphics.chart.internal.maps.defaultBasemap())
                ignoreProperty(code,'Basemap');
            end
            if isequal(obj.FontName,get(groot,'FactoryGeoaxesFontName'))
                ignoreProperty(code,'FontName');
            end



            manualMapCenter=obj.MapCenterMode=="manual";
            manualZoomLevel=obj.ZoomLevelMode=="manual";
            manualMapCenterAndZoomLevel=manualMapCenter&&manualZoomLevel;
            if~isempty(obj.LatitudeLimitsRequest)&&...
                ~isempty(obj.LongitudeLimitsRequest)&&...
                ~manualMapCenterAndZoomLevel
                geolimitsfunction=codegen.codefunction('Name','geolimits');
                latlimarg=codegen.codeargument('Name','latlim',...
                'Value',obj.LatitudeLimitsRequest,...
                'IsParameter',false,'Comment','LatitudeLimits');
                geolimitsfunction.addArgin(latlimarg);
                lonlimarg=codegen.codeargument('Name','lonlim',...
                'Value',obj.LongitudeLimitsRequest,...
                'IsParameter',false,'Comment','LongitudeLimits');
                geolimitsfunction.addArgin(lonlimarg);
                code.addPostConstructorFunction(geolimitsfunction);





                if manualMapCenter

                    objarg=codegen.codeargument('Name','gb','Value',...
                    obj,'IsParameter',true,'Comment','object');
                    addConstructorArgout(code,objarg);


                    setMapCenter=codegen.codefunction('Name','set');
                    setMapCenter.addArgin(objarg);
                    mapCenterName=codegen.codeargument('Value','MapCenter',...
                    'ArgumentType',codegen.ArgumentType.PropertyName);
                    setMapCenter.addArgin(mapCenterName);
                    mapCenterVal=codegen.codeargument('Name','MapCenter',...
                    'Value',obj.MapCenter,...
                    'ArgumentType',codegen.ArgumentType.PropertyValue);
                    setMapCenter.addArgin(mapCenterVal);
                    code.addPostConstructorFunction(setMapCenter);

                    ignoreProperty(code,'MapCenter');
                end
                if manualZoomLevel

                    objarg=codegen.codeargument('Name','gb','Value',...
                    obj,'IsParameter',true,'Comment','object');
                    addConstructorArgout(code,objarg);


                    setZoomLevel=codegen.codefunction('Name','set');
                    setZoomLevel.addArgin(objarg);
                    zoomLevelName=codegen.codeargument('Value','ZoomLevel',...
                    'ArgumentType',codegen.ArgumentType.PropertyName);
                    setZoomLevel.addArgin(zoomLevelName);
                    zoomLevelVal=codegen.codeargument('Name','ZoomLevel',...
                    'Value',obj.ZoomLevel,...
                    'ArgumentType',codegen.ArgumentType.PropertyValue);
                    setZoomLevel.addArgin(zoomLevelVal);
                    code.addPostConstructorFunction(setZoomLevel);

                    ignoreProperty(code,'ZoomLevel');
                end
            end
            ignoreProperty(code,'LatitudeLimits');
            ignoreProperty(code,'LongitudeLimits');
        end
    end


    methods(Access=protected)
        function validateDataProperties(~)

        end

        function updateLegends(~,~)

        end

        function updateDataObjects(~)

        end

        function[latlim,lonlim]=limitsFromData(~)
            latlim=[];
            lonlim=[];
        end

        function updateLegendFontName(~,~)

        end

        function updateLegendFontSize(~,~)

        end
    end


    methods(Hidden)
        function scaleForPrinting(obj,flag,scale)










            switch lower(flag)
            case 'modify'

                settings.DataPropertySettings=cacheDataProperties(obj);


                settings.LatitudeLimits=obj.LatitudeLimits;
                settings.LongitudeLimits=obj.LongitudeLimits;
                settings.ZoomLevel=obj.ZoomLevel;
                settings.ZoomLevelMode=obj.ZoomLevelMode;
                settings.MapCenter=obj.MapCenter;
                settings.MapCenterMode=obj.MapCenterMode;

                settings.Units=obj.Units;
                if strcmpi(obj.PositionConstraint,'outerposition')
                    settings.OuterPosition=obj.OuterPosition;
                else
                    settings.InnerPosition=obj.InnerPosition;
                end
                obj.PrintSettingsCache=settings;



                scopeGuard=onCleanup(@()obj.enableSubplotListeners());
                obj.disableSubplotListeners();
                obj.Units='normalized';
                delete(scopeGuard);




                reader=obj.Axes.BasemapDisplay.TileReader;
                if isprop(reader,'IsPrinting')
                    reader.IsPrinting=true;
                end


                if scale~=1

                    obj.LatitudeLimitsRequest=settings.LatitudeLimits;
                    obj.LongitudeLimitsRequest=settings.LongitudeLimits;
                    obj.MapCenterMode='auto';
                    obj.ZoomLevelMode='auto';
                    scaleDataProperties(obj,settings.DataPropertySettings,scale)
                end

            case 'revert'
                settings=obj.PrintSettingsCache;

                if~isempty(settings)






                    reader=obj.Axes.BasemapDisplay.TileReader;
                    if isprop(reader,'IsPrinting')
                        reader.IsPrinting=false;
                    end


                    obj.LatitudeLimitsRequest=settings.LatitudeLimits;
                    obj.LongitudeLimitsRequest=settings.LongitudeLimits;
                    if strcmp(settings.ZoomLevelMode,'manual')
                        obj.ZoomLevel=settings.ZoomLevel;
                    end
                    if strcmp(settings.MapCenterMode,'manual')
                        obj.MapCenter=settings.MapCenter;
                    end
                    revertDataProperties(obj,settings.DataPropertySettings)



                    scopeGuard=onCleanup(@()obj.enableSubplotListeners());
                    obj.disableSubplotListeners();
                    obj.Units=settings.Units;




                    obj.disableSubplotListeners();
                    if strcmpi(obj.PositionConstraint,'outerposition')
                        obj.OuterPosition=settings.OuterPosition;
                    else
                        obj.InnerPosition=settings.InnerPosition;
                    end
                    delete(scopeGuard);
                end


                obj.PrintSettingsCache=[];
            end
        end
    end


    methods(Access=protected)
        function dataPropertySettings=cacheDataProperties(~)

            dataPropertySettings=[];
        end

        function scaleDataProperties(~,~,~)




        end

        function revertDataProperties(~,~)




        end

        function disableSubplotListeners(obj)
            parent=obj.Parent;
            if isscalar(parent)&&isvalid(parent)
                slm=getappdata(parent,'SubplotListenersManager');
                if~isempty(slm)
                    disable(slm);
                end
            end
        end

        function enableSubplotListeners(obj)
            parent=obj.Parent;
            if isscalar(parent)&&isvalid(parent)
                slm=getappdata(parent,'SubplotListenersManager');
                if~isempty(slm)
                    enable(slm);
                end
            end
        end
    end


    methods

        function set.OuterPositionCache(obj,opc)








            if isfinite(opc.CharacterHeight)
                hAx=obj.Axes;%#ok<MCSUP>
                hAx.Units=opc.Units;
                hAx.OuterPosition=opc.Position;
            end
        end


        function opc=get.OuterPositionCache(obj)







            hAx=obj.Axes;
            opc=matlab.graphics.general.UnitPosition;
            opc.Units=hAx.Units;
            opc.Position=hAx.OuterPosition;

            opc.CharacterHeight=Inf;
        end


        function set.PositionStorage(obj,data)



            if~any(isfield(data,{'PositionConstraint','ActivePositionProperty'}))
                return
            end






            if~isfield(data,'PositionConstraint')
                if strcmpi(data.ActivePositionProperty,'outerposition')
                    data.PositionConstraint='outerposition';
                else
                    data.PositionConstraint='innerposition';
                end
            end

            obj.Axes.Units=data.Units;%#ok<MCSUP>

            if strcmpi(data.PositionConstraint,'outerposition')
                obj.Axes.PositionConstraint=data.PositionConstraint;%#ok<MCSUP>
                obj.Axes.OuterPosition=data.OuterPosition;%#ok<MCSUP>
            else
                obj.Axes.PositionConstraint=data.PositionConstraint;%#ok<MCSUP>
                obj.Axes.Position=data.InnerPosition;%#ok<MCSUP>
            end
        end


        function data=get.PositionStorage(obj)



            data.Units=obj.Axes.Units;
            data.ActivePositionProperty=obj.Axes.ActivePositionProperty;
            data.PositionConstraint=obj.Axes.PositionConstraint;
            data.InnerPosition=obj.Axes.Position;
            data.OuterPosition=obj.Axes.OuterPosition;
        end


        function set.MapLayout(obj,maplayout)
            obj.MapLayout=maplayout;
            ax=obj.Axes;%#ok<MCSUP>
            latruler=ax.LatitudeAxis;
            lonruler=ax.LongitudeAxis;
            if maximizeMap(obj)
                ax.Title.Visible='off';
                latruler.TickValues=[];
                lonruler.TickValues=[];
                latruler.Label.Visible='off';
                lonruler.Label.Visible='off';
            else
                ax.Title.Visible='on';
                latruler.TickValuesMode='auto';
                lonruler.TickValuesMode='auto';
                latruler.Label.Visible='on';
                lonruler.Label.Visible='on';
            end
        end


        function maplayout=get.MapLayout(obj)
            maplayout=char(obj.MapLayout);
        end


        function set.Title(obj,str)
            ax=obj.Axes;%#ok<MCSUP>
            ax.Title.String_I=str;
            obj.Title=ax.Title.String;
        end


        function title=get.Title(obj)
            title=convertStringsToChars(obj.Title);
        end


        function set.Basemap(gb,basemap)
            try
                gb.Axes.Basemap=basemap;%#ok<MCSUP>
            catch e
                throwAsCaller(e)
            end
        end


        function basemap=get.Basemap(obj)
            basemap=obj.Axes.Basemap;
        end


        function set.MapCenter(gb,mapcenter)
            latmax=90;
            validateattributes(mapcenter,{'single','double'},...
            {'real','finite','nonsparse','size',[1,2]},'','MapCenter')

            validateattributes(mapcenter(1),{'single','double'},...
            {'>',-latmax,'<',latmax},'','MapCenter(1)')
            mapcenter=double(mapcenter);
            try
                gb.MapCenter_I=mapcenter;
                gb.MapCenterMode='manual';
                ax=gb.Axes;
                rememberMapCenterInteraction(ax)
            catch e
                throw(e)
            end
        end


        function center=get.MapCenter(gb)
            center=gb.MapCenter_I;
        end


        function set.MapCenterMode(obj,mapCenterMode)
            ax=obj.Axes;%#ok<MCSUP>
            ax.MapCenterMode=mapCenterMode;
        end


        function centermode=get.MapCenterMode(obj)
            ax=obj.Axes;
            centermode=ax.MapCenterMode;
        end


        function set.MapCenter_I(gb,mapcenter)
            ax=gb.Axes;%#ok<MCSUP>
            ax.MapCenter_I=mapcenter;
            gb.MapCenter_I=ax.MapCenter_I;
        end


        function center=get.MapCenter_I(gb)
            ax=gb.Axes;
            center=ax.MapCenter_I;



            lonlim=gb.LongitudeLimits;
            west=lonlim(1);
            east=lonlim(2);
            lon=center(2);
            wlon=lon<west;
            elon=lon>east;
            lon(wlon)=west+mod(lon(wlon)-west,360);
            lon(elon)=east-mod(east-lon(elon),360);
            center(2)=lon;
        end


        function set.ZoomLevel(gb,z)
            validateattributes(z,{'numeric'},...
            {'real','finite','nonnegative','scalar','nonsparse',...
            '>=',0,'<=',25},...
            '','ZoomLevel')
            z=double(z);
            try
                gb.ZoomLevel_I=z;
                gb.ZoomLevelMode='manual';
                ax=gb.Axes;
                rememberZoomLevelInteraction(ax)
            catch e
                throw(e)
            end
        end


        function z=get.ZoomLevel(gb)
            z=gb.ZoomLevel_I;
        end


        function set.ZoomLevelMode(obj,zoomLevelMode)
            ax=obj.Axes;%#ok<MCSUP>
            ax.ZoomLevelMode=zoomLevelMode;
        end


        function zoomLevelMode=get.ZoomLevelMode(obj)
            ax=obj.Axes;
            zoomLevelMode=ax.ZoomLevelMode;
        end


        function set.ZoomLevel_I(gb,z)
            ax=gb.Axes;%#ok<MCSUP>
            ax.ZoomLevel_I=z;
            gb.ZoomLevel_I=ax.ZoomLevel_I;
        end


        function z=get.ZoomLevel_I(gb)
            ax=gb.Axes;
            z=ax.ZoomLevel_I;
        end


        function set.LatitudeLimits(~,varargin)
            error(message('MATLAB:graphics:maps:ReadOnlyLatitudeLimits'))
        end


        function limits=get.LatitudeLimits(gb)
            ax=gb.Axes;
            limits=ax.LatitudeLimits;
        end


        function set.LatitudeLimitsRequest(gb,limits)
            ax=gb.Axes;%#ok<MCSUP>
            ax.LatitudeLimitsRequest=limits;
        end


        function limits=get.LatitudeLimitsRequest(gb)
            ax=gb.Axes;
            limits=ax.LatitudeLimitsRequest;
        end


        function set.LongitudeLimits(~,varargin)
            error(message('MATLAB:graphics:maps:ReadOnlyLongitudeLimits'))
        end


        function limits=get.LongitudeLimits(gb)
            ax=gb.Axes;
            limits=ax.LongitudeLimits;
            if diff(limits)<=360
                limits=matlab.graphics.chart.internal.maps.unwrapLongitudeLimits(limits);
            end
        end


        function set.LongitudeLimitsRequest(gb,limits)
            ax=gb.Axes;%#ok<MCSUP>
            ax.LongitudeLimitsRequest=limits;
        end


        function limits=get.LongitudeLimitsRequest(gb)
            ax=gb.Axes;
            limits=ax.LongitudeLimitsRequest;
        end


        function set.GridVisible(gb,gridVisible)
            try
                tf=matlab.graphics.chart.internal.maps.validateOnOffProperty('GridVisible',gridVisible);
            catch e
                throwAsCaller(e)
            end
            gb.Axes.Grid=tf;%#ok<MCSUP>
            gb.GridVisible=tf;
        end


        function onoff=get.GridVisible(gb)
            tf=gb.GridVisible;
            onoff=char(matlab.lang.OnOffSwitchState(tf));
        end


        function set.ScalebarVisible(gb,scalebarVisible)
            try
                tf=matlab.graphics.chart.internal.maps.validateOnOffProperty(...
                'ScalebarVisible',scalebarVisible);
            catch e
                throwAsCaller(e)
            end
            gb.ScalebarVisible_I=tf;
            gb.ScalebarVisibleMode='manual';
        end


        function onoff=get.ScalebarVisible(gb)
            tf=gb.ScalebarVisible_I;
            onoff=char(matlab.lang.OnOffSwitchState(tf));
        end


        function set.ScalebarVisible_I(gb,tf)
            gb.Axes.Scalebar.Visible=tf;%#ok<MCSUP>
        end


        function tf=get.ScalebarVisible_I(gb)
            tf=gb.Axes.Scalebar.Visible;
        end


        function set.FontName(obj,fontName)

            ax=obj.Axes;%#ok<MCSUP>
            if isscalar(ax)&&isvalid(ax)
                ax.FontName=fontName;
                updateLegendFontName(obj,fontName)
            end
            obj.FontName=fontName;
        end


        function set.FontSize(obj,fontSize)
            obj.FontSizeMode='manual';
            obj.FontSize_I=fontSize;
        end


        function sz=get.FontSize(obj)
            sz=obj.FontSize_I;
        end


        function set.FontSize_I(obj,fontSize)

            ax=obj.Axes;%#ok<MCSUP>
            if isscalar(ax)&&isvalid(ax)
                ax.FontSize=fontSize;
            end
            updateLegendFontSize(obj,fontSize)
            obj.FontSize_I=fontSize;
        end


        function set.GrayscaleTiles(obj,tf)
            obj.Axes.GrayscaleTiles=tf;
        end


        function tf=get.GrayscaleTiles(obj)
            tf=obj.Axes.GrayscaleTiles;
        end

        function set.LooseInsetCachePosition(obj,li)







            lic=obj.LooseInsetCache;
            if any(strcmp(lic.Units,{'pixels','devicepixels'}))
                li=li+[1,1,0,0];
            end
            obj.LooseInsetCache.Position=li;
        end

        function li=get.LooseInsetCachePosition(obj)



            lic=obj.LooseInsetCache;
            li=lic.Position;
            if any(strcmp(lic.Units,{'pixels','devicepixels'}))
                li=li-[1,1,0,0];
            end
        end
    end


    methods(Hidden)
        function[latlim,lonlim]=geographicLimits(obj,varargin)
            ax=obj.Axes;
            try
                [latlimits,lonlimits]=geographicLimits(ax,varargin{:});
            catch e
                throw(e)
            end

            if(nargout>0)||(nargin==1)
                latlim=latlimits;
                lonlim=lonlimits;
            end
        end


        function pan(obj,direction)








            ax=obj.Axes;
            pan(ax,direction)
        end


        function zoomIn(obj,varargin)













            ax=obj.Axes;
            zoomIn(ax,varargin{:})
        end


        function zoomOut(obj,varargin)















            ax=obj.Axes;
            zoomOut(ax,varargin{:})
        end


        function resetplotview(obj,~)




            ax=obj.Axes;
            resetplotview(ax)
        end


        function recenter(obj,xcenter,ycenter)





            ax=obj.Axes;
            recenter(ax,xcenter,ycenter)
        end


        function reset(obj)

            error(message('MATLAB:Chart:UnsupportedConvenienceFunction',...
            'reset',obj.Type));
        end


        function xl=xlim(obj,varargin)%#ok<STOUT>
            msg=message('MATLAB:graphics:maps:UnsupportedLimitsFunction','xlim',obj.Type);
            throwAsCaller(MException('MATLAB:graphics:maps:UnsupportedLimitsFunction',getString(msg)))
        end


        function yl=ylim(obj,varargin)%#ok<STOUT>
            msg=message('MATLAB:graphics:maps:UnsupportedLimitsFunction','ylim',obj.Type);
            throwAsCaller(MException('MATLAB:graphics:maps:UnsupportedLimitsFunction',getString(msg)))
        end



        function hideMapActionsPalette(~)
        end



        function showMapActionsPalette(~)
        end


        function pos=getLegendPixelPosition(~)

            pos=[];
        end
    end


    methods(Access=protected)
        function setAxesLooseInsetInPoints(obj,looseInsetPoints,newDesiredOuterPositionPoints)






            if(nargin<3)
                vpli=getViewPortReferenceFrame(obj);
            else
                vpli=getViewPortReferenceFrame(obj,newDesiredOuterPositionPoints);
            end


            units=obj.Units;
            looseInset=matlab.graphics.chart.Chart.convertDistances(vpli,units,'points',looseInsetPoints);
            ax=obj.Axes;
            ax.LooseInset_I=looseInset;
        end



        function vpli=getViewPortReferenceFrame(obj,newDesiredOuterPositionPoints)

            ax=obj.Axes;
            vp=ax.Camera.Viewport;

            if(nargin>1)
                outerpos=newDesiredOuterPositionPoints;




                outerPosPixels=obj.convertUnits(vp,'devicepixels','Points',outerpos);

            else
                outerpos=obj.OuterPosition_I;




                outerPosPixels=obj.convertUnits(vp,'devicepixels',obj.Units,outerpos);
            end




            vpli=vp;







            vpli.RefFrame=outerPosPixels;
        end


        function tf=maximizeMap(gb)
            tf=(gb.MapLayout=="maximized");
        end
    end
end


function disableAxesBehavior(ax)

    bh=hggetbehavior(ax,'brush');
    bh.Serialize=true;
    bh.Enable=false;









end
