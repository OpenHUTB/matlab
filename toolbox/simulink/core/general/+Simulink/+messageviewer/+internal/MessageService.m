



classdef MessageService<handle

    properties(SetAccess=private,GetAccess=public)
        m_ChannelId;
        m_Subscriptions;
    end

    methods(Access=public)

        function obj=MessageService(aComponentId)
            obj.m_ChannelId=['/slmsgviewer/',aComponentId,'/'];
            obj.m_Subscriptions=containers.Map('KeyType','char','ValueType','uint64');
        end

        function delete(this)
            aSubscriptions=this.m_Subscriptions.values();
            for i=1:length(aSubscriptions)
                message.unsubscribe(aSubscriptions(i));
            end
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
            Simulink.output.connectorPublish(aFinalChannel,jsonencode(aData));
        end

    end

end
