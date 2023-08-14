classdef Dispatcher<handle




    properties
        Subscribers;
        AppInstanceId;
        MasterToken;
        baseMsg='sta'
    end

    methods

        function obj=Dispatcher(id)
            obj.AppInstanceId=id;
            obj.Subscribers=containers.Map('KeyType','char','ValueType','any');
            dispatcherMap=obj.getDispatcherMap();
            dispatcherMap.insert(obj.AppInstanceId,obj);
        end

        function delete(obj)
            dispatcherMap=Simulink.sta.Dispatcher.getDispatcherMap();
            if isvalid(dispatcherMap)
                if dispatcherMap.isKey(obj.AppInstanceId)
                    dispatcherMap.deleteDataByKey(obj.AppInstanceId);
                end
            end

            forceUnSubscribe(obj);
        end

        function status=logStatus(obj)
            status='';




            if isvalid(obj)
                tokenStatus='not empty';
                if isempty(obj.MasterToken)
                    tokenStatus='empty';
                end
                status=sprintf('\n\nDispatcher (%s) has %d remaining subscribers\nMasterToken is %s\n\n',...
                obj.AppInstanceId,length(obj.Subscribers),tokenStatus);
            end
        end

        function token=subscribe(obj,channel,callback)
            validateattributes(channel,{'char'},{});
            validateattributes(callback,{'function_handle'},{});
            subscribers=obj.Subscribers;
            assert(~subscribers.isKey(channel),'duplicate subscribers on channel "%s" not allowed',channel);
            if~subscribers.isKey(channel)
                if subscribers.length()==0
                    dispatchChannel=sprintf('/%s%s/dispatcher',obj.baseMsg,obj.AppInstanceId);
                    obj.MasterToken=message.subscribe(...
                    dispatchChannel,@(string)onNewMessage(obj,string));
                end
                obj.Subscribers(channel)=callback;
            end
            token=channel;
        end

        function publish(obj,viewName,channel,value)
            fullChannel=sprintf('/%s%s/%s%s',obj.baseMsg,obj.AppInstanceId,viewName,channel);
            message.publish(fullChannel,value);
        end

        function unsubscribe(obj,token)




            if isvalid(obj)
                subscribers=obj.Subscribers;
                if subscribers.isKey(token)
                    message.unsubscribe(token);
                    subscribers.remove(token);
                    if subscribers.length()==0
                        message.unsubscribe(obj.MasterToken);
                        obj.MasterToken=[];
                    end
                end
            end
        end


        function forceUnSubscribe(obj)

            subscribers=obj.Subscribers;
            allKeys=subscribers.keys;

            for kKey=1:length(allKeys)
                message.unsubscribe(allKeys{kKey});
                subscribers.remove(allKeys{kKey});
            end

            message.unsubscribe(obj.MasterToken);
            obj.MasterToken=[];
        end
    end

    methods

        function onNewMessage(obj,message)
            channel=message{1};
            message=message{2};
            obj.broadcastMessage(channel,message);
        end

        function broadcastMessage(obj,channel,message)
            if isvalid(obj)
                subscribers=obj.Subscribers;
                if subscribers.isKey(channel)
                    callback=subscribers(channel);
                    callback(message);
                end
            end
        end

    end

    methods(Static)

        function map=getDispatcherMap()
            persistent dispatcherMap;
            if isempty(dispatcherMap)
                dispatcherMap=Simulink.sdi.Map();
            end
            map=dispatcherMap;
        end

        function synchronousPublish(instanceId,channel,message)
            dispatcher=Simulink.sta.Dispatcher.getMatchingDispatcher(instanceId);
            dispatcher.broadcastMessage(channel,message);
        end

        function dispatcher=getMatchingDispatcher(instanceId)
            dispatcher=[];
            map=Simulink.sta.Dispatcher.getDispatcherMap();
            if map.isKey(instanceId)
                dispatcher=map.getDataByKey(instanceId);
            end
        end

    end

end

