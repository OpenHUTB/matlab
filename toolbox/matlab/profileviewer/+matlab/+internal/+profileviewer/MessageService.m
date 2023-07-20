classdef MessageService<matlab.internal.profileviewer.ImplManagerClient




    properties(Access=private)
ProfileInterface
ProfilerState
ClientId
RequestDispatcher
Subscriptions
        IsStarted=false;
    end

    methods(Hidden)
        function obj=MessageService(clientId,implManager)
            obj@matlab.internal.profileviewer.ImplManagerClient(implManager);
            obj.ClientId=clientId;
            obj.Subscriptions=[];
            mlock;
        end

        function startService(obj)
            if~obj.IsStarted
                obj.IsStarted=true;
                obj.startChannelListeners();
            end
        end

        function refreshProfiler(obj)
            if~obj.IsStarted
                return;
            end

            obj.requestProfilerWindowRefresh;
        end

        function broadcastFunctionIndex(obj,functionIndex)
            if~obj.IsStarted
                return;
            end

            obj.handleFunctionIndexRequest(functionIndex);
        end

        function broadcastProfilerStateChanged(obj)
            if~obj.IsStarted
                return;
            end

            message.publish('/ProfileViewer/profilerStateChange',struct('payload',obj.ProfilerState.getState()));
        end

        function startProfilerViewerImplChannelListeners(obj)
            requestDispatcher=obj.ImplManagerInstance.getRequestDispatcherImpl();
            payloadRequestCallbackMap=requestDispatcher.getPayloadRequestCallbacks();
            customCallbackMap=requestDispatcher.getCustomRequestCallbacks();

            for requestName=keys(payloadRequestCallbackMap)
                callback=payloadRequestCallbackMap(requestName{1});
                obj.createPayloadRequestSubscription(requestName{1},@(data)callback(data));
            end
            for requestName=keys(customCallbackMap)
                callback=customCallbackMap(requestName{1});
                obj.createCustomSubscription(requestName{1},@(data)callback(data));
            end
            obj.ProfilerState.setProfilerViewerChannelsStarted(true)


            addlistener(obj.ProfileInterface,'ProfileInterfaceEvent',@obj.notifyProfileInterfaceEvent);
        end

        function broadcastRunAndTimeStart(obj)
            if~obj.IsStarted
                return;
            end
            message.publish(sprintf('/ProfileViewer/%s/receiveRunAndTimeStartStatus',obj.ClientId),true);
        end
    end

    methods(Access=protected)
        function onImplSwapOut(~)

        end

        function onImplSwapIn(obj)
            obj.ProfileInterface=obj.ImplManagerInstance.getProfileInterfaceImpl();
            obj.RequestDispatcher=obj.ImplManagerInstance.getRequestDispatcherImpl();
            obj.ProfilerState=obj.ImplManagerInstance.getProfilerState();


            if~obj.ProfilerState.getProfilerViewerChannelsStarted()
                obj.startProfilerViewerImplChannelListeners();
            end
        end

        function onClientRegistration(obj)
            obj.ProfileInterface=obj.ImplManagerInstance.getProfileInterfaceImpl();
            obj.RequestDispatcher=obj.ImplManagerInstance.getRequestDispatcherImpl();
            obj.ProfilerState=obj.ImplManagerInstance.getProfilerState();
        end
    end

    methods(Access=private)
        function unsubscribeChannelListeners(~,subscriptions)
            arrayfun(@(id)message.unsubscribe(id),subscriptions);
        end

        function startChannelListeners(obj)

            obj.startProfilerViewerImplChannelListeners();


            obj.createCustomSubscription('requestProfilerWindowRefresh',@(~)obj.requestProfilerWindowRefresh);
            obj.createCustomSubscription('requestFileOpen',@obj.handleFileOpenRequest);
            obj.createCustomSubscription('requestFileOpenToLine',@obj.handleFileOpenToLineRequest);
            obj.createCustomSubscription('requestProfileFunctionDocOpen',@obj.handleProfileFunctionDocOpen);
            obj.createCustomSubscription('requestProfilerDocOpen',@obj.handleProfilerDocOpen);
            obj.createCustomSubscription('requestCoverageReportLaunch',@obj.handleCoverageReportLaunch);
        end

        function notifyProfileInterfaceEvent(obj,~,eventData)
            message.publish(sprintf('/ProfileViewer/%s/receiveProfileInterfaceEvent',obj.ClientId),struct('action',eventData.getAction()));
        end

        function createPayloadRequestSubscription(obj,requestName,callback)
            obj.Subscriptions(end+1)=message.subscribe(sprintf('/ProfileViewer/%s/request%s',obj.ClientId,requestName),...
            @(messageToPublish)obj.handlePayloadRequest(requestName,messageToPublish,callback));
        end

        function handlePayloadRequest(obj,requestName,messageToPublish,callback)
            [payload,publish]=callback(messageToPublish.data);
            if publish
                message.publish(sprintf('/ProfileViewer/%s/receive%s',obj.ClientId,requestName),...
                struct('payload',{payload},'requestId',{messageToPublish.data.requestId}));
            end
        end

        function createCustomSubscription(obj,channelName,callback)
            obj.Subscriptions(end+1)=message.subscribe(sprintf('/ProfileViewer/%s/%s',obj.ClientId,channelName),@(msg)callback(msg.data));
        end

        function requestProfilerWindowRefresh(obj)





            refreshRequest=obj.RequestDispatcher.getRefreshWindowRequestPayload();
            message.publish(sprintf('/ProfileViewer/%s/receiveProfilerWindowRefresh',obj.ClientId),refreshRequest);
        end

        function handleFileOpenRequest(~,data)

            edit(data.fileName);
        end

        function handleFileOpenToLineRequest(~,data)

            opentoline(data.fileName,data.lineNumber);
        end

        function handleProfileFunctionDocOpen(~,data)
            doc(data.docPageCommand)
        end

        function handleProfilerDocOpen(~,data)

            if(strcmp(data.docType,'help'))
                helpview(fullfile(docroot,'matlab','helptargets.map'),data.docArg)
            elseif(strcmp(data.docType,'example'))
                openExample(data.docArg)
            end
        end

        function handleCoverageReportLaunch(~,data)

            coveragerpt(fileparts(data.fileName));
        end

        function handleFunctionIndexRequest(obj,functionIndex)

            message.publish(sprintf('/ProfileViewer/%s/receiveFunctionIndex',obj.ClientId),functionIndex);
        end

        function delete(obj)
            if obj.IsStarted

                obj.unsubscribeChannelListeners(obj.Subscriptions);
            end
        end
    end
end
