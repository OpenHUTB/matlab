classdef MatlabDataModel<matlab.internal.profileviewer.model.BaseDataModel...
    &matlab.internal.profileviewer.model.RunAndTimeModel





    properties(Constant)
        SESSION_TYPE='MATLAB'
        SESSION_TYPE_WITH_MEMORY='MATLAB_WITH_MEMORY'
    end

    properties(Access=protected,Transient,NonCopyable)
FlamegraphViewPayloadCache
FlamegraphPayloadBuilder
    end

    properties(Hidden,SetAccess=protected)
        IsFlamegraphViewPayloadStale=false
    end

    methods(Access=protected)
        function isCached=isSummaryViewPayloadCached(~,~)
            isCached=true;
        end

        function saveSummaryViewPayloadToCache(obj,summaryViewPayload,~)
            obj.SummaryViewPayloadCache=summaryViewPayload;
        end

        function payload=retrieveSummaryViewPayloadFromCache(obj,~)
            payload=obj.SummaryViewPayloadCache;
        end

        function profileInfo=processProfileInfo(~,profileInfo,~)

        end

        function config=configureSummaryViewPayloadBuilder(~,config,~)

        end

        function config=configureDetailViewPayloadBuilder(~,config,~,~)

        end

        function payload=buildCustomDetailTitlePayload(~,payload,~)

        end
    end


    methods
        function obj=MatlabDataModel(profileInterface)
            import matlab.internal.profileviewer.model.*

            landingViewPayloadBuilder=MatlabLandingViewBuilder(profileInterface);
            summaryViewPayloadBuilder=MatlabSummaryViewBuilder(profileInterface);
            detailViewPayloadBuilder=MatlabDetailViewBuilder(profileInterface);
            obj@matlab.internal.profileviewer.model.BaseDataModel(landingViewPayloadBuilder,...
            summaryViewPayloadBuilder,...
            detailViewPayloadBuilder,...
            profileInterface);
            obj.FlamegraphPayloadBuilder=FlamegraphPayloadBuilder(profileInterface);
            mlock;
        end
    end


    methods

        function functionTableItem=getFunctionTableItem(~,functionTable,functionIndex,~)
            functionTableItem=functionTable(...
            cellfun(@(x)isequal(x,functionIndex),{functionTable.FunctionIndex}));
        end

        function loadData(obj,profileInfo)
            obj.loadDataBaseImpl(profileInfo);
            obj.FlamegraphViewPayloadCache=obj.FlamegraphPayloadBuilder.build(obj.SummaryViewPayloadCache,profileInfo.FunctionHistory,...
            obj.HasProfileResumed,obj.IsDataPayloadLoaded);
        end

        function payload=getFlamegraphViewPayload(obj)


            if obj.IsFlamegraphViewPayloadStale
                obj.IsFlamegraphViewPayloadStale=false;

                functionHistory=obj.ProfileInterface.getFunctionHistory();
                summaryViewPayload=obj.getSummaryViewPayload();
                obj.FlamegraphViewPayloadCache=obj.FlamegraphPayloadBuilder.build(summaryViewPayload,functionHistory,...
                obj.HasProfileResumed,obj.IsDataPayloadLoaded);
            end
            payload=obj.FlamegraphViewPayloadCache;
        end

        function payload=getLandingViewPayload(obj)
            payload=obj.getLandingViewPayloadBaseImpl();
        end

        function payload=getSummaryViewPayload(obj)
            payload=obj.getSummaryViewPayloadBaseImpl();
        end

        function payload=getDetailViewPayload(obj,functionIndex)
            payload=obj.getDetailViewPayloadBaseImpl(functionIndex);
        end

        function payload=getProfileStatusPayload(obj)
            payload=obj.getProfileStatusPayloadBaseImpl();
        end

        function isStale=isProfileInfoStale(obj,profileInfo)
            isStale=obj.isProfileInfoStaleBaseImpl(profileInfo);
        end

        function payload=getSummaryTitlePayload(obj)
            payload=obj.getSummaryTitlePayloadBaseImpl();
        end

        function payload=getDetailTitlePayload(obj,functionIndex)
            payload=obj.getDetailTitlePayloadBaseImpl(functionIndex);
        end

        function setDataPayloadStaleState(obj,isStale)


            obj.IsSummaryViewPayloadStale=isStale;
            obj.IsFlamegraphViewPayloadStale=isStale;
            obj.IsLandingViewPayloadStale=isStale;
        end

        function flag=getDataPayloadStaleState(obj)
            flag=obj.IsSummaryViewPayloadStale||obj.IsFlamegraphViewPayloadStale||obj.IsLandingViewPayloadStale;
        end


        function sessionType=getSessionType(obj,isMemoryProfile,~)
            if isMemoryProfile
                sessionType=obj.SESSION_TYPE_WITH_MEMORY;
            else
                sessionType=obj.SESSION_TYPE;
            end
        end

        function status=isSameAsCurrentPayload(obj,newPayload)
            currentPayload=obj.getSummaryViewPayload();
            payloadFunctionTable=currentPayload.FunctionTable;
            if all(isfield(payloadFunctionTable,{'SelfTime','PlotData','FunctionIndex'}))
                payloadFunctionTable=rmfield(payloadFunctionTable,{'SelfTime','PlotData','FunctionIndex'});
            end
            if isfield(payloadFunctionTable,'SelfMemory')
                payloadFunctionTable=rmfield(payloadFunctionTable,'SelfMemory');
            end
            status=isequaln(payloadFunctionTable,newPayload.FunctionTable);
        end

        function summaryFunctionIndex=getSummaryFunctionIndex(~,~)
            summaryFunctionIndex=0;
        end
    end
end
