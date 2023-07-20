classdef(Sealed,ConstructOnLoad,UseClassDefaultsOnLoad)GeographicAxes...
    <matlab.graphics.axis.decorator.GeographicTickLabelFormatHelper...
    &matlab.graphics.axis.GeographicAxesBase






























    properties(Dependent,SetObservable)
        Basemap=matlab.graphics.chart.internal.maps.defaultBasemap()
MapCenter
ZoomLevel
    end

    properties(Dependent)
LatitudeLimits
LongitudeLimits
        LatitudeLabel matlab.graphics.primitive.Text
        LongitudeLabel matlab.graphics.primitive.Text
        AxisColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0.15,0.15,0.15]
    end

    properties(Dependent,AffectsObject,NeverAmbiguous)
        MapCenterMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual
        ZoomLevelMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual
    end

    properties(Hidden,AffectsObject)
        Basemap_I=matlab.graphics.chart.internal.maps.defaultBasemap()
        MapCenter_I=[0,0]
        ZoomLevel_I=0
        LatitudeLimitsRequest=[]
        LongitudeLimitsRequest=[]
        AxisColor_I=[0.15,0.15,0.15];
    end

    properties(Hidden,Transient,AffectsObject)

        CompassDirectionNorth(1,1)string="N"
        CompassDirectionSouth(1,1)string="S"
        CompassDirectionEast(1,1)string="E"
        CompassDirectionWest(1,1)string="W"
    end

    properties(Hidden)
        MapCenterMode_I matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        ZoomLevelMode_I matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        BasemapMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        LatitudeLabelMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        LongitudeLabelMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        AxisColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
    end

    properties(SetAccess=private,Transient,NonCopyable)
CurrentPoint
    end

    properties(Access=private,Constant)
        MinZoomLevel=0
        MaxZoomLevel=25
        PanStepFactor=0.025
        StepsPerZoomLevelDefault=1
        LatitudeString=getString(message('MATLAB:graphics:maps:Latitude'))
        LongitudeString=getString(message('MATLAB:graphics:maps:Longitude'))
    end

    properties(Hidden,Constant)
        StepsPerZoomLevelKeystrokes=2
        StepsPerZoomLevelScrollWheel=8
    end

    properties(Access=private,Transient,NonCopyable)
        BasemapManager matlab.graphics.chart.internal.maps.BasemapManager
Circumference
    end

    properties(Hidden,SetAccess=private,Transient,NonCopyable)
        PanZoomActionUpdatePending=false
        PlotboxInDevicePixels=zeros(1,4)
    end

    properties(Access=private,NonCopyable)
        InteractionHasOccurred=false
        MapCenterBeforeInteraction=[]
        ZoomLevelBeforeInteraction=[]
        LatitudeLimitsRequestBeforeInteraction=[]
        LongitudeLimitsRequestBeforeInteraction=[]
    end

    properties(SetAccess=private,NonCopyable)
        Scalebar(1,1)matlab.graphics.axis.decorator.GeographicScalebar
    end

    properties(Access=private,NonCopyable)

PropertyStorage
    end

    properties(Transient,Hidden)



        GrayscaleTiles logical
    end

    properties(Access=private,Transient)
