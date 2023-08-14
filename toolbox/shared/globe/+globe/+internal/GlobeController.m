classdef GlobeController<handle







































    properties(Dependent)
Name
Position
Basemap
        TerrainClipping(1,1)matlab.lang.OnOffSwitchState
    end


    properties(SetAccess=private,Dependent)
URL
Visible
Launched
Terrain
UseTerrain
    end


    properties(Hidden)
        UseDebug=false
        LaunchWebWindow=true
ErrorResponseData
IsWebGraphicsSupported
MaxImageSize
WebGraphicsErrorMessage
        GlobeModel=globe.internal.GlobeModel.empty
        RequestTimeout double{mustBeNonnegative}=120
    end


    properties(Hidden,Dependent)
WindowController
TerrainSource
CesiumVersion
    end


    properties(Hidden,SetAccess=private)
        ID=1
        RequestResponseChannel char=''
    end


    properties(Access=private)
        BasemapTileURL string=string.empty
        SwitchToHTTPS(1,1)logical=false

        pCesiumVersion char=''
        pTerrainClipping(1,1)matlab.lang.OnOffSwitchState=matlab.lang.OnOffSwitchState.off
        pPosition=globe.internal.WebWindowController.defaultWindowPosition
        pWindowController=globe.internal.WebWindowController.empty

RequestResponseSubscription
RequestToken
RequestResponseFcn
RequestResponseData

        IsActionComplete logical=true
        IsRequestComplete logical=true









PendingCloseRequest

ConnectorServiceProvider
        LaunchIsComplete(1,1)=false
        AllowCameraMessages(1,1)=true
    end

    events
