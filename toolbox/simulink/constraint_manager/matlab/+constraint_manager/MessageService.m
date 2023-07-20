

classdef MessageService<handle

    properties(SetAccess=private,GetAccess=public)
        m_URL;
        m_ChannelId;
        m_Subscriptions;
    end

    methods(Access=public)

        function obj=MessageService()
            connector.ensureServiceOn();

            obj.m_URL=connector.getUrl('/toolbox/simulink/constraint_manager/web/index.html');



            aNonce=regexp(obj.m_URL,'snc\=([a-zA-Z0-9]+)','tokens');
            assert(~isempty(aNonce));

            obj.m_ChannelId=['/constraint_manager/',aNonce{1}{1}];

            obj.m_Subscriptions=containers.Map('KeyType','char','ValueType','uint64');
        end

        function delete(this)
            aSubsciptions=this.m_Subscriptions.values();
            for i=1:length(aSubsciptions)
                message.unsubscribe(aSubsciptions(i));
            end
        end

        function[aURL]=getURL(this)
            aURL=this.m_URL;
        end

        function subscribe(this,aSubscriptionName,aOnSubscribeFcn)
            if~this.m_Subscriptions.isKey(aSubscriptionName)
                this.m_Subscriptions(aSubscriptionName)=message.subscribe([this.m_ChannelId,aSubscriptionName],aOnSubscribeFcn);
            end
        end

        function unsubscribe(this,aSubscriptionName)
            if this.m_Subscriptions.isKey(aSubscriptionName)
                message.unsubscribe(this.m_Subscriptions(aSubscriptionName));
                this.m_Subscriptions.remove(aSubscriptionName);
            end
        end

        function publish(this,aChannelName,aData)
            aFinalChannel=[this.m_ChannelId,aChannelName];
            message.publish(aFinalChannel,aData);
        end

    end

end

