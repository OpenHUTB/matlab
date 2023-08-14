classdef(Sealed)ClientToServerLoggingService<codergui.internal.WebService&coderapp.internal.log.Loggable





    properties(Access=private)
Client
Subscription
    end

    methods
        function start(this,client)
            if isempty(client.Logger)||client.Logger.IsDummy
                return
            end
            this.Client=client;
            client.ClientParams.mirrorLog=true;
            this.Logger=this.Client.Logger.create('browser',this.LogLevel);
            this.Logger.LogCaller=false;
            this.Subscription=client.subscribe('log',@(msg)this.Logger.log(msg.level,msg.message));
        end

        function shutdown(this)
            if isempty(this.Client)
                return
            end
            this.Client.unsubscribe(this.Subscription);
            this.Client=[];
            this.Logger=coderapp.internal.log.DummyLogger.empty();
        end
    end
end