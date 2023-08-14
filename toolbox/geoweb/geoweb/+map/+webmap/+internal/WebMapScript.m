classdef WebMapScript<handle















































    properties(Access='public')




        MapName='Web Map'





InstallFolder





        ScriptFilename='webmap.js'





        HTMLFilename='session1.html'
    end

    properties(Access=public,Dependent=true)








BaseLayer





BaseLayerName







LatitudeLimits
    end

    properties(Access=public)






        LongitudeLimits=[-180,180]





        CenterLatitude=0





        CenterLongitude=0
    end

    properties(Access=public,Dependent=true)




CenterPoint
    end

    properties(Access=public)





        WrapAround=true





        ZoomLevel=2






        FrameWidth=525






        FrameHeight=525
    end

    properties(Access='public',Hidden)





        DeployAddon char=''







        AddOnsPath char=''
    end

    properties(SetAccess='protected',GetAccess='public')




        CoordinateReferenceSystem='EPSG:900913'





UsingPublish





        PublishingActiveWebMap=false





        BaseLayerNames={'default'}





        ApiProvider=''





        ApiLibrary=''




        ApiVersion=''
    end

    properties(SetAccess='private',GetAccess='public',Dependent=true)




Script




HTML
    end

    properties(Access='protected',Hidden=true)





        WebScript={}





ScriptFolder





        ScriptBase='Base'





InstalledFiles





        FilesAreInstalled=false





        LayerConfigurationFilename='webmap_config.xml'





        LayerConfigurationFullFilename(1,1)string=""





        BaseLayerConfiguration=[]


        NumBaseLayersInConfigFile(1,1)double=0





        OverlayLayerConfiguration=[]




        Browser=[]





        ChannelID char=''




        BrowserInterface=[]





PublishFigureHandle






CloseFigureObject


        CreateWebMapFilename='createWebMap.js'
        CreateTiledMapServiceLayerFilename=...
'createTiledMapServiceLayer.js'
        CreateTiledMapServiceOverlayLayersFilename=...
'createTiledMapServiceOverlayLayers.js'
        CreateWebMapServiceLayerFilename=...
'createWebMapServiceLayer.js'
        CreateWebMapServiceOverlayLayersFilename=...
'createWebMapServiceOverlayLayers.js'
        CreateLayersFilename='createLayers.js'
        WebMapHTMLFilename='webmap.html'
WebMapHTML


        GetBaseLayerName=...
'   getBaseLayerName();'
        SetCenter='   window.msgImpl.setMapCenter(window.webmapImpl.map, centerLat, centerLon, zoomLevel);'
        SetZoom='   window.msgImpl.setZoomLevel(window.webmapImpl.map, zoomLevel);'
        SetLimits='   window.msgImpl.setMapLimits(window.webmapImpl.map, xmin, xmax, ymin, ymax);'
        RestrictLimits=...
'   window.webmapImpl.setRestrictedExtent(window.webmapImpl.map, xmin, xmax, ymin, ymax);'

        GetCenter='   window.msgImpl.getMapCenter(window.webmapImpl.map);'
        GetZoom='   window.msgImpl.getZoomLevel(window.webmapImpl.map);'
        GetLimits='   window.msgImpl.getMapLimits(window.webmapImpl.map);'
        Print='   print();'
        CreateKmlLayer=...
        '   window.msgImpl.addVectorOverlay(window.webmapImpl.map, "FILENAME_TOKEN", "KML");';
        RemoveKmlOverlay=...
'   window.msgImpl.removeVectorOverlay(window.webmapImpl.map, layerNumber);'
        WrapAroundVar=...
'   var wrapDateLine = true;'

        PanZoomBarScript=...
'   window.webmapImpl.map.removeControl(window.webmapImpl.panzoom);'
    end

    properties(Access='protected',Hidden=true,Dependent=true)

CreateWebMap
CreateTiledMapServiceLayer
CreateTiledMapServiceOverlayLayers
CreateWebMapServiceLayer
CreateWebMapServiceOverlayLayers
CreateLayers
EndOfCreateLayersScript
    end

    properties(Access='protected',Hidden,Constant)
        EndOfScript='}'
        LineWidthInChars=120
    end

    properties(Access='private',Hidden=true)

pBaseLayer
pBaseLayerName
        pLatitudeLimits=[-85,85]
