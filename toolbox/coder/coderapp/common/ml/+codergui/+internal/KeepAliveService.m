classdef(Sealed)KeepAliveService<codergui.internal.WebService




    properties(SetAccess=immutable)
DisposeChannel
KeepAliveChannel
    end

    properties
        KeepAliveTime=30
    end

    properties(Access=private)
Client
DisposeSubscription
HeartbeatSubscription
Timer
    end

    methods
        function this=KeepAliveService(disposeChannel,keepAliveChannel)
            this.DisposeChannel=disposeChannel;
            this.KeepAliveChannel=keepAliveChannel;
        end

        function start(this,client)
            this.Client=client;
            this.DisposeSubscription=client.subscribe(this.DisposeChannel,@(msg)this.handleRequest(msg));
        end

        function shutdown(this)
            this.Client.unsubscribe(this.DisposeSubscription);
            this.Client.unsubscribe(this.HeartbeatSubscription);
            this.cancelTimer();
            this.DisposeSubscription=[];
            this.HeartbeatSubscription=[];
            this.Client=[];
        end
    end

    methods(Hidden)
        function setupTimer(this)
            if isempty(this.Timer)||~isvalid(this.Timer)
                this.Timer=timer('TimerFcn',@(~,~)codergui.WebClient.disposeById(this.Client.Id),...
                'StartDelay',this.KeepAliveTime);
                this.Timer.start();
            end
        end

        function cancelTimer(this)
            if~isempty(this.Timer)&&isvalid(this.Timer)
                this.Timer.stop();
                delete(this.Timer);
            end
        end

        function handleHeartbeatRequest(this,msg)
            if strcmp(msg,'alive')
                this.cancelTimer();
            end
        end

        function handleRequest(this,msg)
            if strcmp(msg,'disposed')
                this.HeartbeatSubscription=this.Client.subscribe(this.KeepAliveChannel,@(msg)this.handleHeartbeatRequest(msg));
                this.setupTimer();
            else
                this.cancelTimer();
                if strcmp(msg,'initialized')
                    this.Client.unsubscribe(this.HeartbeatSubscription);
                end
            end
        end
    end
end