classdef Dispatcher<handle


    properties
Channel
CallbackMap
ReadyToShowChannel
    end

    methods

        function this=Dispatcher(channel)
            this.CallbackMap=struct;
            this.Channel=channel;
            this.ReadyToShowChannel=this.Channel+"/readyToShow";
        end

        function subscribeToClient(this,controllers)


            controllerNames=string(fieldnames(controllers));
            for ctrlIdx=1:numel(controllerNames)
                controller=controllers.(controllerNames{ctrlIdx});
                subscriptions=controller.Subscriptions;
                controllerID=controller.ControllerID;
                for subIdx=1:numel(subscriptions)
                    suscription=subscriptions(subIdx);
                    messageID=suscription.messageID;
                    subscriptionKey=controllerID+messageID;
                    this.CallbackMap.(subscriptionKey)=suscription.callback;
                end
            end
            this.helperSubscribeToClient(this.Channel,@this.onMessageFromClient);
        end

        function publishToClient(this,controllerID,messageID,data)
            messageObj.subscriptionKey=controllerID+messageID;
            messageObj.data=data;
            this.helperPublishToClient(this.Channel,messageObj);
        end

        function helperPublishToClient(~,channel,messageObj)
            message.publish(channel,messageObj);
        end

        function helperSubscribeToClient(~,channel,callback)
            message.subscribe(channel,callback);
        end

        function onMessageFromClient(this,args)
            subscriptionKey=string(args.controllerID)+string(args.messageID);
            callback=this.CallbackMap.(subscriptionKey);
            callback(args)
        end

        function subscribeToReadyToShow(this,callback)
            this.helperSubscribeToClient(this.ReadyToShowChannel,callback);
        end
    end
end