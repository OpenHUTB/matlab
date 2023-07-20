classdef SDIDispatcher<Simulink.sdi.internal.controllers.Dispatcher





    methods(Static)

        function ret=getDispatcher(bCreateIfNeeded)

            persistent ctrlsDispatcher
            mlock;

            if~nargin||bCreateIfNeeded
                if isempty(ctrlsDispatcher)||~isvalid(ctrlsDispatcher)
                    ctrlsDispatcher=Simulink.sdi.internal.controllers.SDIDispatcher;
                end
            end


            ret=ctrlsDispatcher;
        end


        function ret=isConstructed()


            obj=Simulink.sdi.internal.controllers.SDIDispatcher.getDispatcher(false);
            ret=~isempty(obj)&&isvalid(obj);
        end
    end


    methods(Hidden)


        function obj=SDIDispatcher(varargin)
            obj=obj@Simulink.sdi.internal.controllers.Dispatcher(varargin{:});
        end


        function delete(this)
            if~isempty(this.SubscriptionIDs)
                if connector.isRunning
                    cnt=this.SubscriptionIDs.getCount();
                    for idx=1:cnt
                        id=this.SubscriptionIDs.getDataByIndex(idx);
                        Simulink.sdi.unregisterMLSubscription(id);
                    end
                end
                this.SubscriptionCBs.Clear();
                this.SubscriptionIDs.Clear();
            end
        end


        function initSubscriptions(this,channelPrefix,setMessage,removeMessage)



            this.SubscriptionCBs=Simulink.sdi.Map('char',?handle);
            this.SubscriptionIDs=Simulink.sdi.Map('char',?handle);

            this.helperSubscribe(...
            [channelPrefix,setMessage],...
            @(arg)cb_NewClient(this,arg));
            this.helperSubscribe(...
            [channelPrefix,removeMessage],...
            @(arg)cb_RemoveClient(this,arg));
        end


        function helperSubscribe(this,channel,callback)


            id=Simulink.sdi.registerMLSubscription(channel);
            this.SubscriptionIDs.insert(channel,id);
            this.SubscriptionCBs.insert(channel,callback);
        end


        function helperUnsubscribe(this,channel)

            if this.SubscriptionIDs.isKey(channel)
                id=this.SubscriptionIDs.getDataByKey(channel);
                Simulink.sdi.unregisterMLSubscription(id);
                this.SubscriptionIDs.deleteDataByKey(channel);
                this.SubscriptionCBs.deleteDataByKey(channel);
            end
        end


        function handleNewMsg(this,channel,msg)
            if this.SubscriptionCBs.isKey(channel)
                data=jsondecode(msg);
                cb=this.SubscriptionCBs.getDataByKey(channel);
                cb(data);
            end
        end


        function helperPublishToClient(~,channel,messageObj)
            message.publish(channel,messageObj);
        end

    end


    methods(Static)


        function onNewMessage(channel,msg)
            dispatcher=Simulink.sdi.internal.controllers.SDIDispatcher.getDispatcher();
            dispatcher.handleNewMsg(channel,msg);
        end

    end


    properties(Access=private)
SubscriptionCBs
SubscriptionIDs
    end
end



