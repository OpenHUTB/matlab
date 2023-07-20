classdef(Abstract)BaseDataModel<handle






    properties(Access=protected,Transient,NonCopyable)

SummaryViewPayloadCache
LandingViewPayloadCache

SummaryViewPayloadBuilder
DetailViewPayloadBuilder
LandingViewPayloadBuilder

ProfileInterface
    end


    properties(SetAccess=protected,Hidden)
        IsLandingViewPayloadStale=false
        IsSummaryViewPayloadStale=false
        IsDataPayloadStale=false
        IsDataPayloadLoaded=false
        HasProfileResumed=false
        InitialFunctionIndex=0
    end



    methods(Abstract)
        payload=getSummaryViewPayload(obj,~)
        payload=getLandingViewPayload(obj)
        payload=getDetailViewPayload(obj,functionIndex,~)
        payload=getSummaryTitlePayload(obj,~)
        payload=getDetailTitlePayload(obj,~)
        isSame=isSameAsCurrentPayload(obj,profileInfo)
        isStale=isProfileInfoStale(obj,profileInfo)
        summaryFunctionIndex=getSummaryFunctionIndex(obj,selectionIndex);
        payload=getSessionType(obj,isMemoryProfile,selectionIndex)
        setDataPayloadStaleState(obj,isStale)
        isStale=getDataPayloadStaleState(obj)
        functionTableItem=getFunctionTableItem(obj,functionTable,functionIndex,selectionIndex)
    end


    methods(Abstract,Access=protected)
        profileInfo=processProfileInfo(obj,profileInfo,selectionIndex)
        saveSummaryViewPayloadToCache(obj,summaryViewPayload,selectionIndex)
        payload=retrieveSummaryViewPayloadFromCache(obj,selectionIndex);
        isCached=isSummaryViewPayloadCached(obj,selectionIndex)
        config=configureSummaryViewPayloadBuilder(obj,config,profileInfo)
        config=configureDetailViewPayloadBuilder(obj,config,summaryViewPayload,varargin)
        payload=buildCustomDetailTitlePayload(obj,payload,functionTableItem)
    end



    methods(Access=protected)
        function obj=BaseDataModel(landingViewBuilder,summaryViewBuilder,...
            detailViewBuilder,profileInterface)
            obj.ProfileInterface=profileInterface;
            obj.LandingViewPayloadBuilder=landingViewBuilder;
            obj.SummaryViewPayloadBuilder=summaryViewBuilder;
            obj.DetailViewPayloadBuilder=detailViewBuilder;
            mlock;
        end

        function status=isProfileInfoStaleBaseImpl(obj,profileInfo)



            if isempty(obj.SummaryViewPayloadCache)
                status=true;
                return;
            end
            status=~obj.isSameAsCurrentPayload(profileInfo);
        end

        function payload=getLandingViewPayloadBaseImpl(obj)



            if obj.IsLandingViewPayloadStale
                obj.LandingViewPayloadCache=obj.LandingViewPayloadBuilder.build(obj.IsDataPayloadLoaded);
            end
            payload=obj.LandingViewPayloadCache;
        end

        function payload=getSummaryViewPayloadBaseImpl(obj,selectionIndex)


            if nargin==1
                selectionIndex=[];
            end


            if obj.IsSummaryViewPayloadStale||~obj.isSummaryViewPayloadCached(selectionIndex)
                profileInfo=obj.ProfileInterface.getProfileInfo();


                profileInfo=obj.processProfileInfo(profileInfo,selectionIndex);


                summaryViewPayload=obj.buildSummaryViewPayload(profileInfo,selectionIndex);


                obj.saveSummaryViewPayloadToCache(summaryViewPayload,selectionIndex);


                obj.IsSummaryViewPayloadStale=false;
            end


            payload=obj.retrieveSummaryViewPayloadFromCache(selectionIndex);
        end

        function payload=getDetailViewPayloadBaseImpl(obj,functionIndex,selectionIndex,varargin)





            if nargin==2
                selectionIndex=[];
            end


            summaryViewPayload=obj.getNonEmptySummaryViewPayload(selectionIndex);


            functionTableItem=obj.getFunctionTableItem(summaryViewPayload.FunctionTable,functionIndex,selectionIndex);


            defaultBuilderConfig=obj.DetailViewPayloadBuilder.makeDefaultBuilderConfig();
            defaultBuilderConfig.WithMemoryData=summaryViewPayload.IsMemoryProfile;
            defaultBuilderConfig.SessionType=summaryViewPayload.SessionType;


            config=obj.configureDetailViewPayloadBuilder(defaultBuilderConfig,summaryViewPayload,varargin{:});


            obj.DetailViewPayloadBuilder.configure(config);
            payload=obj.DetailViewPayloadBuilder.build(summaryViewPayload.FunctionTable,functionTableItem);
        end

        function payload=getProfileStatusPayloadBaseImpl(obj,selectionIndex)


            if nargin==1
                selectionIndex=[];
            end


            summaryViewPayload=obj.getNonEmptySummaryViewPayload(selectionIndex);


            payload.ProfilerInvokedStatus=summaryViewPayload.ProfilerInvokedStatus;
            payload.DataPayloadLoadStatus=summaryViewPayload.DataPayloadLoadStatus;
            payload.IsMemoryProfile=summaryViewPayload.IsMemoryProfile;
            payload.ProfilerType=obj.getSessionType(summaryViewPayload.IsMemoryProfile,selectionIndex);
        end

        function loadDataBaseImpl(obj,profileInfo,selectionIndex)



            if nargin==2
                selectionIndex=[];
            end


            profileInfo=obj.processProfileInfo(profileInfo,selectionIndex);

            if isfield(profileInfo,'FunctionHistory')
                profileInfo=rmfield(profileInfo,'FunctionHistory');
            end
            summaryViewPayload=obj.buildSummaryViewPayload(profileInfo,selectionIndex);
            obj.saveSummaryViewPayloadToCache(summaryViewPayload,selectionIndex);


            obj.LandingViewPayloadCache=obj.LandingViewPayloadBuilder.build(obj.IsDataPayloadLoaded);

        end

        function payload=buildSummaryViewPayload(obj,profileInfo,selectionIndex)

            timer=obj.ProfileInterface.getProfileTimer();
            isProfilerInvoked=obj.ProfileInterface.getProfilerInvokedStatus();


            defaultBuilderConfig=obj.SummaryViewPayloadBuilder.makeDefaultBuilderConfig();
            defaultBuilderConfig.WithMemoryData=obj.isMemoryProfile(profileInfo);
            defaultBuilderConfig.SessionType=obj.getSessionType(defaultBuilderConfig.WithMemoryData,selectionIndex);


            config=obj.configureSummaryViewPayloadBuilder(defaultBuilderConfig,profileInfo);


            obj.SummaryViewPayloadBuilder.configure(config);
            payload=obj.SummaryViewPayloadBuilder.build(profileInfo,timer,...
            isProfilerInvoked,obj.IsDataPayloadLoaded);
        end

        function payload=getSummaryTitlePayloadBaseImpl(obj,selectionIndex)

            if nargin==1
                selectionIndex=[];
            end

            summaryViewPayload=obj.getNonEmptySummaryViewPayload(selectionIndex);
            payload.TotalTime=summaryViewPayload.TotalTime;
            payload.SessionType=summaryViewPayload.SessionType;
        end

        function payload=getDetailTitlePayloadBaseImpl(obj,functionIndex,selectionIndex)

            if nargin==2
                selectionIndex=[];
            end

            summaryViewPayload=obj.getNonEmptySummaryViewPayload(selectionIndex);
            functionTableItem=obj.getFunctionTableItem(summaryViewPayload.FunctionTable,functionIndex,selectionIndex);
            if isempty(functionTableItem)
                payload=[];
                return;
            end
            payload.FunctionName=functionTableItem.FunctionName;
            payload.NumCalls=functionTableItem.NumCalls;
            payload.TotalTime=functionTableItem.TotalTime;
            if summaryViewPayload.IsMemoryProfile
                payload.TotalMemAllocated=functionTableItem.TotalMemAllocated;
                payload.TotalMemFreed=functionTableItem.TotalMemFreed;
                payload.PeakMem=functionTableItem.PeakMem;
            end
            payload.SessionType=summaryViewPayload.SessionType;
            payload=obj.buildCustomDetailTitlePayload(payload,functionTableItem);
        end

        function payload=getNonEmptySummaryViewPayload(obj,selectionIndex)


            if nargin==1
                selectionIndex=[];
            end

            payload=obj.getSummaryViewPayloadBaseImpl(selectionIndex);
            if isempty(payload)
                error(message('MATLAB:profiler:SummaryViewPayloadEmpty'));
            end
        end
    end



    methods
        function isEmpty=isSummaryCacheEmpty(obj)
            isEmpty=isempty(obj.SummaryViewPayloadCache);
        end

        function profileInterface=getProfileInterface(obj)
            profileInterface=obj.ProfileInterface;
        end

        function setInitialFunctionIndex(obj,functionIndex)
            obj.InitialFunctionIndex=functionIndex;
        end

        function initialIndex=getInitialFunctionIndex(obj)
            initialIndex=obj.InitialFunctionIndex;
        end

        function setPayloadStaleState(obj,stale)
            obj.IsDataPayloadStale=stale;
        end

        function out=getPayloadStaleState(obj)
            out=obj.IsDataPayloadStale;
        end

        function setDataPayloadLoadState(obj,status)
            obj.IsDataPayloadLoaded=status;
        end

        function out=getDataPayloadLoadState(obj)
            out=obj.IsDataPayloadLoaded;
        end

        function setProfileResumedState(obj,hasResumed)
            obj.HasProfileResumed=hasResumed;
        end
    end

    methods(Static)
        function isMemoryProfile=isMemoryProfile(profileInfo)
            isMemoryProfile=all(isfield(profileInfo.FunctionTable,{'TotalMemAllocated',...
            'TotalMemFreed'}));
        end

        function data=getRefreshData(~)
            data=[];
        end
    end
end
