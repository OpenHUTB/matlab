classdef Subscription




    properties(SetAccess=private,GetAccess=public)
        Topic;
        QualityOfService;
        Callback;
        MQTTClient;
        DataManager;
    end

    properties(Access=private)
        SubscriptionListener;
    end

    methods
        function obj=Subscription(mqttClient,topic,QoS,callback)


            obj.MQTTClient=mqttClient;
            obj.Topic=topic;
            obj.QualityOfService=QoS;
            obj.Callback=callback;
            obj.DataManager=icomm.mqtt.DataManager;

            obj.SubscriptionListener=addlistener(obj.MQTTClient,'Custom',@obj.handleCustomEvent);


            subscribeOptions=[];
            subscribeOptions.Topic=obj.Topic;
            subscribeOptions.QoS=int32(obj.QualityOfService);


            obj.MQTTClient.execute("subscribeTopic",subscribeOptions);


            responseCode=obj.MQTTClient.subscribeResponseCode;
            if(responseCode~=icomm.mqtt.Utility.MQTTASYNC_SUCCESS)
                error(message('icomm_mqtt:Subscription:SubscribeAttemptFail',obj.Topic));
            end
        end

        function unsubscribe(obj)


            unsubscribeOptions=[];
            unsubscribeOptions.Topic=obj.Topic;
            obj.MQTTClient.execute("unsubscribeTopic",unsubscribeOptions)


            responseCode=obj.MQTTClient.unsubscribeResponseCode;
            if(responseCode~=icomm.mqtt.Utility.MQTTASYNC_SUCCESS)
                error(message('icomm_mqtt:Subscription:UnsubscribeAttemptFail',obj.Topic));
            end


            delete(obj.SubscriptionListener);
        end

        function[message]=read(obj,topic)

            message=read(obj.DataManager,topic);
        end

        function[message]=peek(obj,topic)

            message=peek(obj.DataManager,topic);
        end

        function flush(obj,topic)

            flush(obj.DataManager,topic);
        end


        function handleCustomEvent(obj,~,eventData)

            switch eventData.Type
            case 'MessageArrivedEvent'
                topic=eventData.Data.Topic;


                if~eventTopicBelongsToSubscription(topic,obj)
                    return;
                end


                data=eventData.Data.Message;
                obj.DataManager.storeData(topic,data);



                obj.MQTTClient.execute("clearAllBuffers",[])
                fireCallback=1;
            otherwise
                error(message('icomm_mqtt:Subscription:InvalidEventType'));
            end



            if isempty(obj.Callback)
                return
            end


            if fireCallback
                try
                    feval(obj.Callback,topic,data);
                catch
                    if isa(obj.Callback,'function_handle')
                        error(message('icomm_mqtt:Subscription:InvalidCallback',func2str(obj.Callback)))
                    end
                    error(message('icomm_mqtt:Subscription:InvalidCallback',obj.Callback))
                end
            end
        end
    end

    methods(Hidden=true)
        function delete(obj)
            try
                obj.unsubscribe();
            catch

            end
        end

    end
end

function flag=eventTopicBelongsToSubscription(topic,subscription)




    flag=false;


    if strcmpi(topic,subscription.Topic)
        flag=true;
        return;
    end


    if contains(subscription.Topic,'+')
        topics=strsplit(subscription.Topic,'+');
        if regexp(topic,[topics{1},'\w*',topics{2}])
            flag=true;
            return;
        end
    end


    if contains(subscription.Topic,'#')
        topicOfinterest=strsplit(subscription.Topic,'#');
        if contains(topic,topicOfinterest{1})
            flag=true;
            return;
        end
    end
end
