classdef BlocksetDesigner<handle




    properties(SetAccess=private,GetAccess=private)
Subscription
SubscribeChannel
CEFWindow
IsDebug
Url
    end

    methods
        function obj=BlocksetDesigner(varargin)
            if nargin==1&&isequal(varargin{1},'debug')
                obj.IsDebug=true;
            else
                obj.IsDebug=false;
            end
            obj.SubscribeChannel='/blocksetdesigner/jspublish';
            obj.Subscription=message.subscribe(obj.SubscribeChannel,@(msg)obj.messageReceived(msg));

            ccallerFeatureControl=['&ccallersupport=',int2str(slfeature('EnableCCallerBlockInBSD'))];

            packagedSFunctionFeatureControl=['&packagedsfunctionsupport=',int2str(slfeature('EnablePackagedSFunctionInBSD'))];

            connector.ensureServiceOn;
            connector.newNonce;
            if obj.IsDebug
                obj.Url=connector.getUrl('toolbox/simulink/simulink/blocksetdesigner/web/index-debug.html');
            else
                obj.Url=connector.getUrl('toolbox/simulink/simulink/blocksetdesigner/web/index.html');
            end

            obj.Url=[obj.Url,ccallerFeatureControl,packagedSFunctionFeatureControl];

            obj.CEFWindow=matlab.internal.webwindow(obj.Url,matlab.internal.getDebugPort,'EnableZoom',true);
            obj.CEFWindow.Position=[300,250,1100,700];
            obj.CEFWindow.Title='Blocksetdesigner';
            obj.CEFWindow.CustomWindowClosingCallback=@(~,~)obj.cleanUp;
        end

        function delete(obj)
        end

        function view(obj)
            obj.CEFWindow.show();
            obj.CEFWindow.bringToFront();
            if obj.IsDebug
                obj.CEFWindow.executeJS('cefclient.sendMessage("openDevTools");');
            end

        end

        function result=messageReceived(obj,msg)

            result=Simulink.BlocksetDesigner.invokeCommand(msg);
        end

        function Url=getUrl(obj)

            Url=obj.Url;
        end

        function val=isValid(obj)
            val=obj.CEFWindow.isvalid()&&obj.CEFWindow.isWindowValid();
        end

        function cleanUp(obj)

            Simulink.BlocksetDesigner.BlockAuthoring.setgetMetaDataManager('');
            obj.CEFWindow.close();
            message.unsubscribe(obj.Subscription);
        end
    end

    methods(Static)
        function bsd=getInstance(openingMode)
            persistent localObj;
            if isempty(localObj)||~localObj.isValid()
                localObj=Simulink.BlocksetDesigner.BlocksetDesigner(openingMode);
            end
            bsd=localObj;
        end
    end


end
