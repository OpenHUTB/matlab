classdef releasemanagerHTML<handle

    properties(SetAccess=protected)
cefObj
clientID
publishChannel
subscribeChannel
subscribeReleaseListChannelRM
publishReleaseListChannelRM
subscription
releaseListSubscription
releasemanagerInstance
listenerIds
launchListenerIds
    end

    methods

        function obj=releasemanagerHTML()
            obj.clientID=char(matlab.lang.internal.uuid);
            obj.publishChannel=strcat('/ReleaseManager/',obj.clientID,'/MATLAB');
            obj.subscribeChannel=strcat('/ReleaseManager/',obj.clientID,'/JS');
            obj.subscription=message.subscribe(obj.subscribeChannel,@(msg)obj.handleReady(msg));
            obj.subscribeReleaseListChannelRM=strcat('/ReleaseManager/',obj.clientID,'/ReleaseList/JS');
            obj.publishReleaseListChannelRM=strcat("/ReleaseManager/",obj.clientID,"/ReleaseList/MATLAB");
            obj.releaseListSubscription=message.subscribe(obj.subscribeReleaseListChannelRM,@(msg)obj.handleReleaseList(msg));
            obj.releasemanagerInstance=multivercosim.internal.releasemanager.getInstance();
            fcnHdl=@()multivercosim.internal.releasemanagerModel.updateView(obj.publishReleaseListChannelRM);
            obj.listenerIds=zeros(1,2);
            obj.listenerIds(1)=Simulink.CoSimServiceUtils.attachView(fcnHdl);






            fcnHdl=@()multivercosim.internal.releasemanagerModel.updateMdlRefDialog;
            obj.listenerIds(2)=Simulink.CoSimServiceUtils.attachView(fcnHdl);
            receiveLauncherChannel=strcat('/SLReleaseManager/MatlabLauncherResponse/',obj.clientID,'/CPP');
            obj.launchListenerIds=Simulink.CoSimServiceUtils.attachLaunchListener(receiveLauncherChannel);
        end


        function delete(obj)
            arrayfun(@(x)Simulink.CoSimServiceUtils.detachView(x),obj.listenerIds);
            arrayfun(@(x)Simulink.CoSimServiceUtils.detachLaunchListener(x),obj.launchListenerIds);
        end


        function createCEFObj(obj)
            if slsvTestingHook('MultiVerCosimGUIDebug')>0
                nurl=connector.getUrl('/toolbox/shared/multivercosim/web/index-debug.html');
            else
                nurl=connector.getUrl('/toolbox/shared/multivercosim/web/index.html');
            end
            urlWithPortID=[nurl,'&','UUID=',obj.clientID];
            cef=matlab.internal.webwindow(urlWithPortID,matlab.internal.getDebugPort);
            cef.Position=setDialogSize();
            cef.CustomWindowClosingCallback=@closeFunction;

            obj.cefObj=cef;
            if slsvTestingHook('MultiVerCosimGUIDebug')>0
                obj.cefObj.executeJS('cefclient.sendMessage("openDevTools");');
            end
        end

        function handleReady(obj,msg)
            msgCommand=msg.command;
            switch msgCommand
            case 'JS starts'
                obj.sendReadyNotification();
            case 'JS is ready'

                obj.releasemanagerInstance.initializeRM(obj.publishReleaseListChannelRM);
            case 'webwindow close request'
                obj.close();
            otherwise
            end
        end


        function handleReleaseList(obj,msg)
            obj.releasemanagerInstance.updateData(msg);
        end


        function view(obj)
            if isempty(obj.cefObj)||~obj.cefObj.isWindowValid
                obj.createCEFObj();
            end
            obj.cefObj.show();
            obj.cefObj.bringToFront();
        end


        function close(obj)
            if~isempty(obj.cefObj)
                obj.cefObj.close();
            end
        end



        function sendReadyNotification(obj)
            msg.command="MATLAB is ready";
            msg.currentrelease=matlabroot;
            message.publish(obj.publishChannel,msg);
        end

    end

    methods(Static)
        function releaseManagerHTML=getInstance()
            persistent localObj;
            if isempty(localObj)||~isvalid(localObj)
                localObj=multivercosim.internal.releasemanagerHTML();
            end
            releaseManagerHTML=localObj;
        end
    end



end

function dialogPos=setDialogSize()
    screenSize=get(0,'ScreenSize');
    dialogW=screenSize(3)/4;
    dialogH=screenSize(4)/2;


    dialogPos(1)=(screenSize(3)-dialogW)/2;
    dialogPos(2)=(screenSize(4)-dialogH)/2;
    dialogPos(3)=dialogW;
    dialogPos(4)=dialogH;
end


function closeFunction(obj,~)

    obj.hide();
    return;
end