MouseEvent
ReloadEvent
    end


    methods
        function controller=GlobeController(varargin)










            controller.GlobeModel=globe.internal.GlobeModel;
            provider=globe.internal.ConnectorServiceProvider(varargin{:});
            controller.RequestResponseChannel=provider.RequestResponseChannel;
            controller.ConnectorServiceProvider=provider;
            controller.AllowCameraMessages=true;
        end

        function forceClipping(controller,clipping)
            if nargin==1
                clipping=true;
            end
            data.Clipping=clipping;
            controller.pTerrainClipping=clipping;
            controller.request("forceAutoTerrainClipping",data,@()onActionComplete(controller));
        end

        function ids=getId(controller,numIds)
            ids=cell(numIds,1);
            for i=1:numIds
                ids{i}=controller.ID;
                controller.ID=controller.ID+1;
            end
        end

        function responseData=request(controller,requestType,requestData,responseFcn)


            async=false;

            if(~iscell(requestData)&&isfield(requestData,'WaitForResponse')&&requestData.WaitForResponse==false)
                async=true;
            end


            if nargin<4
                responseFcn=requestData;
            end




            controller.IsRequestComplete=false;
            C=onCleanup(@()controller.onRequestComplete);




            [~,requestToken]=fileparts(tempname);
            if(~async)

                controller.IsActionComplete=false;
                controller.RequestResponseFcn=responseFcn;
                controller.RequestToken=requestToken;
            end
            if nargin<4
                msg=struct('Token',requestToken,'Type',requestType);
            else
                msg=struct('Token',requestToken,...
                'Type',requestType,...
                'Args',requestData);
            end
            message.publish(controller.RequestResponseChannel,msg);

            if(~async)
                controller.waitForAction;
            end

            responseData=controller.RequestResponseData;
            controller.RequestResponseData=[];


            if~isempty(controller.PendingCloseRequest)
                closeRequest=controller.PendingCloseRequest;
                controller.PendingCloseRequest=[];
                controller.request(closeRequest{:});
            end


            delete(C);
        end

        function launch(controller)



            if~controller.LaunchIsComplete

                if~isempty(controller.RequestResponseSubscription)
                    message.unsubscribe(controller.RequestResponseSubscription);
                end
                controller.RequestResponseSubscription=message.subscribe(controller.RequestResponseChannel,...
                @(msg)onRequestResponse(controller,msg));


                if controller.LaunchWebWindow
                    w=controller.WindowController;
                    w.Title=controller.Name;
                    w.Position=controller.Position;
                    constructWindow(w,controller.URL)
                end
            end
        end


        function show(controller)


            if~controller.LaunchWebWindow
                return
            end

            if isempty(controller.WindowController)


                controller.WindowController=globe.internal.WebWindowController;
            end

            try
                validateWebGraphicsSupport(controller)
                if controller.LaunchWebWindow
                    data=struct('EnableWindowLaunch',true,...
                    'Animation','none');
                    controller.visualRequest('show',data);
                end
            catch e
                throwAsCaller(e)
            end
        end

        function setViewRectangle(controller,latlim,lonlim)
            if~controller.LaunchWebWindow
                return
            end

            w=controller.WindowController;
            try
                if~controller.LaunchWebWindow||w.isVisible
                    data=struct(...
                    'EnableWindowLaunch',false,...
                    'Animation','fly',...
                    'North',latlim(2),...
                    'South',latlim(1),...
                    'West',lonlim(1),...
                    'East',lonlim(2));
                    controller.visualRequest('setViewRectangle',data);
                end
            catch e
                throwAsCaller(e)
            end
        end

        function[latlim,lonlim]=getViewRectangle(controller)
            try
                if isvalid(controller)&&controller.Visible
                    args=controller.request("getViewRectangle",@()onActionComplete(controller));
                    latlim(1)=rad2deg(args.south);
                    latlim(2)=rad2deg(args.north);
                    lonlim(1)=rad2deg(args.west);
                    lonlim(2)=rad2deg(args.east);
                else
                    latlim=[];
                    lonlim=[];
                end
            catch e
                throwAsCaller(e)
            end
        end


        function setCameraPosition(controller,cameraPosition)
            if~controller.LaunchWebWindow||~controller.AllowCameraMessages
                return
            end

            w=controller.WindowController;
            try
                if~controller.LaunchWebWindow||w.isVisible
                    data=struct('EnableWindowLaunch',false);
                    data.CameraPosition=cameraPosition.CameraPosition;
                    controller.visualRequest('setCameraPosition',data);
                end
            catch e
                throwAsCaller(e)
            end
        end


        function args=getParameterRequest(controller,fcnname)


            args=[];
            try
                if~isempty(controller)&&isvalid(controller)&&controller.Visible
                    ntimes=4;
                    args=[];
                    n=0;
                    while(n<ntimes&&isempty(args))
                        n=n+1;
                        if~isempty(controller)&&isvalid(controller)
                            args=controller.request(fcnname,@()onActionComplete(controller));
                        else
                            args=[];
                        end
                    end
                end
            catch
            end
        end

        function position=getCameraPosition(controller)
            if controller.AllowCameraMessages
                args=getParameterRequest(controller,"getCameraPosition");
                if~isempty(args)
                    position=args.position;
                else
                    position=globe.internal.GlobeOptions.DefaultCameraPosition;
                end
            else
                position=globe.internal.GlobeOptions.DefaultCameraPosition;
            end
        end

        function setCameraOrientation(controller,cameraOrientation)
            if~controller.LaunchWebWindow||~controller.AllowCameraMessages
                return
            end

            w=controller.WindowController;
            try
                if~controller.LaunchWebWindow||w.isVisible
                    data=struct('EnableWindowLaunch',false);
                    data.CameraOrientation=cameraOrientation.CameraOrientation;
                    controller.visualRequest('setCameraOrientation',data);
                end
            catch
            end
        end


        function orientation=getCameraOrientation(controller)
            if controller.AllowCameraMessages
                args=getParameterRequest(controller,"getCameraOrientation");
                if~isempty(args)
                    orientation=args.orientation;
                    orientation.heading=rad2deg(orientation.heading);
                    orientation.pitch=rad2deg(orientation.pitch);
                    orientation.roll=rad2deg(orientation.roll);
                else
                    orientation=globe.internal.GlobeOptions.DefaultCameraOrientation;
                end
            else
                orientation=globe.internal.GlobeOptions.DefaultCameraOrientation;
            end
        end

        function setCamera(controller,args)
            if~controller.LaunchWebWindow||~controller.AllowCameraMessages
                return
            end

            w=controller.WindowController;
            try
                if~controller.LaunchWebWindow||w.isVisible
                    data=struct('EnableWindowLaunch',false);
                    data.CameraPosition=args.CameraPosition;
                    data.CameraOrientation=args.CameraOrientation;
                    controller.visualRequest('setCamera',data);
                end
            catch e
                throwAsCaller(e)
            end
        end

        function close(controller)

            if~isempty(controller.RequestResponseSubscription)
                message.unsubscribe(controller.RequestResponseSubscription);
            end


            close(controller.WindowController)
        end


        function delete(controller)

            if~isempty(controller.RequestResponseSubscription)
                message.unsubscribe(controller.RequestResponseSubscription);
            end

            if~isempty(controller.GlobeModel)&&isvalid(controller.GlobeModel)
                delete(controller.GlobeModel)
            end


            w=controller.WindowController;
            if~isempty(w)&&isvalid(w)&&isValidWindow(w)
                delete(w)
            end
        end


        function showBusyMessage(controller,msg)


            try

                w=controller.WindowController;
                if~controller.LaunchWebWindow||w.isVisible
                    data=struct('Message',msg,...
                    'EnableWindowLaunch',false,...
                    'Animation','none');
                    controller.visualRequest('showBusyMessage',data);
                end
            catch e
                throwAsCaller(e)
            end
        end


        function hideBusyMessage(controller)


            try
                controller.removeVisualRequest('hideBusyMessage');
            catch e
                throwAsCaller(e)
            end
        end

        function visualRequest(controller,request,data)



            controller.waitForLaunch






            w=controller.WindowController;
            launchedInExternalBrowser=~controller.LaunchWebWindow;
            if(launchedInExternalBrowser||~w.isVisible)&&data.EnableWindowLaunch


                validateBasemapAccess(controller)





                if launchedInExternalBrowser
                    controller.updateMapConfiguration
                end
            end


            if launchedInExternalBrowser

                defaultAnimation='fly';
                responseFcn=@()onActionComplete(controller);
            elseif w.isVisible

                w.bringToFront;
                defaultAnimation='fly';
                responseFcn=@()onActionComplete(controller);
            else

                defaultAnimation='zoom';
                if data.EnableWindowLaunch
                    responseFcn=@()onLaunchVisualRequestComplete(controller);
                else
                    responseFcn=@()onActionComplete(controller);
                end
            end





            if~data.EnableWindowLaunch
                data.Animation='none';
            elseif isempty(data.Animation)
                data.Animation=defaultAnimation;
            end

            controller.request(request,data,@()onVisualRequestComplete(controller,responseFcn));
        end


        function removeVisualRequest(controller,request,data)



            w=controller.WindowController;
            if~controller.LaunchWebWindow||w.isVisible

                if controller.LaunchWebWindow
                    w.bringToFront;
                end

                if nargin<3
                    controller.request(request,@()onActionComplete(controller));
                else
                    controller.request(request,data,@()onActionComplete(controller));
                end
            end
        end
    end


    methods(Hidden)

        function updateMapConfiguration(controller)


            try


                config=mapConfiguration(controller.GlobeModel);


                if controller.TerrainClipping
                    config.ClipAgainstTerrain='on';
                end

                if controller.SwitchToHTTPS
                    index=config.BasemapSelectedIndex+1;
                    source=config.BasemapSources{index};
                    source.URL=replace(source.URL,'http:','https:');
                    config.BasemapSources{index}=source;
                end



                if controller.Launched||~controller.LaunchWebWindow
                    controller.request('setMapConfiguration',{config},@()onActionComplete(controller));
                end
            catch e
                throwAsCaller(e)
            end
        end


        function validateBasemapAccess(controller)








            url=controller.BasemapTileURL;
            controller.SwitchToHTTPS=false;
            if~isempty(url)
                usingHTTP=startsWith(url,'http:');
                if usingHTTP

                    httpsURL=replace(url,'http:','https:');
                    tf=globe.internal.GlobeModel.verifyConnection(httpsURL);
                    controller.SwitchToHTTPS=tf;
                    if~tf

                        tf=globe.internal.GlobeModel.verifyConnection(url);
                    end
                else

                    tf=globe.internal.GlobeModel.verifyConnection(url);
                end

                if~tf




                    fallbackBasemap='darkwater';
                    basemap=controller.GlobeModel.Basemap;
                    wstate=warning('off','backtrace');
                    C=onCleanup(@()warning(wstate));
                    warning(message('shared_globe:viewer:GlobeViewerNoInternet',...
                    fallbackBasemap,basemap));












                    controller.GlobeModel.Basemap=fallbackBasemap;
                end
            end
        end


        function terrainName=updateTerrain(controller,terrainName)









            oldTerrainName=controller.GlobeModel.TerrainName;
            if~strcmp(oldTerrainName,terrainName)
                controller.GlobeModel.TerrainName=terrainName;
                validateTerrainAccess(controller);
                terrainName=controller.GlobeModel.TerrainName;
                updateMapConfiguration(controller);
            end
        end

        function validateTerrainAccess(controller)






            if controller.UseTerrain&&~controller.GlobeModel.isTerrainURLAvailable
                wstate=warning('off','backtrace');
                C=onCleanup(@()warning(wstate));

                if controller.TerrainSource.IsURLLocation
                    warning(message("shared_globe:viewer:GlobeViewerTerrainNoInternet",...
                    controller.Terrain));
                else
                    warning(message("shared_globe:viewer:GlobeViewerTerrainFolderNotFound",...
                    controller.Terrain,controller.TerrainSource.Location));
                end







                controller.GlobeModel.TerrainName='none';
            end
        end


        function validateWebGraphicsSupport(controller)


            try


                isAlreadyLaunched=controller.Launched;


                if~feature('hasdisplay')
                    error(message('shared_globe:viewer:NoDisplay'));
                end


                if isempty(controller.IsWebGraphicsSupported)

                    controller.waitForLaunch;
                    if isappdata(groot,'GlobeViewerWebGraphicsSupport')
                        controller.IsWebGraphicsSupported=getappdata(groot,'GlobeViewerWebGraphicsSupport');
                    end
                end

                if~controller.IsWebGraphicsSupported
                    error(message('shared_globe:viewer:GlobeViewerUnsupportedWebGraphics'));
                end
            catch e


                if~isAlreadyLaunched&&controller.Launched
                    close(controller.WindowController);
                end

                if~isappdata(groot,'IgnoreGlobeViewerUnsupportedWebGraphics')
                    throwAsCaller(e)
                else
                    controller.LaunchWebWindow=false;
                end
            end
        end


        function waitForLaunch(controller)



            launchWindow=controller.LaunchWebWindow&&~controller.LaunchIsComplete;
            if launchWindow
                controller.IsActionComplete=false;
                controller.launch;
                controller.waitForAction;
                onLaunchComplete(controller);
                controller.LaunchIsComplete=true;
            end
        end


        function waitForAction(controller)



            maxTime=controller.RequestTimeout;
            timeStep=0.01;
            timeOut=waitFor(maxTime,timeStep,@()controller.IsActionComplete);

            if timeOut
                controller.IsActionComplete=true;
                error(message('shared_globe:viewer:GlobeViewerTimeout'));
            end
        end

    end


    methods


        function set.WindowController(controller,w)
            w.Title=controller.Name;
            w.Position=controller.Position;
            controller.pWindowController=w;
        end

        function w=get.WindowController(controller)
            w=controller.pWindowController;
        end

        function name=get.Name(controller)
            if controller.Launched
                name=controller.WindowController.Title;
            else
                name=controller.GlobeModel.Name;
            end
        end

        function set.Name(controller,name)
            if controller.Launched
                controller.WindowController.Title=name;
            end
            controller.GlobeModel.Name=name;
        end

        function v=get.CesiumVersion(controller)
            if isempty(controller.pCesiumVersion)
                v=controller.request("version",@()onActionComplete(controller));
                controller.pCesiumVersion=v;
            else
                v=controller.pCesiumVersion;
            end
        end

        function set.CesiumVersion(controller,v)
            controller.pCesiumVersion=v;
        end

        function pos=get.Position(controller)
            w=controller.WindowController;
            if~isempty(w)&&isvalid(w)
                pos=controller.WindowController.Position;
            else
                pos=controller.pPosition;
            end
        end

        function set.Position(controller,pos)
            w=controller.WindowController;
            if~isempty(w)&&isvalid(w)
                controller.WindowController.Position=pos;
            else




                validateattributes(pos,{'double'},...
                {'real','finite','nonsparse','size',[1,4]},'','Position');
            end
            controller.pPosition=pos;
        end

        function basemap=get.Basemap(controller)
            getBasemapFromViewer=~isempty(controller)&&isvalid(controller)...
            &&controller.Visible...
            &&logical(controller.GlobeModel.GlobeOptions.EnableBaseLayerPicker);
            if getBasemapFromViewer
                basemap=controller.request("getCurrentBasemap",@()onActionComplete(controller));





                if~isempty(basemap)
                    controller.GlobeModel.Basemap=basemap;
                end
            end
            basemap=controller.GlobeModel.Basemap;
        end

        function set.Basemap(controller,basemap)
            controller.GlobeModel.Basemap=basemap;
            usingBaseLayerPicker=logical(controller.GlobeModel.GlobeOptions.EnableBaseLayerPicker);
            if usingBaseLayerPicker


                updateMapConfiguration(controller);
            elseif controller.Launched


                validateBasemapAccess(controller)



                updateMapConfiguration(controller);
            end
        end

        function terrain=get.Terrain(controller)
            if strcmp(controller.TerrainSource,'none')
                terrain='none';
            else
                terrain=controller.TerrainSource.Name;
            end
        end

        function set.TerrainSource(controller,value)
            controller.GlobeModel.TerrainSource=value;
        end

        function source=get.TerrainSource(controller)
            source=controller.GlobeModel.TerrainSource;
        end

        function set.TerrainClipping(controller,clipping)
            forceClipping(controller,logical(clipping))
        end

        function clipping=get.TerrainClipping(controller)
            clipping=controller.pTerrainClipping;
        end

        function vis=get.Visible(controller)
            vis=controller.Launched&&controller.WindowController.isVisible;
        end

        function url=get.URL(controller)
            if~controller.UseDebug
                url=controller.ConnectorServiceProvider.URL;
            else
                url=controller.ConnectorServiceProvider.DebugURL;
            end
        end

        function url=get.BasemapTileURL(controller)




            basemap=controller.GlobeModel.Basemap;
            url=string.empty;
            if~isempty(basemap)
                s=settings;
                basemapGroups=s.shared.globe.basemaps;
                basemap=replace(basemap,"-","_");
                if isprop(basemapGroups,basemap)

                    basemapGroup=basemapGroups.(basemap);
                    if isprop(basemapGroup,'URL')
                        url=string(basemapGroup.URL.ActiveValue);
                    end
                else

                    group=matlab.internal.maps.BasemapSettingsGroup;
                    basemapGroups=readGroup(group);
                    if~isempty(basemapGroups)
                        basemapNames=basemapGroups(1).BasemapNames;
                        index=matches(basemapNames,basemap);
                        basemapGroup=basemapGroups(index);
                        if isscalar(basemapGroup)
                            parameterizedURL=basemapGroup.URL;
                            loc=matlab.graphics.chart.internal.maps.MapTileLocation(parameterizedURL);


                            y=0;
                            x=0;
                            z=0;
                            url=mapTileName(loc,y,x,z);
                            if~startsWith(url,'http')
                                url=string.empty;
                            end
                        end
                    end
                end
            end
        end


        function launch=get.Launched(controller)
            if~isempty(controller)&&isvalid(controller)
                w=controller.WindowController;
                launch=~isempty(w)&&isValidWindow(w);
            else
                launch=false;
            end
        end

        function useterrain=get.UseTerrain(controller)
            useterrain=~strcmp(controller.TerrainSource,'none');
        end

        function maxSize=get.MaxImageSize(controller)
            if isempty(controller.MaxImageSize)

                controller.waitForLaunch;
            end
            maxSize=controller.MaxImageSize;
        end
    end


    methods(Access=private)
        function onRequestComplete(controller)
            if~isempty(controller)&&isvalid(controller)
                controller.IsRequestComplete=true;
            end
        end

        function onActionComplete(controller)
            controller.IsActionComplete=true;
        end


        function onVisualRequestComplete(controller,responseFcn)








            isWaitingForZoom=@()ischar(controller.RequestResponseData)&&strcmp(controller.RequestResponseData,'waitForZoomTo');
            if isWaitingForZoom()
                waitFor(0.5,0.1,@()~isWaitingForZoom());
            end


            responseFcn();


            if isWaitingForZoom()
                waitFor(controller.RequestTimeout,0.1,@()~isWaitingForZoom());
            end
        end

        function onLaunchResponse(controller)





            readyResponseData=controller.RequestResponseData;
            controller.IsWebGraphicsSupported=readyResponseData.IsWebGraphicsSupported;
            controller.MaxImageSize=readyResponseData.MaxImageSize;
            controller.WebGraphicsErrorMessage=readyResponseData.WebGraphicsErrorMessage;
            controller.RequestResponseData=[];



            if controller.LaunchWebWindow
                onActionComplete(controller);
            else
                onLaunchComplete(controller);
            end
        end

        function onLaunchComplete(controller)



            validateTerrainAccess(controller)


            controller.updateMapConfiguration
        end


        function onLaunchVisualRequestComplete(controller)


            w=controller.WindowController;
            if isValidWindow(w)

                w.bringToFront;





                waitFor(0.5,0.1,@()w.isVisible);
            end
            onActionComplete(controller);
        end

        function onRequestResponse(controller,msg)
            isMessage=isstruct(msg);
            if isMessage&&isfield(msg,'Token')
                requestToken=msg.Token;
                if strcmp(requestToken,controller.RequestToken)




                    r=controller.RequestResponseFcn;
                    controller.RequestResponseFcn=[];


                    controller.RequestResponseData=msg.Message;


                    if~isempty(r)
                        r();
                    end
                    controller.RequestToken='';
                elseif strcmp(requestToken,'reloaded')





                    responseData=msg.Message;
                    resetView(controller,responseData)
                elseif controller.UseDebug
                    disp('Unexpected message:');
                    disp(msg)
                end
            elseif isMessage&&isfield(msg,'IsWebGraphicsSupported')

                controller.RequestResponseData=msg;
                onLaunchResponse(controller);
            elseif isMessage&&isfield(msg,'MouseData')
                notify(controller,'MouseEvent',globe.internal.MouseEventData(msg));
            elseif isMessage&&isfield(msg,'zoomLevel')
                model=controller.GlobeModel;
                basemap=msg.basemap;
                if isempty(basemap)
                    basemap=model.Basemap;
                end
                reader=model.ReaderMap(basemap);
                imgData=readSqlBlob(reader,msg.y,msg.x,msg.zoomLevel);


                data=struct('EnableWindowLaunch',true,...
                'Animation','none',...
                'imageArray',imgData,...
                'x',msg.x,...
                'y',msg.y,...
                'z',msg.zoomLevel,...
                'WaitForResponse',false);
                controller.visualRequest("onTileReady",data);
            elseif controller.UseDebug
                if(isfield(msg,'error'))
                    controller.ErrorResponseData=msg;
                    warning(message('shared_globe:viewer:GlobeViewerRuntimeError',...
                    msg.name,msg.message,msg.stack));
                else
                    disp('Unexpected message:');
                    disp(msg)
                end
            end
        end

        function resetView(controller,responseData)







            controller.AllowCameraMessages=false;


            basemap=responseData.Basemap;
            controller.GlobeModel.Basemap=basemap;
            updateMapConfiguration(controller);
            data=struct('EnableWindowLaunch',true,...
            'Animation','none');
            controller.visualRequest('show',data);


            position=responseData.Camera.Position;
            lat=position.latitude;
            lon=position.longitude;
            height=position.height;
            args.CameraPosition=[lat,lon,height];

            orientation=responseData.Camera.Orientation;
            args.CameraOrientation.Heading=orientation.heading;
            args.CameraOrientation.Pitch=orientation.pitch;
            args.CameraOrientation.Roll=orientation.roll;


            controller.AllowCameraMessages=true;
            setCamera(controller,args)


            notify(controller,'ReloadEvent');
        end
    end
end


function timeOut=waitFor(maxTime,timeStep,isCompleteFcn)

    timeoutNumSteps=maxTime/timeStep;
    numSteps=0;
    isComplete=isCompleteFcn();
    while~isComplete&&(numSteps<timeoutNumSteps)
        pause(timeStep);
        numSteps=numSteps+1;
        isComplete=isCompleteFcn();
    end

    timeOut=(numSteps>=timeoutNumSteps);
end
