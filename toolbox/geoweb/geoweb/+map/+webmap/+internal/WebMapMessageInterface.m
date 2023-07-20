classdef WebMapMessageInterface<handle




























    properties(SetAccess=private)




        ChannelID char
    end

    properties(Access=private)




        Initialized=false
    end

    properties(Access=private,Constant)

        ResponseChannelID='/geoweb/response'


        RequestChannelID='/geoweb/request'


        DelayInSeconds=.1


        MaxSecondsToPause=30
    end

    methods
        function wmmifc=WebMapMessageInterface(channelID)







            wmmifc.ChannelID=channelID;
        end


        function initialize(wmmifc)





            if~wmmifc.Initialized
                data=struct('channelID',wmmifc.ChannelID);
                message.publish([wmmifc.ResponseChannelID,'/setChannelID'],data)
                wmmifc.Initialized=true;
            end
        end


        function hweb=loadWebPage(wmmifc,webFcnHandle)


















            response=[];
            channel=message.subscribe(...
            requestChannel(wmmifc,'WebMapLoaded'),...
            @(msg)getWebMapLoadedCallback(msg));
            hweb=webFcnHandle();
            elapsedTime=0;


            while isempty(response)
                if elapsedTime>=wmmifc.MaxSecondsToPause
                    error(message('map:webmap:notFinishedLoading'))
                else
                    pause(wmmifc.DelayInSeconds)
                    elapsedTime=elapsedTime+wmmifc.DelayInSeconds;
                end
            end
            message.unsubscribe(channel)
            initialize(wmmifc);

            function getWebMapLoadedCallback(msg)
                response=msg;

            end
        end


        function setMapCenter(wmmifc,centerLat,centerLon,zoomLevel)










            if nargin==3
                zoomLevel=getZoomLevel(wmmifc);
            end
            data=struct(...
            'centerlat',centerLat,...
            'centerlon',centerLon,...
            'zoomlevel',zoomLevel);
            subscribeAndPublish(wmmifc,'setMapCenterStatus','setMapCenter',data);
        end


        function setMapLimits(wmmifc,latlim,lonlim)








            data=struct(...
            'southernlat',latlim(1),...
            'westernlon',lonlim(1),...
            'northernlat',latlim(2),...
            'easternlon',lonlim(2));
            subscribeAndPublish(wmmifc,'setMapLimitsStatus','setMapLimits',data);
        end


        function setZoomLevel(wmmifc,zoomLevel)






            data=struct('zoomlevel',zoomLevel);
            subscribeAndPublish(wmmifc,'setZoomLevelStatus','setZoomLevel',data);
        end


        function addVectorOverlay(wmmifc,filename,overlayname)








            data=struct('filename',filename,'overlayname',overlayname);
            subscribeAndPublish(wmmifc,'addVectorOverlayStatus','addVectorOverlay',data);
        end


        function removeVectorOverlay(wmmifc,overlaynumber)







            data=struct('overlaynumber',overlaynumber);
            subscribeAndPublish(wmmifc,...
            'removeVectorOverlayStatus','removeVectorOverlay',data);
        end


        function[centerLat,centerLon]=getMapCenter(wmmifc)





            response=subscribeAndPublish(wmmifc,'MapCenter','getMapCenter');
            centerLat=str2double(extractBefore(response,','));
            centerLon=str2double(extractAfter(response,','));
        end


        function[latlim,lonlim]=getMapLimits(wmmifc)





            response=subscribeAndPublish(wmmifc,'MapLimits','getMapLimits');
            limits=split(string(response),',');
            latlim=str2double(limits(2:2:end))';
            lonlim=str2double(limits(1:2:end))';
        end


        function zoomLevel=getZoomLevel(wmmifc)





            zoomLevel=subscribeAndPublish(wmmifc,'ZoomLevel','getZoomLevel');
        end
    end

    methods(Access=private)
        function channel=responseChannel(wmmifc,messageName)







            channel=[wmmifc.ResponseChannelID,'/',wmmifc.ChannelID,'/',messageName];
        end


        function channel=requestChannel(wmmifc,messageName)






            channel=[wmmifc.RequestChannelID,'/',messageName,'/*'];
        end


        function publish(wmmifc,messageName,data)







            initialize(wmmifc)
            message.publish(responseChannel(wmmifc,messageName),data)
        end


        function channel=subscribe(wmmifc,messageName,fcn)







            initialize(wmmifc)
            channel=message.subscribe(requestChannel(wmmifc,messageName),fcn);
        end


        function response=subscribeAndPublish(wmmifc,subscribeMessage,publishMessage,data)

















            channel=subscribe(wmmifc,subscribeMessage,@(msg)getSubscriberCallback(msg));
            response=[];
            elapsedTime=0;

            if nargin~=4
                data=0;
            end
            publish(wmmifc,publishMessage,data)


            while isempty(response)
                if elapsedTime>=wmmifc.MaxSecondsToPause
                    error(message('map:webmap:notFinishedLoading'))
                else
                    pause(wmmifc.DelayInSeconds)
                    elapsedTime=elapsedTime+wmmifc.DelayInSeconds;
                end
            end
            message.unsubscribe(channel)

            function getSubscriberCallback(msg)
                response=msg;
            end
        end
    end
end
