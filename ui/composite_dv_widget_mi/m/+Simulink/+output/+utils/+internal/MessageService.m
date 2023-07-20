

classdef MessageService<handle

    properties(SetAccess=private,GetAccess=public)
        m_ChannelId;
        m_Subscriptions;
    end

    methods(Access=public)

        function obj=MessageService(uID)
            obj.m_ChannelId=['/dvwidget/',uID,'/'];
            obj.m_Subscriptions=containers.Map('KeyType','char','ValueType','uint64');
        end

        function delete(this)
            aSubscriptions=this.m_Subscriptions.values();
            for i=1:length(aSubscriptions)
                message.unsubscribe(aSubscriptions{i});
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

        function unsubscribeAll(this)
            aSubscriptionNames=this.m_Subscriptions.keys();
            for i=1:length(aSubscriptionNames)
                this.unsubscribe(aSubscriptionNames{i});
            end
        end

        function publish(this,aChannelName,aData)
            aFinalChannel=[this.m_ChannelId,aChannelName];
            message.publish(aFinalChannel,aData);
        end

    end

end
