classdef Canvas<handle

    properties(Access=public,Hidden,Dependent)

BaseLayer

BaseLayerName

WrapAround

CenterPoint

ZoomLevel

LatitudeLimits

LongitudeLimits
    end

    properties(GetAccess=public,SetAccess=private,Hidden)
        UsingConnectorBrowserInterface=false
    end

    properties(GetAccess=public,SetAccess=private,Hidden,Dependent)



Script
    end

    properties(Access=private,Transient)

Browser

BrowserInterface

BaseInstallFolder

InstallFolderCreated

WebMapId

Overlay

        NumberOfVisibleOverlays=0

        RemoveOverlayIndex=logical([])

        TotalNumberOfOverlays=0
    end

    properties(Access='private',Dependent)

BrowserIsEnabled
    end

    properties(Access=private,Transient)

pScript


        pBrowserIsEnabled=false
    end

    properties(Access=private,Constant,Hidden)
        Basename='webmap'
        AppDataName='webmap'
        AppDataIdName='webmapid'
    end

    methods(Hidden)
        function h=Canvas(varargin)
            h.WebMapId=newWebMapId(h.AppDataIdName);

            if nargin>0
                index=cellfun(@(x)isa(x,'map.webmap.internal.BrowserInterface'),varargin);
                if any(index)
                    browserIfc=varargin(index);
                    browserIfc=browserIfc{end};
                    h.BrowserInterface=browserIfc;
                    varargin(index)=[];
                else
                    h.BrowserInterface=map.webmap.internal.BrowserInterfaceFactory.createDefaultBrowserInterface;
                end
            else
                h.BrowserInterface=map.webmap.internal.BrowserInterfaceFactory.createDefaultBrowserInterface;
            end

            h.UsingConnectorBrowserInterface=...
            isa(h.BrowserInterface,'map.webmap.internal.ConnectorWebWindowBrowserInterface');


            if numel(varargin)>0
                displayBrowser=varargin{1};
                displayBrowser=logical(displayBrowser);
            else
                displayBrowser=true;
            end


            if numel(varargin)>1
                script=varargin{2};
                h.Script=script;
            else

                h.Script=map.webmap.internal.OpenLayersScript;
            end

            if displayBrowser



                web(h);
            else


                h.Browser=[];
            end
        end
    end

    methods
        function delete(h)
            if~isempty(h)&&~isempty(findprop(h,'Browser'))

                if~isempty(h.Overlay)
                    for k=length(h.Overlay):-1:1
                        overlay=h.Overlay{k};
                        if isvalid(overlay)
                            delete(overlay)
                        end
                    end
                end

                rmappdata(h);


                rminstall(h);

                if~isempty(h.Browser)&&isValidBrowser(h.BrowserInterface)

                    close(h.BrowserInterface)
                end
            end
        end



        function set.Script(h,script)

            validateattributes(script,...
            {'map.webmap.internal.WebMapScript'},...
            {'scalar','nonempty'});



            if~isempty(h.Script)
                rminstall(h);
            end

            webMapIdStr=sprintf('%d',h.WebMapId);
            webMapName=sprintf('%s %s','Web Map',webMapIdStr);
            script.MapName=webMapName;


            if h.UsingConnectorBrowserInterface
                randIdStr=char(string(convertTo(datetime('now'),'.net')));
                basename=[h.Basename,randIdStr];
            else
                basename=[h.Basename,webMapIdStr];
            end
            script.HTMLFilename=[basename,'.html'];
            script.ScriptFilename=[basename,'.js'];
            script.DeployAddon=['deployroot',webMapIdStr];

            isPublishing=script.PublishingActiveWebMap;
            if~isPublishing
                h.BaseInstallFolder=tempname;
                installFolder=fullfile(h.BaseInstallFolder,'webmapdata');
                if~exist(installFolder,'dir')
                    mkdir(installFolder);
                    h.InstallFolderCreated=true;
                else
                    h.InstallFolderCreated=false;
                end
                script.InstallFolder=installFolder;
            else

                script.InstallFolder=fullfile(pwd,'html');
                h.InstallFolderCreated=false;
            end


            addWebAddOnsPath(script)


            h.pScript=script;
        end

        function v=get.Script(h)
            v=h.pScript;
        end

        function set.BaseLayer(h,value)
            h.Script.BaseLayer=value;
        end

        function v=get.BaseLayer(h)
            v=h.Script.BaseLayer;
        end

        function set.BaseLayerName(h,name)
            h.Script.BaseLayerName=name;
        end

        function baseLayerName=get.BaseLayerName(h)
            baseLayerName=h.Script.BaseLayerName;
        end

        function set.WrapAround(h,value)
            h.Script.WrapAround=value;
        end

        function v=get.WrapAround(h)
            v=h.Script.WrapAround;
        end

        function set.ZoomLevel(h,value)
            h.Script.ZoomLevel=value;
        end

        function zoomLevel=get.ZoomLevel(h)
            if h.BrowserIsEnabled
                zoomLevel=getWebMapZoomLevel(h.Script);
            else
                zoomLevel=h.Script.ZoomLevel;
            end
        end

        function set.CenterPoint(h,pt)
            if isempty(pt)
                h.Script.CenterLatitude=[];
                h.Script.CenterLongitude=[];
            else
                h.Script.CenterPoint=pt;
            end
        end

        function v=get.CenterPoint(h)
            if h.BrowserIsEnabled
                [lat,lon]=getWebMapCenter(h.Script);
                v=[lat,lon];
            else
                v=h.Script.CenterPoint;
            end
        end

        function set.LatitudeLimits(h,value)
            h.Script.LatitudeLimits=value;
        end

        function latlim=get.LatitudeLimits(h)
            if h.BrowserIsEnabled
                latlim=getWebMapLimits(h.Script);
            else
                latlim=h.Script.LatitudeLimits;
            end
        end

        function set.LongitudeLimits(h,value)
            h.Script.LongitudeLimits=value;
        end

        function lonlim=get.LongitudeLimits(h)
            if h.BrowserIsEnabled
                [~,lonlim]=getWebMapLimits(h.Script);
            else
                lonlim=h.Script.LongitudeLimits;
            end
        end

        function set.BrowserIsEnabled(h,value)
            h.pBrowserIsEnabled=value;
        end

        function tf=get.BrowserIsEnabled(h)

            tf=h.pBrowserIsEnabled;
            if tf
                validBrowser=isValidBrowser(h.BrowserInterface);
                if~validBrowser
                    pause(.5)
                end
            end
        end
    end

    methods(Access=public,Hidden=true)

        function varargout=web(h)
            try
                h.Browser=web(h.Script,h.BrowserInterface);
            catch e
                throwAsCaller(e);
            end

            h.BrowserIsEnabled=true;

            if nargout==1
                varargout{1}=h.Browser;
            end

            setappdata(h);
            setCallback(h.BrowserInterface);
        end



        function hmarker=addMarkerOverlay(h,varargin)
            hmarker=map.webmap.MarkerOverlay(h,varargin{:});
            numberOfOverlays=h.NumberOfVisibleOverlays+1;
            hmarker.OverlayNumber=numberOfOverlays;
            h.TotalNumberOfOverlays=h.TotalNumberOfOverlays+1;
            hmarker.KMLFileNumber=h.TotalNumberOfOverlays;


            addOverlay(hmarker);


            if~isempty(hmarker.Feature)

                updateOverlayProperties(h,hmarker,numberOfOverlays);
            else


            end
        end



        function hline=addLineOverlay(h,varargin)
            hline=map.webmap.LineOverlay(h,varargin{:});
            numberOfOverlays=h.NumberOfVisibleOverlays+1;
            hline.OverlayNumber=numberOfOverlays;
            h.TotalNumberOfOverlays=h.TotalNumberOfOverlays+1;
            hline.KMLFileNumber=h.TotalNumberOfOverlays;


            addOverlay(hline);


            if~isempty(hline.Feature)

                updateOverlayProperties(h,hline,numberOfOverlays);
            else


            end
        end



        function hpoly=addPolygonOverlay(h,varargin)



            hpoly=map.webmap.PolygonOverlay(h,varargin{:});
            numberOfOverlays=h.NumberOfVisibleOverlays+1;
            hpoly.OverlayNumber=numberOfOverlays;
            h.TotalNumberOfOverlays=h.TotalNumberOfOverlays+1;
            hpoly.KMLFileNumber=h.TotalNumberOfOverlays;


            addOverlay(hpoly);


            if~isempty(hpoly.Feature)
                updateOverlayProperties(h,hpoly,numberOfOverlays);
            else


            end
        end



        function removeOverlay(h,overlay)


            if~exist('overlay','var')

                overlays=h.Overlay(~h.RemoveOverlayIndex);
                if~isempty(overlays)
                    overlay=overlays{end};
                else
                    overlay=[];
                end
            end

            if~isempty(overlay)

                classes={'map.webmap.MarkerOverlay','map.webmap.LineOverlay','map.webmap.PolygonOverlay'};
                validateattributes(overlay,classes,{'scalar'},mfilename);

                for k=1:length(h.Overlay)
                    if isequal(overlay,h.Overlay{k})
                        removeOverlay(overlay,k)
                        h.NumberOfVisibleOverlays=...
                        max(0,h.NumberOfVisibleOverlays-1);
                        h.RemoveOverlayIndex(k)=true;
                    end
                end
            end
        end



        function setLimits(h,latlim,lonlim)

            h.LatitudeLimits=latlim;
            h.LongitudeLimits=lonlim;
            latlim=h.Script.LatitudeLimits;
            lonlim=h.Script.LongitudeLimits;
            appendSetLimitsScript(h.Script,latlim,lonlim);
        end



        function[latlim,lonlim]=getLimits(h)
            [latlim,lonlim]=getWebMapLimits(h.Script);
        end



        function print(h)

            if h.BrowserIsEnabled

                makeActive(h)
                pause(.5)


                print(h.BrowserInterface)
            end
        end



        function makeActive(h)

            if h.BrowserIsEnabled
                makeActive(h.BrowserInterface)
                name=lower(h.Script.MapName);
                name(isspace(name))=[];
                map.webmap.Canvas.saveActiveBrowserName(name)
            end
        end
    end

    methods(Hidden,Static=true)
        function saveActiveBrowserName(name)
            setappdata(0,'webmap_active_browser_name',name);
        end
    end

    methods(Access='private')

        function setappdata(h)
            appdata=getappdata(0,h.AppDataName);

            name=lower(h.Script.MapName);
            name(isspace(name))=[];

            if isempty(appdata)
                webMapData=containers.Map(name,h);
            else
                webMapData=appdata;
                webMapData(name)=h;
            end


            setappdata(0,h.AppDataName,webMapData);
        end



        function rmappdata(h)
            appdata=getappdata(0,h.AppDataName);

            name=lower(h.Script.MapName);
            name=strrep(name,' ','');

            if isa(appdata,'containers.Map')&&isvalid(appdata)...
                &&~isempty(appdata)
                if appdata.isKey(name)
                    appdata.remove(name);
                    if isempty(appdata)
                        rmappdata(0,h.AppDataName);
                        if isappdata(0,h.AppDataIdName)
                            rmappdata(0,h.AppDataIdName);
                        end
                    else
                        setappdata(0,h.AppDataName,appdata);
                    end
                end
            else
                if isappdata(0,h.AppDataName)
                    rmappdata(0,h.AppDataName);
                end
                if isappdata(0,h.AppDataIdName)
                    rmappdata(0,h.AppDataIdName);
                end
            end
        end



        function rminstall(h)

            if exist(h.Script.InstallFolder,'dir')
                installFolder=h.Script.InstallFolder;
                delete(h.Script);
                try
                    if h.InstallFolderCreated

                        d=dir(installFolder);
                        names={d.name};
                        if isequal(names,{'.','..'})

                            rmdir(installFolder)
                            rmdir(h.BaseInstallFolder)
                        end
                    end
                catch
                end
            end
        end



        function updateOverlayProperties(h,hoverlay,numberOfOverlays)
            h.NumberOfVisibleOverlays=numberOfOverlays;
            h.RemoveOverlayIndex(end+1)=false;

            if isempty(h.Overlay)
                h.Overlay={hoverlay};
            else
                h.Overlay{end+1}=hoverlay;
            end

            if hoverlay.AutoFit
                setLimitsUsingAutoFit(h);
            end
        end

        function setLimitsUsingAutoFit(h)
            overlays=h.Overlay(~h.RemoveOverlayIndex);
            latlim=[];
            lonlim=[];
            lonlim360=[];
            buffer=.005;

            for k=1:length(overlays)
                overlay=overlays{k};
                feature=overlay.Feature;
                lat=feature.Latitude;
                lon=feature.Longitude;
                latlim=[min([lat,latlim]),max([lat,latlim])];
                lonlim=[min([lon,lonlim]),max([lon,lonlim])];
                lon360=wrapTo360(lon);
                lonlim360=...
                [min([lon360,lonlim360]),max([lon360,lonlim360])];
            end
            if~isempty(latlim)&&~isempty(lonlim)
                [latlim,lonlim]=bufgeoquad(latlim,lonlim,buffer,buffer);

                if diff(lonlim)>180

                    lonlim=lonlim360;
                end
                setLimits(h,latlim,lonlim);
            end
        end
    end
end



function webMapId=newWebMapId(appDataIdName)

    webMapId=getappdata(0,appDataIdName);

    if isempty(webMapId)
        webMapId=1;
    else
        webMapId=webMapId+1;
    end
    setappdata(0,appDataIdName,webMapId);
end
