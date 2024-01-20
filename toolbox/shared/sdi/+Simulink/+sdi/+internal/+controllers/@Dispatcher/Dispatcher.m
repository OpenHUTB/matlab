classdef Dispatcher<handle

    methods(Abstract)
        initSubscriptions(this,channelPrefix,setMessage,removeMessage);
        helperSubscribe(this,channel,callback);
        helperPublishToClient(this,channel,messageObj);
        helperUnsubscribe(this,channel);
    end


    methods(Hidden)

        function this=Dispatcher()

            import Simulink.sdi.internal.controllers.Dispatcher;
            this.SubscribeCallbacks=Simulink.sdi.Map('char',?handle);
            this.RemoveCallbacks=Simulink.sdi.Map('char',?handle);
            this.ClientIDs=cell(0,0);
            this.initSubscriptions(Dispatcher.PublicChannel,...
            'set_clientID','remove_clientID');
        end


        function subscribe(this,callbackID,callback)
            this.SubscribeCallbacks.insert(callbackID,callback);
        end


        function publish(this,controllerID,messageID,data)

            for i=1:size(this.ClientIDs,2)
                this.publishToClient(...
                this.ClientIDs{i},controllerID,messageID,data);
            end
        end


        function publishToClient(...
            this,clientID,controllerID,messageID,data)

            import Simulink.sdi.internal.controllers.Dispatcher;
            messageObj.subscriptionKey=[controllerID,'/',messageID];
            messageObj.data=data;
            this.helperPublishToClient(...
            [Dispatcher.Channel,clientID],messageObj);
        end


        function cb_NewClient(this,clientID)

            import Simulink.sdi.internal.controllers.Dispatcher;

            this.ClientIDs{end+1}=clientID;
            channel=[Dispatcher.Channel,clientID];

            this.helperSubscribe(...
            channel,@(arg)cb_OnNewMessage(this,arg))
            messageObj.subscriptionKey='ack';
            messageObj.data=[];
            messageObj.clientID=clientID;
            this.helperPublishToClient(channel,messageObj);
        end


        function registerRemove(this,id,callback)
            this.RemoveCallbacks.insert(id,callback);
        end


        function cb_RemoveClient(this,clientID1)

            clientID=num2str(clientID1);
            import Simulink.sdi.internal.controllers.Dispatcher;
            indexToRemove=find(strcmp(this.ClientIDs,clientID)==1);
            c=this.RemoveCallbacks.getCount();
            if c>0
                for n=1:c
                    key=this.RemoveCallbacks.getKeyByIndex(n);
                    callbackMethod=this.RemoveCallbacks.getDataByKey(key);
                    callbackMethod(clientID);
                end
            end

            if~isempty(indexToRemove)
                this.ClientIDs(indexToRemove)=[];
                this.helperUnsubscribe([Dispatcher.Channel,clientID]);
            end
        end


        function cb_OnNewMessage(this,arg)

            if~isfield(arg,'controllerID')||strcmp(arg.controllerID,'messageDialog')
                return
            end
            callbackID=[arg.controllerID,'/',arg.messageID];
            if~this.SubscribeCallbacks.isKey(callbackID)
                warning('SDI DISPATCHER unknown callback: %s\n',callbackID);
                return
            end

            callbackMethod=...
            this.SubscribeCallbacks.getDataByKey(callbackID);
            ctrlArg=struct('clientID',arg.clientID,'data',arg.data);
            callbackMethod(ctrlArg);
        end


        function numClientIDs=getNumClientIDs(this)
            numClientIDs=length(this.ClientIDs);
        end

    end


    properties(Access=protected)
        ClientIDs;
    end


    properties(Access=private)
        SubscribeCallbacks;
        RemoveCallbacks;
        Subscriptions;
    end


    properties(Constant)
        PublicChannel='/sdi_public/';
        Channel='/sdi/';
    end
end