pCreateWebMap
pCreateTiledMapServiceLayer
pCreateTiledMapServiceOverlayLayers
pCreateWebMapServiceLayer
pCreateWebMapServiceOverlayLayers
pCreateLayers
        pEndOfCreateLayersScript=''
    end

    methods

        function script=WebMapScript()






            script.ScriptFolder=fullfile(toolboxdir('geoweb'),'geoweb','scripts');


            script.InstallFolder=pwd;




            if isdeployed||isempty(snapnow('get'))
                script.UsingPublish=false;
            else
                script.UsingPublish=true;
            end
        end

        function js=addKmlOverlay(script,filename,overlayName)












            url=filename;

            js=createKmlLayerScript(script,url,overlayName);
            appendScript(script,js);
            if isBrowserEnabled(script)
                ifc=script.BrowserInterface;
                addVectorOverlay(ifc,url,overlayName)
                snapshotIfPublishing(script)
            end
        end

        function removeKmlOverlay(script,overlayScript,layerNumber)






            if~isempty(overlayScript)&&~isempty(script.WebScript)
                script.WebScript=strrep(script.WebScript,overlayScript,'');
                if isBrowserEnabled(script)
                    layerNumber=layerNumber-1;
                    ifc=script.BrowserInterface;
                    removeVectorOverlay(ifc,layerNumber);
                    snapshotIfPublishing(script)
                end
            end
        end

        function js=appendSetCenterScript(script,centerLat,centerLon,varargin)












            if isempty(varargin)
                js=script.createSetCenterScript(centerLat,centerLon);
            else
                zoomLevel=varargin{1};
                script.ZoomLevel=zoomLevel;
                js=script.createSetCenterScript(centerLat,centerLon,zoomLevel);
            end
            script.appendScript(js);
            script.CenterLatitude=centerLat;
            script.CenterLongitude=centerLon;
            setWebMapCenter(script)
            snapshotIfPublishing(script)
        end


        function js=appendSetZoomLevelScript(script,zoomLevel)







            js=script.createSetZoomScript(zoomLevel);
            script.appendScript(js);
            script.ZoomLevel=zoomLevel;
            setWebMapZoomLevel(script)
            snapshotIfPublishing(script)
        end


        function js=appendSetLimitsScript(script,latlim,lonlim)









            latlim=clampLatitudeLimits(...
            script.CoordinateReferenceSystem,latlim);

            js=script.createSetLimitsScript(latlim,lonlim);
            script.appendScript(js);

            script.LatitudeLimits=latlim;
            script.LongitudeLimits=lonlim;
            setWebMapLimits(script)
            snapshotIfPublishing(script)
        end




        function setWebMapCenter(script)





            if script.isBrowserEnabled
                ifc=script.BrowserInterface;
                centerLat=script.CenterLatitude;
                centerLon=script.CenterLongitude;
                zoomLevel=getWebMapZoomLevel(script);
                setMapCenter(ifc,centerLat,centerLon,zoomLevel)
            end
        end

        function[centerLat,centerLon]=getWebMapCenter(script)





            if script.isBrowserEnabled
                ifc=script.BrowserInterface;
                [centerLat,centerLon]=getMapCenter(ifc);
            else
                centerLat=script.CenterLatitude;
                centerLon=script.CenterLongitude;
            end
        end

        function setWebMapZoomLevel(script)





            if script.isBrowserEnabled
                ifc=script.BrowserInterface;
                zoomLevel=script.ZoomLevel;
                setZoomLevel(ifc,zoomLevel)
            end
        end

        function zoomLevel=getWebMapZoomLevel(script)





            if script.isBrowserEnabled
                ifc=script.BrowserInterface;
                zoomLevel=getZoomLevel(ifc);
            else
                zoomLevel=script.ZoomLevel;
            end
        end

        function setWebMapLimits(script)






            if script.isBrowserEnabled
                ifc=script.BrowserInterface;
                latlim=script.LatitudeLimits;
                lonlim=script.LongitudeLimits;
                setMapLimits(ifc,latlim,lonlim)
            end
        end

        function[latlim,lonlim]=getWebMapLimits(script)





            if script.isBrowserEnabled
                ifc=script.BrowserInterface;
                [latlim,lonlim]=getMapLimits(ifc);




                crs=script.CoordinateReferenceSystem;
                latlim=clampLatitudeLimits(crs,latlim);


                lonlim=clampLongitudeLimits(lonlim);
            else
                latlim=script.LatitudeLimits;
                lonlim=script.LongitudeLimits;
            end
        end



        function install(script)





            if~script.FilesAreInstalled
                script.write();
                script.FilesAreInstalled=true;
                script.InstalledFiles={...
                fullfile(script.InstallFolder,script.HTMLFilename),...
                fullfile(script.InstallFolder,script.ScriptFilename)};
            end
        end

        function delete(script)





            if script.FilesAreInstalled&&~script.PublishingActiveWebMap
                files=script.InstalledFiles;
                for k=1:length(files)
                    if exist(files{k},'file')&&~exist(files{k},'dir')
                        delete(files{k});
                    elseif exist(files{k},'dir')
                        rmdir(files{k},'s')
                    end
                end
            end

            if~isempty(script.AddOnsPath)
                addOnsPath=extractAfter(script.AddOnsPath,'addons');
                script.AddOnsPath='';



                connector.removeStaticContentOnPath(addOnsPath)
            end
        end

        function publish(script)







            script.install();
            if script.PublishingActiveWebMap



            end
        end

        function varargout=web(script,browserIfc)








            if script.PublishingActiveWebMap


                hweb=[];
            else
                if nargin==2
                    script.BrowserInterface=browserIfc;
                elseif isempty(script.BrowserInterface)
                    script.BrowserInterface=...
                    map.webmap.internal.BrowserInterfaceFactory.createDefaultBrowserInterface;
                end

                if~script.FilesAreInstalled
                    install(script);
                else
                    writeScript(script);
                end


                if isempty(script.AddOnsPath)

                    addWebAddOnsPath(script)
                end
                url=connector.getHttpsUrl([script.AddOnsPath,script.HTMLFilename]);


                hweb=openBrowser(script,url);
            end

            if nargout==1
                varargout{1}=hweb;
            end
        end


        function addWebAddOnsPath(script)







            channelID=lower(script.MapName);
            channelID(isspace(channelID))=[];
            script.ChannelID=channelID;

            addOnsPath=['geoweb',channelID];
            connector.ensureServiceOn;
            connector.addWebAddOnsPath(addOnsPath,script.InstallFolder);
            script.AddOnsPath=['addons/',addOnsPath,'/'];
        end


        function hweb=openBrowser(script,url)


            if~isempty(script.Browser)&&~isempty(script.BrowserInterface)

                hweb=script.Browser;
                ifc=script.BrowserInterface;
                setCurrentLocation(ifc,url)
                setBrowserName(ifc,script.MapName)
            else
                ifc=script.BrowserInterface;
                ifc.ChannelID=script.ChannelID;
                hweb=web(ifc,url);
                script.Browser=hweb;
                setBrowserName(ifc,script.MapName)



                if script.UsingPublish

                    hfig=figure('Visible','on');
                    set(hfig,'CurrentAxes',gca)
                    script.PublishFigureHandle=hfig;


                    script.CloseFigureObject=onCleanup(@()closeFigure(hfig));


                    showBrowserSnapshotImage(script)
                end
            end
        end


        function closeBrowser(script)


            if~isempty(script.Browser)&&isvalid(script.Browser)
                delete(script.Browser)
            end
        end



        function set.MapName(script,mapName)
            validateattributes(mapName,{'char'},{'nonempty','row'},...
            mfilename,'MapName');
            script.MapName=mapName;
        end

        function set.InstallFolder(script,dirName)
            if isempty(dirName)
                dirName=pwd;
            else
                validateattributes(dirName,{'char'},{'nonempty','row'},...
                mfilename,'InstallFolder');
            end
            if~contains(dirName,'/')&&~contains(dirName,'\')
                dirName=fullfile(pwd,dirName);
            end
            if~exist(dirName,'dir')
                mkdir(dirName)
            end
            script.InstallFolder=dirName;
        end

        function set.ScriptFilename(script,filename)
            validateattributes(filename,{'char'},{'nonempty','row'},...
            mfilename,'ScriptFilename');
            script.ScriptFilename=filename;
        end

        function set.HTMLFilename(script,filename)
            validateattributes(filename,{'char'},{'nonempty','row'},...
            mfilename,'HTMLFilename');
            script.HTMLFilename=filename;
        end

        function set.BaseLayer(script,layer)

            validateattributes(layer,{'WMSLayer'},{'nonempty'},...
            mfilename,'BaseLayer');

            mwurl="https://wms.mathworks.com";
            if any(contains({layer.ServerURL},extractAfter(mwurl,":")))
                wmsreadtxt='<a href="matlab:doc wmsread">wmsread</a>';
                geoshowtxt='<a href="matlab:doc geoshow">geoshow</a>';
                error(message('map:webmap:LayerNotSupported',...
                mwurl,wmsreadtxt,geoshowtxt))
            end


            layer=wmsupdate(layer,'AllowMultipleServers',true);


            if isempty(layer)
                validateattributes(layer,{'WMSLayer'},{'nonempty'},...
                mfilename,'BaseLayer');
            end


            script.CoordinateReferenceSystem='EPSG:4326';


            script.pBaseLayer=layer;
        end

        function v=get.BaseLayer(script)
            v=script.pBaseLayer;
        end

        function set.BaseLayerName(script,name)
            names=script.BaseLayerNames;
            names_lower=strrep(lower(names),' ','');
            try
                value=validatestring(name,names);
            catch e
                if strcmp(e.identifier,'MATLAB:unrecognizedStringChoice')
                    value=validatestring(name,unique([names,names_lower]));
                else
                    rethrow(e)
                end
            end

            baseLayerName=strrep(lower(value),' ','');
            baseIndex=strcmp(baseLayerName,names_lower);
            baseLayerName=names{baseIndex};

            script.pBaseLayerName=baseLayerName;
        end

        function v=get.BaseLayerName(script)
            v=script.pBaseLayerName;
        end

        function set.LatitudeLimits(script,latlim)
            validateattributes(latlim,{'double'},...
            {'vector','numel',2,'real','finite',...
            '>=',-90,'<=',90,'nonempty'},...
            mfilename,'LatitudeLimits');
            latlim=[min(latlim),max(latlim)];


            crs=script.CoordinateReferenceSystem;
            latlim=clampLatitudeLimits(crs,latlim);


            script.pLatitudeLimits=latlim;
        end

        function v=get.LatitudeLimits(script)
            v=script.pLatitudeLimits;
        end

        function set.LongitudeLimits(script,lonlim)
            validateattributes(lonlim,{'double'},...
            {'vector','numel',2,'real','finite','nonempty'},...
            mfilename,'LongitudeLimits');
            if any(lonlim>360)||any(lonlim<-180)
                lonlim=wrapTo360(lonlim);
            end
            if lonlim(1)>lonlim(2)
                lonlim(2)=wrapTo360(lonlim(2));
            end
            script.LongitudeLimits=lonlim;
        end

        function set.CenterLatitude(script,lat)

            if~isempty(lat)
                validateattributes(lat,{'double','single'},...
                {'scalar','real','finite','>=',-90,'<=',90},...
                mfilename,'CenterLatitude');


                lat=double(lat);

                if script.isSphericalMercatorProjection


                    lat=max(lat,-85);
                    lat=min(lat,85);
                end
            end
            script.CenterLatitude=lat;
        end

        function set.CenterLongitude(script,lon)
            if~isempty(lon)

                validateattributes(lon,{'double','single'},...
                {'scalar','real','finite','nonempty'},...
                mfilename,'CenterLongitude');
            end


            lon=double(lon);


            script.CenterLongitude=wrapTo180(lon);
        end

        function set.CenterPoint(script,pt)
            if length(pt)~=2

                validateattributes(pt,{'double','single'},...
                {'vector','numel',2},mfilename,'CenterPoint');
            end


            script.CenterLatitude=pt(1);
            script.CenterLongitude=pt(2);
            if script.isBrowserEnabled
                setWebMapCenter(script)
            end
        end

        function v=get.CenterPoint(script)
            lat=script.CenterLatitude;
            lon=script.CenterLongitude;
            v=[lat,lon];
        end

        function set.WrapAround(script,wrap)
            validateattributes(wrap,{'logical','double'},...
            {'scalar','real','finite','nonempty'},...
            mfilename,'WrapAround');
            script.WrapAround=logical(wrap);
        end

        function set.ZoomLevel(script,zoomLevel)
            validateattributes(zoomLevel,{'numeric'},...
            {'integer','scalar','>',-1,'<',19},...
            mfilename,'ZoomLevel')
            script.ZoomLevel=zoomLevel;
            if script.isBrowserEnabled
                setWebMapZoomLevel(script)
            end
        end

        function v=get.Script(script)


            s1=createWebMapScript(script);



            s2=script.WebScript;


            s3=script.EndOfScript;


            script.WebScript={};
            appendScript(script,s1);
            appendScript(script,s2);
            appendScript(script,s3);
            v=script.WebScript;
            v=char([v{:}]);
        end

        function v=get.HTML(script)
            html=script.WebMapHTML;
            v=[html{:}];
        end

        function v=get.CreateWebMap(script)
            if isempty(script.pCreateWebMap)
                js=readScript(script,script.CreateWebMapFilename);
                script.pCreateWebMap=extractBefore(js,script.EndOfScript);
            end
            v=script.pCreateWebMap;
        end

        function v=get.CreateTiledMapServiceLayer(script)
            if isempty(script.pCreateTiledMapServiceLayer)
                script.pCreateTiledMapServiceLayer=...
                readScript(script,script.CreateTiledMapServiceLayerFilename);
            end
            v=script.pCreateTiledMapServiceLayer;
        end

        function v=get.CreateTiledMapServiceOverlayLayers(script)
            if isempty(script.pCreateTiledMapServiceOverlayLayers)
                script.pCreateTiledMapServiceOverlayLayers=...
                readScript(script,script.CreateTiledMapServiceOverlayLayersFilename);
            end
            v=script.pCreateTiledMapServiceOverlayLayers;
        end

        function v=get.CreateWebMapServiceLayer(script)
            if isempty(script.pCreateWebMapServiceLayer)
                script.pCreateWebMapServiceLayer=...
                readScript(script,script.CreateWebMapServiceLayerFilename);
            end
            v=script.pCreateWebMapServiceLayer;
        end

        function v=get.CreateWebMapServiceOverlayLayers(script)
            if isempty(script.pCreateWebMapServiceOverlayLayers)
                script.pCreateWebMapServiceOverlayLayers=...
                readScript(script,script.CreateWebMapServiceOverlayLayersFilename);
            end
            v=script.pCreateWebMapServiceOverlayLayers;
        end

        function v=get.CreateLayers(script)
            if isempty(script.pCreateLayers)
                js=readScript(script,script.CreateLayersFilename);
                currentYear=string(year(datetime('today')));
                if~isempty(js)
                    script.pEndOfCreateLayersScript=extractAfter(js,'{');
                    js=extractBefore(js,'return');
                    script.pCreateLayers=strrep(js,'YEAR',char(currentYear));
                else


                    script.pEndOfCreateLayersScript={...
                    [newline,'    return layers;',newline,'}',newline]};
                    script.pCreateLayers={...
                    ['// Main entry point for webmap',newline...
                    ,'// Copyright ',char(currentYear),'The MathWorks Inc.',newline...
                    ,'function createLayers() {',newline]};
                end
            end
            v=script.pCreateLayers;
        end

        function v=get.EndOfCreateLayersScript(script)
            v=script.pEndOfCreateLayersScript;
        end

        function v=get.WebMapHTML(script)
            v=readScript(script,script.WebMapHTMLFilename);
            [~,base,ext]=fileparts(script.ScriptFilename);
            filename=[base,ext];
            v=strrep(v,'webmap.js',filename);
        end
    end



    methods(Access='protected')

        function js=createWebMapScript(script)







            s=script.WebScript;
            script.WebScript={};



            base=script.BaseLayerConfiguration;
            useWebMapServiceScript=false;
            if~isempty(base.WMSLayer)
                wmsConfig=base.WMSLayer;
                projections={wmsConfig.Projection};
                index1=strcmp('EPSG:4326',projections);
                index2=strcmp('CRS:84',projections);
                index=index1|index2;
                geoLayerConfig=wmsConfig(index);
                if~isempty(geoLayerConfig)
                    script.BaseLayerConfiguration.WMSLayer=geoLayerConfig;
                    useWebMapServiceScript=true;
                end
            end



            layer=script.BaseLayer;
            layerIsTiled=~isempty(layer)&&...
            layerIsUsingSphericalMercatorProjection(layer);
            useTiledMapServiceScript=isempty(layer)||...
            (~useWebMapServiceScript&&layerIsTiled);


            js=script.CreateLayers;
            appendScript(script,js);

            if useTiledMapServiceScript

                updateStaticAttribution(script)

                if layerIsTiled

                    projCodes=cell(1,length(layer));
                    for k=1:length(layer)
                        projCodes{k}=getSphericalMercatorProjectionCode(layer(k));
                    end
                    js=createTiledMapServiceMapScript(script,layer,projCodes);
                else

                    js=createTiledMapServiceMapScript(script);
                end
            else

                js=createWebMapServiceMapScript(script,layer);
            end


            script.WebScript=s;
        end



        function updateStaticAttribution(script)














            persistent baseLayerConfiguration
            persistent overlayLayerConfiguration
            persistent layerConfigFile
            if isempty(layerConfigFile)
                layerConfigFile=script.LayerConfigurationFullFilename;
            end





            haveAppData=isappdata(groot,'DEFAULT_WEBMAP_BASELAYER');
            if~haveAppData


























                numBaseLayersInConfigFile=script.NumBaseLayersInConfigFile;
                updateConfiguration=...
                length(baseLayerConfiguration)~=numBaseLayersInConfigFile||...
                layerConfigFile~=script.LayerConfigurationFullFilename;

                lineWidth=script.LineWidthInChars;
                try

                    if updateConfiguration
                        base=script.BaseLayerConfiguration.XYZLayer(1:numBaseLayersInConfigFile);
                        overlay=script.OverlayLayerConfiguration.XYZLayer;
                        baseLayerConfiguration=...
                        map.webmap.internal.updateStaticAttribution(base,lineWidth);
                        overlayLayerConfiguration=...
                        map.webmap.internal.updateStaticAttribution(overlay,lineWidth);
                        layerConfigFile=script.LayerConfigurationFullFilename;
                    end



                    script.BaseLayerConfiguration.XYZLayer(1:numBaseLayersInConfigFile)...
                    =baseLayerConfiguration;




                    script.OverlayLayerConfiguration.XYZLayer=overlayLayerConfiguration;
                catch

                end
            end
        end



        function assignLayerConfigurationProperties(script)






            filename=script.LayerConfigurationFilename;
            if~exist(filename,'file')

                filename=fullfile(...
                script.ScriptFolder,script.ScriptBase,filename);
                script.LayerConfigurationFullFilename=string(filename);
            else
                script.LayerConfigurationFullFilename=string(which(filename));
            end


            [base,overlay,numBaseLayersInConfigFile]=...
            map.webmap.internal.readLayerConfiguration(filename);
            script.BaseLayerConfiguration=base;
            script.OverlayLayerConfiguration=overlay;
            script.NumBaseLayersInConfigFile=numBaseLayersInConfigFile;


            if~isempty(base.XYZLayer)
                xyzConfig=base.XYZLayer;
                xyzLayerNames={xyzConfig.LayerName};
            else
                xyzLayerNames={};
            end
            if~isempty(base.WMSLayer)
                wmsConfig=base.WMSLayer;
                wmsLayerNames={wmsConfig.LayerName};
            else
                wmsLayerNames={};
            end
            script.BaseLayerNames=[xyzLayerNames,wmsLayerNames];


            if isappdata(groot,'DEFAULT_WEBMAP_BASELAYER')
                defaultBaseLayer=getappdata(groot,'DEFAULT_WEBMAP_BASELAYER');
            else
                defaultBaseLayer=script.BaseLayerNames{1};
            end
            script.BaseLayerName=defaultBaseLayer;
        end



        function appendScript(script,js)






            if~isempty(js)
                if ischar(js)

                    js={js};
                else

                    js={[js{:}]};
                end


                v=js{end};
                if~isequal(v(end),newline)
                    v(end+1)=newline;
                    js{end}=v;
                end
                js=[script.WebScript;js];


                script.WebScript={[js{:}]};
            end
        end



        function removeScript(script,js)





            script.WebScript=strrep(script.WebScript,js,'');
        end



        function iframe(script,filename)





            js=['<html><iframe src="',filename,'" ',...
            ['width="',num2str(script.FrameWidth),'" height="'...
            ,num2str(script.FrameHeight),'" frameborder="0" '],...
'scrolling="yes" marginheight="0" marginwidth="0">'...
            ,'</iframe></html>'];
            disp(js);
        end



        function write(script)





            writeScript(script);
            writeHTML(script);
            writeBundle(script);
        end



        function writeHTML(script)





            html=script.HTML;
            if isdeployed










                deployAddon=script.DeployAddon;
                connector.ensureServiceOn;
                connector.addWebAddOnsPath(deployAddon,matlabroot)
                deployURL=[connector.getBaseUrl,'addons/',deployAddon,'/mcr/toolbox'];
                html=replace(html,'/toolbox',deployURL);
            end
            filename=fullfile(script.InstallFolder,script.HTMLFilename);
            fid=fopen(filename,'w');
            fwrite(fid,html);
            fclose(fid);
        end



        function writeScript(script)





            js=script.Script;
            filename=fullfile(script.InstallFolder,script.ScriptFilename);
            fid=fopen(filename,'w');
            fwrite(fid,js);
            fclose(fid);
        end

        function writeBundle(script)





            releaseFolder=fullfile(script.ScriptFolder,"webmap","release");
            files=dir(fullfile(releaseFolder,"bundle*"));
            if~isempty(files)
                installReleaseFolder=fullfile(script.InstallFolder,"release");
                if~exist(installReleaseFolder,"dir")
                    mkdir(installReleaseFolder)
                end
                for k=1:length(files)
                    filename=fullfile(releaseFolder,files(k).name);
                    copyfile(filename,installReleaseFolder,"f")
                end
            end
        end



        function js=readScript(script,filename)





            if isempty(filename)
                js='';
            else
                filename=fullfile(script.ScriptFolder,script.ScriptBase,filename);
                fid=fopen(filename,'r');
                if fid<0
                    js={};
                else
                    obj=onCleanup(@()fclose(fid));
                    js=fread(fid,'char=>char');
                    js={js'};
                end
            end
        end



        function tf=isBrowserEnabled(script)





            ifc=script.BrowserInterface;
            tf=~isempty(ifc)&&isvalid(ifc)...
            &&isBrowserEnabled(script.BrowserInterface);
        end



        function tf=isSphericalMercatorProjection(script)

            tf=strcmp(script.CoordinateReferenceSystem,'EPSG:900913');
        end



        function snapshotIfPublishing(script)


            if script.UsingPublish

                pause(1.5)
                showBrowserSnapshotImage(script)
            end
        end

        function showBrowserSnapshotImage(script)


            ifc=script.BrowserInterface;
            showBrowserSnapshotImage(ifc,script.PublishFigureHandle)
        end
    end



    methods(Abstract,Access='protected')

        js=createTiledMapServiceMapScript(script)

        js=createKmlLayerScript(script,filename,kmlName)

        js=createWebMapServiceMapScript(script)

        js=createSetCenterScript(script,centerLat,centerLon,zoomLevel)

        js=createSetZoomScript(script,zoomLevel)

        js=createSetLimitsScript(script,latlim,lonlim)

        js=createSetMapExtentScript(script)

    end
end



function latlim=clampLatitudeLimits(crs,latlim)



    if strcmp(crs,'EPSG:900913')


        limitMax=85;
        limitMin=-85;
    else
        limitMax=90;
        limitMin=-90;
    end


    latlim(latlim>limitMax)=limitMax;
    latlim(latlim<limitMin)=limitMin;
end



function lonlim=clampLongitudeLimits(lonlim)


    if lonlim(1)<-180
        lonlim(1)=-180;
        if lonlim(2)>180
            lonlim(2)=180;
        end
    elseif any(lonlim>360)
        lonlim(lonlim>360)=360;
    end
end



function closeFigure(hfig)


    if~isempty(hfig)&&ishghandle(hfig,'figure')
        close(hfig)
    end
end



function tf=layerIsUsingSphericalMercatorProjection(layer)



    projCodes={'EPSG:900913','EPSG:102113','EPSG:3857'};
    tf=false(1,length(layer));
    for k=1:length(layer)
        tf(k)=any(ismember(projCodes,layer(k).CoordRefSysCodes));
    end
    tf=all(tf);
end



function projCode=getSphericalMercatorProjectionCode(layer)


    if layerIsUsingSphericalMercatorProjection(layer)
        projCodes={'EPSG:900913','EPSG:3857','EPSG:102113'};
        index=ismember(projCodes,layer.CoordRefSysCodes);
        index=find(index,1);
        projCode=projCodes{index};
    else
        projCode='';
    end
end
