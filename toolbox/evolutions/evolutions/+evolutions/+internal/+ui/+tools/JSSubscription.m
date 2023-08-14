classdef JSSubscription<handle




    properties(Access=private)
Subscriptions
CallbackHandle
    end

    properties
        Enabled logical=true
    end

    methods
        function this=JSSubscription(channelName,callbackHandle,customEvent)

            this.CallbackHandle=callbackHandle;
            this.Subscriptions=message.subscribe(channelName+customEvent,...
            @(data)this.executeCallback(data));
        end

        function executeCallback(this,data)
            if this.Enabled
                this.CallbackHandle(data);
            end
        end

        function delete(this)
            message.unsubscribe(this.Subscriptions);
        end
    end

    methods(Static=true)
        function publish(channel,event,value)
            jsVal=struct('event',event,'value',value);
            message.publish(channel,jsVal);
        end
        function subscription=subscribe(~,channelName,callback,customEvent)
            subscription=evolutions.internal.ui.tools.JSSubscription(channelName,callback,customEvent);
        end
    end
end