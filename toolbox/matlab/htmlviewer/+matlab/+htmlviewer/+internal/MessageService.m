classdef MessageService<handle





    properties(Access=private)
Subscriptions
HTMLViewerManager
        IsServerMessageServiceStarted=false;
    end

    properties(SetAccess=private,GetAccess=public,Hidden)
        IsClientMessageServiceStarted=false;
    end

    methods(Hidden)
        function obj=MessageService()
            obj.HTMLViewerManager=matlab.htmlviewer.internal.HTMLViewerManager.getInstance();
            obj.Subscriptions=[];
        end

        function startService(obj)
            if~obj.IsServerMessageServiceStarted
                obj.IsServerMessageServiceStarted=true;
                obj.startChannelListeners();
            end
        end

        function resetClientMessageServiceStatus(obj)
            obj.IsClientMessageServiceStarted=false;
        end

        function pingClient(obj)
            if~obj.IsClientMessageServiceStarted
                obj.publishData('requestHTMLViewerReady',{});
            end
        end

        function publishData(~,channel,payload)
            message.publish(sprintf('/HTMLViewer/%s',channel),payload);
        end
    end

    methods(Access=private)
        function startChannelListeners(obj)
            obj.createCustomSubscription('receiveHTMLViewerReady',@obj.handleHTMLViewerReady);
            obj.createCustomSubscription('receiveHTMLText',@obj.handleHTMLTextData);
            obj.createCustomSubscription('receiveTitle',@obj.handleTitleData);
            obj.createCustomSubscription('receiveActiveViewer',@obj.handleLastActiveViewer);
            obj.createCustomSubscription('receiveOnClose',@obj.handleClose);

            obj.createCustomSubscription('requestMatlabColonExecution',@obj.handleMatlabColonExecution);
        end

        function createCustomSubscription(obj,channelName,callback)
            obj.Subscriptions(end+1)=message.subscribe(sprintf('/HTMLViewer/%s',channelName),@(msg)callback(msg.data));
        end

        function handleHTMLViewerReady(obj,~)
            if~obj.IsClientMessageServiceStarted
                obj.IsClientMessageServiceStarted=true;
            end

            obj.HTMLViewerManager.publishPendingOpenRequests();
        end

        function handleMatlabColonExecution(obj,data)
            obj.HTMLViewerManager.processMatlabColonRequest(data.command);
        end

        function handleHTMLTextData(obj,data)
            obj.HTMLViewerManager.updateHTMLTextData(data.HTMLText);
        end

        function handleTitleData(obj,data)
            obj.HTMLViewerManager.updateTitleData(data.Title);
        end

        function handleLastActiveViewer(obj,data)
            obj.HTMLViewerManager.updateLastActiveViewerID(data.ViewerID);
        end

        function handleClose(obj,data)
            obj.HTMLViewerManager.onHTMLPageCloseCompletion(data.ViewerID);
        end

        function delete(obj)
            if obj.IsServerMessageServiceStarted

                for subscription=obj.Subscriptions
                    message.unsubscribe(subscription);
                end
            end
        end
    end
end
