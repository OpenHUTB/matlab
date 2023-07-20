classdef(Abstract)AbstractRequestDispatcher<handle






    properties(SetAccess=protected,Hidden,Transient,NonCopyable)
ProfilerType
DataModel
ProfilerState
    end

    properties(Access=protected)
PayloadCallbackMap
CustomCallbackMap
    end

    methods(Abstract)
        getLandingViewPayload(data)
        getSummaryTitlePayload(data)
        getSummaryViewPayload(data)
        getDetailTitlePayload(data)
        getDetailViewPayload(data)
        getProfileStatusPayload(data)
        handleComparisonWindowLaunch(data)
    end

    methods(Hidden)
        function obj=AbstractRequestDispatcher(dataModel,profilerState,profilerType)
            obj.DataModel=dataModel;
            obj.ProfilerState=profilerState;
            obj.ProfilerType=profilerType;

            payloadNames={'LandingViewPayload',...
            'SummaryTitlePayload',...
            'SummaryViewPayload',...
            'DetailTitlePayload',...
            'DetailViewPayload',...
            'ProfileStatusPayload',...
            'ProfilerState'};
            payloadCallbacks={@(data)obj.executePayloadRequestCallback(data,@obj.getLandingViewPayload),...
            @(data)obj.executePayloadRequestCallback(data,@obj.getSummaryTitlePayload),...
            @(data)obj.executePayloadRequestCallback(data,@obj.getSummaryViewPayload),...
            @(data)obj.executePayloadRequestCallback(data,@obj.getDetailTitlePayload),...
            @(data)obj.executePayloadRequestCallback(data,@obj.getDetailViewPayload),...
            @(data)obj.executePayloadRequestCallback(data,@obj.getProfileStatusPayload),...
            @(data)obj.executePayloadRequestCallback(data,@obj.getProfilerState)};
            obj.PayloadCallbackMap=containers.Map(payloadNames,payloadCallbacks);

            customCallbacksNames={'requestComparisonWindowLaunch'};
            customCallbacks={@(data)obj.executeCustomRequestCallback(data,@obj.handleComparisonWindowLaunch)};
            obj.CustomCallbackMap=containers.Map(customCallbacksNames,customCallbacks);
            mlock;
        end

        function callbackMap=getPayloadRequestCallbacks(obj)
            callbackMap=obj.PayloadCallbackMap;
        end

        function callbackMap=getCustomRequestCallbacks(obj)
            callbackMap=obj.CustomCallbackMap;
        end
    end

    methods(Access=protected)
        function[payload,publish]=executePayloadRequestCallback(obj,data,callback)




            publish=false;
            payload=[];
            if strcmp(char(obj.ProfilerType),data.profilerType)
                payload=callback(data);
                publish=true;
            end
        end

        function executeCustomRequestCallback(obj,data,callback)
            if strcmp(char(obj.ProfilerType),data.profilerType)
                callback(data);
            end
        end

        function addCustomRequestDispatchers(obj,payloadNames,callbacks)
            for ii=1:numel(payloadNames)
                obj.CustomCallbackMap(payloadNames{ii})=callbacks{ii};
            end
        end

        function addPayloadRequestDispatchers(obj,payloadNames,callbacks)
            for ii=1:numel(payloadNames)
                obj.PayloadCallbackMap(payloadNames{ii})=callbacks{ii};
            end
        end

        function payload=getProfilerState(obj,~)
            payload=obj.ProfilerState.getState();
        end
    end

    methods(Hidden)
        function payload=getRefreshWindowRequestPayload(obj)
            payload=struct('profilerType',char(obj.ProfilerType),...
            'initialIndex',obj.DataModel.getInitialFunctionIndex(),...
            'profileStatus',obj.DataModel.getProfileStatusPayload(),...
            'metaData',obj.DataModel.getRefreshData());
        end
    end
end
