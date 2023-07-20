

classdef MessageService<handle

    properties(SetAccess=private,GetAccess=public)
        m_URL;
        m_DebugURL;
        m_ChannelId;
        m_Subscriptions;
    end

    methods(Access=public)

        function obj=MessageService()
            connector.ensureServiceOn();

            obj.m_URL=connector.getUrl('/toolbox/simulink/maskeditor/web/main/index.html');


            aNonce=regexp(obj.m_URL,'snc\=([a-zA-Z0-9]+)','tokens');


            if isempty(aNonce)
                aUUID=char(floor(9*rand(1,6))+65);
                obj.m_URL=strcat(obj.m_URL,'&snc=',aUUID);
                obj.m_ChannelId=strcat('/maskeditor/',aUUID);
            else
                obj.m_ChannelId=['/maskeditor/',aNonce{1}{1}];
            end

            obj.m_Subscriptions=containers.Map('KeyType','char','ValueType','uint64');
            obj.m_DebugURL=strrep(obj.m_URL,'index.html','index-debug.html');

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

        function[aURL]=getDebugURL(this)
            aURL=this.m_DebugURL;
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