PrintSettingsCache
    end

    methods
        function obj=GeographicAxes(varargin)
            obj@matlab.graphics.axis.GeographicAxesBase;

            obj.BasemapManager=matlab.graphics.chart.internal.maps.BasemapManager;
            obj.DataSpace_I=matlab.graphics.axis.dataspace.WebMercatorDataSpace;
            piR=pi*obj.DataSpace.Projection.ScaledRadius;
            obj.Circumference=2*piR;
            obj.BasemapDisplay_I=matlab.graphics.internal.maps.BasemapDisplay(...
            -piR,piR,2*piR,-2*piR);



            defaultBasemap=matlab.graphics.chart.internal.maps.defaultBasemap();
            if~strcmp(defaultBasemap,obj.Basemap_I)
                obj.Basemap_I=defaultBasemap;
            end


            matlab.graphics.chart.internal.ctorHelper(obj,varargin);


            obj.BasemapManager.Basemap=obj.Basemap;
            obj.BasemapDisplay.TileReader=obj.BasemapManager.TileReader;


            setupTileReader(obj)

            sb=matlab.graphics.axis.decorator.GeographicScalebar;
            sb.HandleVisibility='off';
            obj.Scalebar=sb;

            setupPrintBehavior(obj)
        end


        function set.Scalebar(obj,scalebar)
            if~isempty(obj.Scalebar)
                oldscalebar=obj.Scalebar;
                oldscalebar.Parent=[];
            end
            addNode(obj.DecorationContainer,scalebar)
            obj.Scalebar=scalebar;
        end


        function set.Basemap(obj,basemap)
            obj.Basemap_I=basemap;
            obj.BasemapMode='manual';
        end


        function basemap=get.Basemap(obj)
            basemap=obj.Basemap_I;
        end


        function set.Basemap_I(obj,basemap)
            basemapmgr=obj.BasemapManager;%#ok<MCSUP>
            try
                basemapmgr.Basemap=basemap;
            catch e
                throwAsCaller(e)
            end
            obj.Basemap_I=basemapmgr.Basemap;
            obj.BasemapDisplay.TileReader=basemapmgr.TileReader;


            setupTileReader(obj)
        end


        function set.MapCenter(obj,mapcenter)
            latmax=90;
            validateattributes(mapcenter,{'single','double'},...
            {'real','finite','nonsparse','size',[1,2]},'','MapCenter')

            validateattributes(mapcenter(1),{'single','double'},...
            {'>',-latmax,'<',latmax},'','MapCenter(1)')
            mapcenter=double(mapcenter);
            obj.MapCenter_I=mapcenter;
            obj.MapCenterMode='manual';
            rememberMapCenterInteraction(obj)
        end


        function center=get.MapCenter(obj)
            forceFullUpdate(obj,'all','MapCenter');
            center=obj.MapCenter_I;
        end


        function set.ZoomLevel(obj,z)
            validateattributes(z,{'numeric'},...
            {'real','finite','nonnegative','scalar','nonsparse',...
            '>=',0,'<=',25},...
            '','ZoomLevel')
            z=double(z);
            obj.ZoomLevel_I=z;
            obj.ZoomLevelMode='manual';
            rememberZoomLevelInteraction(obj)
        end


        function z=get.ZoomLevel(obj)
            forceFullUpdate(obj,'all','ZoomLevel');
            z=obj.ZoomLevel_I;
        end


        function set.MapCenterMode(obj,mapcentermode)
            obj.MapCenterMode_I=mapcentermode;
        end


        function centermode=get.MapCenterMode(obj)
            centermode=obj.MapCenterMode_I;
        end


        function set.ZoomLevelMode(obj,zmode)
            obj.ZoomLevelMode_I=zmode;
        end


        function zmode=get.ZoomLevelMode(obj)
            zmode=obj.ZoomLevelMode_I;
        end


        function set.LatitudeLimits(~,varargin)
            error(message('MATLAB:graphics:maps:ReadOnlyLatitudeLimits'))
        end


        function limits=get.LatitudeLimits(obj)
            forceFullUpdate(obj,'all','LatitudeLimits');
            ds=obj.DataSpace;
            limits=ds.LatitudeLimits;
        end


        function set.LongitudeLimits(~,varargin)
            error(message('MATLAB:graphics:maps:ReadOnlyLongitudeLimits'))
        end


        function limits=get.LongitudeLimits(obj)
            forceFullUpdate(obj,'all','LongitudeLimits');
            ds=obj.DataSpace;
            limits=ds.LongitudeLimits;
        end


        function set.LatitudeLabel(obj,newValue)
            passthroughObj=obj.LatitudeAxis;
            if~isempty(passthroughObj)&&isvalid(passthroughObj)
                passthroughObj.Label=newValue;
                obj.LatitudeLabelMode='manual';
            end
        end


        function value=get.LatitudeLabel(obj)
            passthroughObj=obj.LatitudeAxis;
            if~isempty(passthroughObj)&&isvalid(passthroughObj)
                value=passthroughObj.Label;
            else
                value=[];
            end
        end


        function set.LongitudeLabel(obj,newValue)
            passthroughObj=obj.LongitudeAxis;
            if~isempty(passthroughObj)&&isvalid(passthroughObj)
                passthroughObj.Label=newValue;
                obj.LongitudeLabelMode='manual';
            end
        end


        function value=get.LongitudeLabel(obj)
            passthroughObj=obj.LongitudeAxis;
            if~isempty(passthroughObj)&&isvalid(passthroughObj)
                value=passthroughObj.Label;
            else
                value=[];
            end
        end


        function set.AxisColor(obj,value)
            obj.AxisColor_I=value;
            obj.AxisColorMode='manual';


            ruler=obj.LatitudeAxis;
            if~isempty(ruler)&&isvalid(ruler)
                ruler.Color_I=value;
            end


            ruler=obj.LongitudeAxis;
            if~isempty(ruler)&&isvalid(ruler)
                ruler.Color_I=value;
            end


            scalebar=obj.Scalebar;
            if~isempty(scalebar)&&isvalid(scalebar)
                scalebar.EdgeColor_I=value;
                scalebar.FontColor_I=value;
            end

        end


        function value=get.AxisColor(obj)
            value=obj.AxisColor_I;
        end


        function pt=get.CurrentPoint(obj)



            fig=ancestor(obj,'figure','node');



            pointInPixels=matlab.graphics.interaction.internal.getPointInPixels(...
            fig,fig.CurrentPoint);




            pointInData=matlab.graphics.interaction.internal.calculateIntersectionPoint(...
            pointInPixels,obj);
            pointInData(3)=0;


            pt=repmat(pointInData,2,1);
        end


        function set.PropertyStorage(obj,data)


            obj.Box=data.Box;
        end


        function data=get.PropertyStorage(obj)


            data.Box=obj.Box;
        end


        function set.GrayscaleTiles(obj,tf)
            obj.BasemapDisplay.GrayscaleTiles=tf;
        end


        function tf=get.GrayscaleTiles(obj)
            tf=obj.BasemapDisplay.GrayscaleTiles;
        end


        function tf=prepareForPlot(obj)





            basemap=obj.Basemap_I;
            basemapMode=obj.BasemapMode;
            cla(obj,"reset")
            if strcmp(basemapMode,"manual")




                obj.Basemap=basemap;
            end
            tf=false;
        end
    end


    methods(Access=protected,Hidden)
        function groups=getPropertyGroups(~)

            props={'Basemap','Position','Units'};
            groups=matlab.mixin.util.PropertyGroup(props);
        end


        function setTickLabelFormatFollowup(obj)


            fmt=obj.TickLabelFormat_I;


            ruler=obj.LatitudeAxis;
            if~isempty(ruler)&&isvalid(ruler)
                ruler.TickLabelFormat_I=fmt;
            end


            ruler=obj.LongitudeAxis;
            if~isempty(ruler)&&isvalid(ruler)
                ruler.TickLabelFormat_I=fmt;
            end
        end


        function tf=requiresServerSideRendering(obj)
            isMOTWFlag=mls.internal.feature('graphicsAndGuis','status');
            if strcmp(isMOTWFlag,'on')
                tf=true;
            else
                tf=false;
            end
        end
    end


    methods(Hidden)
        function constructRulersHelper(obj)
            if~isa(obj.LatitudeAxis,'matlab.graphics.axis.decorator.GeographicRuler')
                delete(obj.LatitudeAxis)
                latitudeRuler=matlab.graphics.axis.decorator.GeographicRuler;
                obj.LatitudeAxis_I=latitudeRuler;
            end

            if~isa(obj.LongitudeAxis,'matlab.graphics.axis.decorator.GeographicRuler')
                delete(obj.LongitudeAxis)
                longitudeRuler=matlab.graphics.axis.decorator.GeographicRuler;
                obj.LongitudeAxis_I=longitudeRuler;
            end
        end


        function doSetupHelper(obj)



            obj.Type='geoaxes';
            obj.Box='on';
            obj.LatitudeAxis.Label.String=obj.LatitudeString;
            obj.LongitudeAxis.Label.String=obj.LongitudeString;

            latitudeRuler=obj.LatitudeAxis;
            if~isempty(latitudeRuler)&&isvalid(latitudeRuler)
                latitudeRuler.Coordinate="latitude";
                latitudeRuler.FirstCrossoverAxis_I=1;
                latitudeRuler.FirstCrossoverValue_I=-Inf;
                latitudeRuler.TickDirection_I=obj.TickDir;
                latitudeRuler.LineWidth_I=0.5;
            end

            longitudeRuler=obj.LongitudeAxis;
            if~isempty(longitudeRuler)&&isvalid(longitudeRuler)
                longitudeRuler.Coordinate="longitude";
                longitudeRuler.FirstCrossoverAxis_I=0;
                longitudeRuler.FirstCrossoverValue_I=-Inf;
                longitudeRuler.TickDirection_I=obj.TickDir;
                longitudeRuler.LineWidth_I=0.5;
            end
        end


        function doFanoutHelper(obj,propName,honorMode)
            if strcmp(propName,'FontSize')



                if~honorMode
                    obj.Scalebar.FontSizeMode='auto';
                end

                if strcmp(obj.Scalebar.FontSizeMode,'auto')
                    obj.Scalebar.FontSize_I=obj.FontSize_I*0.8;
                end

                if isprop(obj.BasemapDisplay,'BasemapAttributionText')
                    obj.BasemapDisplay.BasemapAttributionText.FontSize=obj.FontSize_I;
                end
            end
        end


        function doUpdateHelper(obj,~,plotboxInDevicePixels)








            updateCenterAndZoom(obj,plotboxInDevicePixels)
            updateDataSpaceLimits(obj,plotboxInDevicePixels)


            obj.PlotboxInDevicePixels=plotboxInDevicePixels;


            matlab.graphics.interaction.internal.UnifiedAxesInteractions.createDefaultInteractions(obj,true,1)


            latitudeRuler=obj.LatitudeAxis;
            longitudeRuler=obj.LongitudeAxis;
            if latitudeRuler.PositiveCompassDirection~=obj.CompassDirectionNorth
                latitudeRuler.PositiveCompassDirection=obj.CompassDirectionNorth;
            end
            if latitudeRuler.NegativeCompassDirection~=obj.CompassDirectionSouth
                latitudeRuler.NegativeCompassDirection=obj.CompassDirectionSouth;
            end
            if longitudeRuler.PositiveCompassDirection~=obj.CompassDirectionEast
                longitudeRuler.PositiveCompassDirection=obj.CompassDirectionEast;
            end
            if longitudeRuler.NegativeCompassDirection~=obj.CompassDirectionWest
                longitudeRuler.NegativeCompassDirection=obj.CompassDirectionWest;
            end
        end


        function doLayoutHelper(obj,~,plotboxInDevicePixels)




            if plotboxInDevicePixels(3)>0&&plotboxInDevicePixels(4)>0...
                &&any(abs(plotboxInDevicePixels-obj.PlotboxInDevicePixels)>1)
                updateCenterAndZoom(obj,plotboxInDevicePixels)
                updateDataSpaceLimits(obj,plotboxInDevicePixels)
                obj.PlotboxInDevicePixels=plotboxInDevicePixels;
            end


            basemapdisp=obj.BasemapDisplay;
            basemapdisp.TileZoomLevel=computeTileZoom(...
            obj.ZoomLevel_I,basemapdisp.TileSetMaxZoomLevel);
        end


        function computeLayoutInfoHelper(obj,plotboxInDevicePixels)
            updateCenterAndZoom(obj,plotboxInDevicePixels)
            updateDataSpaceLimits(obj,plotboxInDevicePixels)
        end


        function ignore=mcodeIgnoreHandle(~,~)
            ignore=true;
        end
    end


    methods(Hidden,Access={?matlab.graphics.mixin.internal.Copyable,?matlab.graphics.internal.CopyContext})
        function copiedObject=copyElement(obj)

            copiedObject=copyElement@matlab.graphics.mixin.internal.Copyable(obj);


            oldScalebar=obj.Scalebar;
            p=properties(oldScalebar);
            for iter=1:length(p)
                prop=p{iter};
                modeprop=prop+"Mode";
                if isprop(oldScalebar,modeprop)&&oldScalebar.(modeprop)=="manual"


                    newScalebar=copiedObject.Scalebar;
                    newScalebar.(prop)=oldScalebar.(prop);
                elseif(strcmp(prop,"EdgeColor")||strcmp(prop,"FontColor"))...
                    &&obj.AxisColorMode=="manual"


                    internalprop=prop+"_I";
                    newScalebar=copiedObject.Scalebar;
                    newScalebar.(internalprop)=oldScalebar.(internalprop);
                end
            end
        end
    end


    methods(Hidden)
        function[latlim,lonlim]=geographicLimits(obj,latlimreq,lonlimreq)
            switch(nargin)
            case 1





            case 2
                mode=latlimreq;
                try
                    mode=validatestring(mode,["auto","manual"],'','geolimits');
                catch e
                    throwAsCaller(e)
                end

                switch mode
                case "auto"
                    obj.LatitudeLimitsRequest=[];
                    obj.LongitudeLimitsRequest=[];
                case "manual"
                    obj.LatitudeLimitsRequest=obj.LatitudeLimits;
                    obj.LongitudeLimitsRequest=obj.LongitudeLimits;
                end
                obj.MapCenterMode='auto';
                obj.ZoomLevelMode='auto';

            case 3
                validateattributes(latlimreq,{'double','single'},{'real',...
                'finite','>=',-90,'<=',90,'size',[1,2],'nondecreasing'},'','LATLIM')
                validateattributes(lonlimreq,{'double','single'},...
                {'real','finite','size',[1,2]},'','LONLIM')

                if diff(lonlimreq<=0)
                    lonlimreq=matlab.graphics.chart.internal.maps.unwrapLongitudeLimits(lonlimreq);
                end

                obj.LatitudeLimitsRequest=double(latlimreq);
                obj.LongitudeLimitsRequest=double(lonlimreq);

                obj.MapCenterMode='auto';
                obj.ZoomLevelMode='auto';
            end

            if~obj.InteractionHasOccurred
                if nargin>1



                    obj.MapCenterBeforeInteraction=[];
                    obj.ZoomLevelBeforeInteraction=[];
                end




                obj.LatitudeLimitsRequestBeforeInteraction=obj.LatitudeLimitsRequest;
                obj.LongitudeLimitsRequestBeforeInteraction=obj.LongitudeLimitsRequest;
            end

            if(nargout>0)||(nargin==1)


                latlim=obj.LatitudeLimits;
                lonlim=obj.LongitudeLimits;
            end
        end


        function pan(obj,direction)







            stepfactor=obj.PanStepFactor;
            ds=obj.DataSpace;
            [xCenterInWebMercator,yCenterInWebMercator]=xycenter(obj);
            switch direction
            case "west"
                xextent=diff(ds.XMapLimits);
                dx=stepfactor*xextent;
                xCenterInWebMercator=xCenterInWebMercator-dx;
            case "east"
                xextent=diff(ds.XMapLimits);
                dx=stepfactor*xextent;
                xCenterInWebMercator=xCenterInWebMercator+dx;
            case "north"
                yextent=diff(ds.YMapLimits);
                dy=stepfactor*yextent;
                yCenterInWebMercator=yCenterInWebMercator+dy;
            case "south"
                yextent=diff(ds.YMapLimits);
                dy=stepfactor*yextent;
                yCenterInWebMercator=yCenterInWebMercator-dy;
            end
            recenter(obj,xCenterInWebMercator,yCenterInWebMercator)
        end


        function recenter(obj,xcenter,ycenter)








            rememberCenterAndZoomBeforeInteraction(obj)
            obj.MapCenterMode_I='auto';
            plotboxInDevicePixels=getPlotbox(obj,'devicepixels');
            [xcenter,ycenter]=constrainXYCenter(obj,xcenter,ycenter);
            ycenter=minimizeEmptySpace(...
            obj,ycenter,obj.ZoomLevel_I,plotboxInDevicePixels);
            setLimitsFromXYCenterAndZoom(obj,xcenter,ycenter,obj.ZoomLevel_I)
        end


        function zoomIn(obj,varargin)













            levelStepFcn=@(stepsPerLevel)nextZoomStepUp(obj,stepsPerLevel);
            modifyZoomLevel(obj,levelStepFcn,varargin{:})
        end


        function zoomOut(obj,varargin)















            levelStepFcn=@(stepsPerLevel)nextZoomStepDown(obj,stepsPerLevel);
            modifyZoomLevel(obj,levelStepFcn,varargin{:})
        end


        function resetplotview(obj,~)







            if~isempty(obj.LatitudeLimitsRequestBeforeInteraction)
                obj.LatitudeLimitsRequest=obj.LatitudeLimitsRequestBeforeInteraction;
            else
                obj.LatitudeLimitsRequest=[];
            end

            if~isempty(obj.LongitudeLimitsRequestBeforeInteraction)
                obj.LongitudeLimitsRequest=obj.LongitudeLimitsRequestBeforeInteraction;
            else
                obj.LongitudeLimitsRequest=[];
            end

            if~isempty(obj.MapCenterBeforeInteraction)

                obj.MapCenter_I=obj.MapCenterBeforeInteraction;
                obj.MapCenterMode='manual';
            else
                obj.MapCenterMode='auto';
            end

            if~isempty(obj.ZoomLevelBeforeInteraction)

                obj.ZoomLevel_I=obj.ZoomLevelBeforeInteraction;
                obj.ZoomLevelMode='manual';
            else
                obj.ZoomLevelMode='auto';
            end
        end
    end


    methods(Access=private)
        function rememberCenterAndZoomBeforeInteraction(obj)


            if~obj.InteractionHasOccurred
                obj.InteractionHasOccurred=true;

                if obj.MapCenterMode=="manual"
                    obj.MapCenterBeforeInteraction=obj.MapCenter_I;
                end

                if obj.ZoomLevelMode=="manual"
                    obj.ZoomLevelBeforeInteraction=obj.ZoomLevel_I;
                end


                addlistener(obj,'ClaReset',@(o,e)set(o,...
                'InteractionHasOccurred',false,...
                'MapCenterBeforeInteraction',[],...
                'ZoomLevelBeforeInteraction',[],...
                'LatitudeLimitsRequestBeforeInteraction',[],...
                'LongitudeLimitsRequestBeforeInteraction',[]));
            end
        end
    end


    methods(Access=private)

        function modifyZoomLevel(obj,zoomStepFcn,stepsPerLevel,xcenter,ycenter)












            if nargin<3
                stepsPerLevel=obj.StepsPerZoomLevelDefault;
            end

            if nargin<4

                [xcenter,ycenter]=xycenter(obj);
            elseif nargin>4

                obj.MapCenterMode_I='auto';
            elseif nargin==4

                try
                    narginchk(5,5)
                catch e




                    throwAsCaller(e)
                end
            end

            rememberCenterAndZoomBeforeInteraction(obj)
            obj.ZoomLevelMode_I='auto';
            zoomLevel=zoomStepFcn(stepsPerLevel);

            if zoomLevel~=obj.ZoomLevel_I


                plotboxInDevicePixels=getPlotbox(obj,'devicepixels');
                if obj.MapCenterMode=="auto"

                    [xcenter,ycenter]=constrainXYCenter(obj,xcenter,ycenter);
                    [adjustedYCenter,adjustedZoomLevel]=minimizeEmptySpace(...
                    obj,ycenter,zoomLevel,plotboxInDevicePixels);
                    if adjustedZoomLevel>zoomLevel






                        xcenter=xycenter(obj);
                    end
                    zoomLevel=adjustedZoomLevel;
                    ycenter=adjustedYCenter;
                else

                    [~,adjustedZoomLevel]=minimizeEmptySpace(...
                    obj,ycenter,zoomLevel,plotboxInDevicePixels);
                    zoomLevel=adjustedZoomLevel;
                end
                setLimitsFromXYCenterAndZoom(obj,xcenter,ycenter,zoomLevel)
            end
        end


        function setLimitsFromXYCenterAndZoom(obj,xcenter,ycenter,zoomLevel)









            plotboxInDevicePixels=getPlotbox(obj,'devicepixels');
            scale=scaleFromZoomLevel(obj,zoomLevel);
            [xlimits,ylimits]=limitsFromCenterAndScale(...
            obj,xcenter,ycenter,scale,plotboxInDevicePixels);
            [latlim,lonlim]=projinv(obj,xlimits,ylimits);
            [latcenter,loncenter]=projinv(obj,xcenter,ycenter);
            obj.LatitudeLimitsRequest=latlim;
            obj.LongitudeLimitsRequest=lonlim;
            obj.MapCenter_I=[latcenter,loncenter];
            obj.ZoomLevel_I=zoomLevel;
            obj.PanZoomActionUpdatePending=true;
        end


        function updateDataSpaceLimits(obj,plotboxInDevicePixels)


            devicePixelsPerWebMercatorXY=scaleFromZoomLevel(obj,obj.ZoomLevel_I);
            plotboxWidthInWebMercatorX=plotboxInDevicePixels(3)/devicePixelsPerWebMercatorXY;
            plotboxHeightInWebMercatorY=plotboxInDevicePixels(4)/devicePixelsPerWebMercatorXY;
            [xcenter,ycenter]=xycenter(obj);
            ds=obj.DataSpace;
            ds.XMapLimits=xcenter+[-0.5,0.5]*plotboxWidthInWebMercatorX;
            ds.YMapLimits=ycenter+[-0.5,0.5]*plotboxHeightInWebMercatorY;
        end


        function updateCenterAndZoom(obj,plotboxInDevicePixels)





            computeFromLimits=~(obj.PanZoomActionUpdatePending)...
            &&(strcmp(obj.MapCenterMode,'auto')||strcmp(obj.ZoomLevelMode,'auto'));
            if computeFromLimits
                latlim=obj.LatitudeLimitsRequest;
                lonlim=obj.LongitudeLimitsRequest;
                if isempty(latlim)||isempty(lonlim)
                    [latlimdata,lonlimdata]=limitsFromData(obj);
                    if isempty(latlim)
                        latlim=latlimdata;
                    end
                    if isempty(lonlim)
                        lonlim=lonlimdata;
                    end
                end

                if isempty(latlim)||isempty(lonlim)
                    [latlimdef,lonlimdef]=defaultLimits(obj);
                    if isempty(latlim)
                        latlim=latlimdef;
                    end
                    if isempty(lonlim)
                        lonlim=lonlimdef;
                    end
                    [mapcenter,zoom]=fitlimits(obj,latlim,lonlim,plotboxInDevicePixels);
                else
                    if diff(latlim)==0
                        latlim=singlePointLatitudeLimits(obj,latlim(1));
                    end
                    [mapcenter,zoom]=fitlimits(obj,latlim,lonlim,plotboxInDevicePixels);
                    if diff(lonlim)==0





                        mapcenter(2)=mean(lonlim);
                    end
                end

                if strcmp(obj.MapCenterMode,'manual')

                    mapcenter=obj.MapCenter_I;
                end

                if strcmp(obj.ZoomLevelMode,'manual')

                    zoom=obj.ZoomLevel_I;
                end
            else


                mapcenter=obj.MapCenter_I;
                zoom=obj.ZoomLevel_I;
            end
            obj.PanZoomActionUpdatePending=false;
            obj.MapCenter_I=mapcenter;
            obj.ZoomLevel_I=zoom;
        end
    end


    methods(Access=private)

        function[latlim,lonlim]=defaultLimits(obj)
            maxlat=obj.DataSpace.Projection.MaxLatitude;
            latlim=[-maxlat,maxlat];
            lonlim=[-180,180];
        end


        function[xCenterInWebMercator,yCenterInWebMercator]=xycenter(obj)

            mapcenter=obj.MapCenter_I;
            [xCenterInWebMercator,yCenterInWebMercator]...
            =projfwd(obj,mapcenter(1),mapcenter(2));
        end


        function[mapcenter,zoom]=fitlimits(obj,...
            latlimreq,lonlimreq,plotboxInDevicePixels)










            [xCenterInWebMercator,zlon]=centerAndZoomFromLongitudeLimits(obj,lonlimreq,plotboxInDevicePixels(3));
            [yCenterInWebMercator,zlat]=centerAndZoomFromLatitudeLimits(obj,latlimreq,plotboxInDevicePixels(4));
            zoom=max(obj.MinZoomLevel,min(obj.MaxZoomLevel,min([zlon,zlat])));
            [yCenterInWebMercator,zoom]=minimizeEmptySpace(obj,yCenterInWebMercator,zoom,plotboxInDevicePixels);
            [centerlat,centerlon]=projinv(obj,xCenterInWebMercator,yCenterInWebMercator);
            mapcenter=[centerlat,centerlon];
        end


        function[yCenterInWebMercator,z]=centerAndZoomFromLatitudeLimits(obj,...
            latlim,plotboxHeightInDevicePixels)
            ylimits=lat2y(obj,latlim);
            inflim=isinf(ylimits);
            ylimits(inflim)=sign(ylimits(inflim))*realmax;
            yCenterInWebMercator=(ylimits(1)+ylimits(2))/2;
            ymax=obj.Circumference/2;
            yCenterInWebMercator=max(-ymax,min(ymax,yCenterInWebMercator));
            devicePixelsPerDataY=plotboxHeightInDevicePixels/diff(ylimits);
            z=targetZoomLevel(obj,devicePixelsPerDataY);
        end


        function[xCenterInWebMercator,z]=centerAndZoomFromLongitudeLimits(obj,...
            lonlim,plotboxWidthInDevicePixels)
            if diff(lonlim)<=0
                lonlim=matlab.graphics.chart.internal.maps.unwrapLongitudeLimits(lonlim);
            end
            xlimits=lon2x(obj,lonlim);
            xCenterInWebMercator=(xlimits(1)+xlimits(2))/2;




            devicePixelsPerDataX=plotboxWidthInDevicePixels/diff(xlimits);
            z=targetZoomLevel(obj,devicePixelsPerDataX);
        end


        function[yCenterInWebMercator,zoom]=minimizeEmptySpace(obj,...
            yCenterInWebMercator,zoom,plotboxInDevicePixels)





            devicePixelsPerDataXY=scaleFromZoomLevel(obj,zoom);
            [xLimitsInWebMercator,yLimitsInWebMercator]=limitsFromCenterAndScale(...
            obj,0,yCenterInWebMercator,devicePixelsPerDataXY,plotboxInDevicePixels);
            ymax=obj.Circumference/2;
            dylim=diff(yLimitsInWebMercator);
            if dylim>obj.Circumference

                yCenterInWebMercator=0;
                dxlim=diff(xLimitsInWebMercator);
                if dxlim>obj.Circumference


                    zoom=maxZoomForIncludingFullMap(obj,plotboxInDevicePixels);
                end
            elseif yLimitsInWebMercator(1)<-ymax

                yCenterInWebMercator=-ymax+dylim/2;
            elseif yLimitsInWebMercator(2)>ymax

                yCenterInWebMercator=ymax-dylim/2;
            end
        end


        function zoom=maxZoomForIncludingFullMap(obj,plotboxInDevicePixels)






            xscale=plotboxInDevicePixels(3)/obj.Circumference;
            yscale=plotboxInDevicePixels(4)/obj.Circumference;
            scale=min(xscale,yscale);
            N=pixelsPerTileDimension(obj);
            zoom=log2(scale*obj.Circumference/N);
        end


        function[xcenter,ycenter]=constrainXYCenter(obj,xcenter,ycenter)





            maxCenterY=obj.Circumference/2;
            ycenter=max(-maxCenterY,min(maxCenterY,ycenter));



        end


        function[xLimitsInWebMercator,yLimitsInWebMercator]=limitsFromCenterAndScale(...
            ~,xCenterInWebMercator,yCenterInWebMercator,devicePixelsPerDataXY,plotboxInDevicePixels)


            plotboxWidthInDataX=plotboxInDevicePixels(3)/devicePixelsPerDataXY;
            plotboxHeightInDataY=plotboxInDevicePixels(4)/devicePixelsPerDataXY;
            xLimitsInWebMercator=xCenterInWebMercator+[-0.5,0.5]*plotboxWidthInDataX;
            yLimitsInWebMercator=yCenterInWebMercator+[-0.5,0.5]*plotboxHeightInDataY;
            if diff(xLimitsInWebMercator)<=0||diff(yLimitsInWebMercator)<=0
                xLimitsInWebMercator=[];
                yLimitsInWebMercator=[];
            end
        end


        function scale=scaleFromZoomLevel(obj,zoom)

            N=pixelsPerTileDimension(obj);
            scale=(N*2^zoom)/obj.Circumference;
        end


        function z=targetZoomLevel(obj,devicePixelsPerDataXY)

            N=pixelsPerTileDimension(obj);
            z=log2(obj.Circumference*devicePixelsPerDataXY/N);
        end


        function z=nextZoomStepUp(obj,stepsPerLevel)



            z=obj.ZoomLevel_I;
            sz=stepsPerLevel*z;

            z=round(sz+1)/stepsPerLevel;

            z=min(z,obj.MaxZoomLevel);
        end


        function z=nextZoomStepDown(obj,stepsPerLevel)



            z=obj.ZoomLevel_I;
            sz=stepsPerLevel*z;

            z=round(sz-1)/stepsPerLevel;

            z=max(z,obj.MinZoomLevel);
        end
    end


    methods(Access=private)

        function[xWebMercator,yWebMercator]=projfwd(obj,lat,lon)
            ds=obj.DataSpace;
            [xWebMercator,yWebMercator]=projfwd(ds.Projection,lat,lon);
        end


        function[lat,lon]=projinv(obj,xWebMercator,yWebMercator)
            ds=obj.DataSpace;
            [lat,lon]=projinv(ds.Projection,xWebMercator,yWebMercator);
        end


        function xWebMercator=lon2x(obj,lon)
            ds=obj.DataSpace;
            xWebMercator=lon2x(ds.Projection,lon);
        end


        function yWebMercator=lat2y(obj,lat)
            ds=obj.DataSpace;
            yWebMercator=lat2y(ds.Projection,lat);
        end


        function N=pixelsPerTileDimension(obj)
            N=obj.BasemapManager.PixelsPerTileDimension;
        end
    end


    methods(Access=private)
        function setupTileReader(obj)



            reader=obj.BasemapDisplay.TileReader;
            if~isempty(reader)&&isprop(reader,'IsPrinting')
                hfig=ancestor(obj.Parent_I,'figure','node');
                if~isempty(hfig)&&isvalid(hfig)
                    isLiveEditor=matlab.internal.editor.figure.FigureUtils.isEditorEmbeddedFigure(hfig);
                    reader.IsPrinting=isLiveEditor;
                    obj.BasemapDisplay.TileReader=reader;
                end
            end
        end


        function setupPrintBehavior(obj)



            addBehaviorProp(obj)
            hBehavior=hggetbehavior(obj,'print');
            hBehavior.PrePrintCallback=@(obj,callbackName)printEvent(obj,callbackName);
            hBehavior.PostPrintCallback=@(obj,callbackName)printEvent(obj,callbackName);
        end


        function printEvent(obj,callbackName)

            switch callbackName
            case 'PrePrintCallback'




                settingsCache.LatitudeLimits=obj.LatitudeLimits;
                settingsCache.LongitudeLimits=obj.LongitudeLimits;
                settingsCache.ZoomLevel=obj.ZoomLevel;
                settingsCache.ZoomLevelMode=obj.ZoomLevelMode;
                settingsCache.MapCenter=obj.MapCenter;
                settingsCache.MapCenterMode=obj.MapCenterMode;
                obj.PrintSettingsCache=settingsCache;




                reader=obj.BasemapDisplay.TileReader;
                if isprop(reader,'IsPrinting')
                    reader.IsPrinting=true;
                end





                basemapTextObj=obj.BasemapDisplay.BasemapAttributionText;
                if isprop(basemapTextObj,'IsPrinting')
                    basemapTextObj.IsPrinting=true;
                end


                obj.MapCenterMode='auto';
                obj.ZoomLevelMode='auto';
                obj.LatitudeLimitsRequest=settingsCache.LatitudeLimits;
                obj.LongitudeLimitsRequest=settingsCache.LongitudeLimits;

            case 'PostPrintCallback'



                settingsCache=obj.PrintSettingsCache;
                if~isempty(settingsCache)



                    reader=obj.BasemapDisplay.TileReader;
                    if isprop(reader,'IsPrinting')
                        reader.IsPrinting=false;
                    end




                    basemapTextObj=obj.BasemapDisplay.BasemapAttributionText;
                    if isprop(basemapTextObj,'IsPrinting')
                        basemapTextObj.IsPrinting=false;
                    end


                    obj.LatitudeLimitsRequest=settingsCache.LatitudeLimits;
                    obj.LongitudeLimitsRequest=settingsCache.LongitudeLimits;
                    if strcmp(settingsCache.ZoomLevelMode,'manual')
                        obj.ZoomLevel=settingsCache.ZoomLevel;
                    end
                    if strcmp(settingsCache.MapCenterMode,'manual')
                        obj.MapCenter=settingsCache.MapCenter;
                    end
                end
                obj.PrintSettingsCache=[];
            end
        end
    end


    methods(Access=private)
        function addBehaviorProp(obj)
            behaviorProp=findprop(obj,'Behavior');
            if isempty(behaviorProp)
                behaviorProp=addprop(obj,'Behavior');
                behaviorProp.Hidden=true;
                behaviorProp.Transient=true;
            end
        end
    end


    methods(Access=private)
        function[latlim,lonlim]=limitsFromData(obj)



            latlim=[];
            lonlim=[];
            c=obj.Children;
            if~isempty(c)
                latmin=90;
                latmax=-90;
                lonmin=Inf;
                lonmax=-Inf;

                for k=1:length(c)
                    try

                        E=double(getXYZDataExtents(c(k),[],[]));
                        latmin=min(latmin,E(1,1));
                        latmax=max(latmax,E(1,4));
                        lonmin=min(lonmin,E(2,1));
                        lonmax=max(lonmax,E(2,4));
                    catch
                        try %#ok<TRYNC>

                            lat=double(c(k).LatitudeData);
                            lon=double(c(k).LongitudeData);
                            if~isempty(lat)&&~isempty(lon)

                                latmin=min(latmin,min(lat(:)));
                                latmax=max(latmax,max(lat(:)));
                                lonmin=min(lonmin,min(lon(:)));
                                lonmax=max(lonmax,max(lon(:)));
                            end
                        end
                    end
                end

                if isfinite(lonmin)&&isfinite(lonmax)&&(latmin<=latmax)
                    bufferInPercent=5;
                    f=1+bufferInPercent/100;
                    half=f*(latmax-latmin)/2;
                    latlim=[-half,half]+(latmin+latmax)/2;
                    latlim(1)=max(latlim(1),-90);
                    latlim(2)=min(latlim(2),90);
                    half=f*(lonmax-lonmin)/2;
                    lonlim=[-half,half]+(lonmin+lonmax)/2;
                end
            end
        end


        function latlim=singlePointLatitudeLimits(obj,lat)




            proj=obj.DataSpace.Projection;
            y=lat2y(proj,lat);
            dy=proj.Circumference/24;
            latlim=y2lat(proj,y+[-dy,dy]);
            maxlat=proj.MaxLatitude;
            latlim=max(-maxlat,min(maxlat,latlim));
        end
    end


    methods(Hidden,Access={?matlab.graphics.chart.GeographicChart})
        function rememberZoomLevelInteraction(obj)
            if~obj.InteractionHasOccurred

                obj.ZoomLevelBeforeInteraction=obj.ZoomLevel_I;
            end
        end


        function rememberMapCenterInteraction(obj)
            if~obj.InteractionHasOccurred

                obj.MapCenterBeforeInteraction=obj.MapCenter_I;
            end
        end
    end


    methods(Static,Hidden)
        function tb=getDefaultToolbar(obj)
            tb=matlab.graphics.controls.ToolbarController.getDefaultToolbar(obj);
        end
    end
end


function tileZoomLevel=computeTileZoom(zoomLevel,maxTileZoomLevel)






    tol=1e-6;
    tileZoomLevel=max(0,min(maxTileZoomLevel,floor(zoomLevel+tol)));
end


function plotbox=getPlotbox(ax,units)




    layout=GetLayoutInformation(ax);
    plotbox=layout.PlotBox;
    vp=ax.Camera.Viewport;



    vp.Units='pixels';
    vp.Position=plotbox;
    vp.Units=units;
    plotbox=vp.Position;
end
