classdef(Sealed)GlobalConfigWebService<codergui.internal.WebService





    properties(Constant,Access=private)
        REFRESH_CHANNEL="globalconfig/refresh"
        UPDATE_CHANNEL="globalconfig/update"
    end

    properties(Access=private)
WebClient
Subscription
ListenerHandle
SnapshotKeys
    end

    methods
        function start(this,client)
            this.WebClient=client;
            this.pushSnapshot();
            this.ListenerHandle=coderapp.internal.gc.ConfigurationFacade.addChangeListener(@(evt)this.onGlobalConfigChanged(evt));
            this.Subscription=this.WebClient.subscribe(this.REFRESH_CHANNEL,@(~)this.pushSnapshot());
        end

        function shutdown(this)
            this.ListenerHandle=[];
            this.WebClient.unsubscribe(this.Subscription);
        end

        function keys=get.SnapshotKeys(this)
            keys=this.SnapshotKeys;
            if isempty(keys)&&~iscell(keys)
                keys=fieldnames(coderapp.internal.gc.ConfigurationFacade.getCurrentSnapshot());
                this.SnapshotKeys=keys;
            end
        end
    end

    methods(Access=private)
        function onGlobalConfigChanged(this,evt)
            evtChanges=evt.Changes(ismember(evt.Keys,this.SnapshotKeys));
            filter=false(size(evtChanges));
            for i=1:numel(evtChanges)
                filter(i)=any(strcmp('Value',evtChanges(i).attributes));
            end
            if~any(filter)
                return
            end

            overlay=rmfield(coderapp.internal.gc.ConfigurationFacade.getCurrentSnapshot(),setdiff(this.SnapshotKeys,evt.Keys(filter)));
            this.WebClient.publish(this.UPDATE_CHANNEL,overlay);
        end

        function handleGetRequest(this,msg)
            if isfield(msg,'key')
                reply=coderapp.internal.gc.ConfigurationFacade.getValue(msg.key);
            else
                reply=coderapp.internal.gc.ConfigurationFacade.getCurrentSnapshot();
            end
            this.WebClient.publish(this.GET_CHANNEL+"reply",reply);
        end

        function pushSnapshot(this)
            this.WebClient.publish(this.UPDATE_CHANNEL,coderapp.internal.gc.ConfigurationFacade.getCurrentSnapshot(),true);
        end
    end
end