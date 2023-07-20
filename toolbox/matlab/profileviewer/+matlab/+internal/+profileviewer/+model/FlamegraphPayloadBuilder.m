classdef FlamegraphPayloadBuilder<matlab.internal.profileviewer.model.PayloadBuilder




    properties(Access=protected)
        PayloadFields={}
    end

    methods
        function obj=FlamegraphPayloadBuilder(profileInterface)
            obj@matlab.internal.profileviewer.model.PayloadBuilder(profileInterface);
            mlock;
        end

        function flamegraphViewPayload=build(obj,summaryViewPayload,functionHistory,...
            hasProfileResumed,isDataPayloadLoaded)
            historySize=obj.ProfileInterface.getHistorySize();

            if obj.isTimerCompatibleWithFlamegraph()
                flamegraphViewPayload=matlab.internal.profileviewer.parseProfileInfo(...
                summaryViewPayload,functionHistory,historySize,hasProfileResumed);
            else
                flamegraphViewPayload=matlab.internal.profileviewer.getEmptyFlamegraphPayload();
                flamegraphViewPayload.TimerIncompatible=true;
            end


            flamegraphViewPayload.Status=obj.getProfileStatusForFlamegraph();


            if~isempty(flamegraphViewPayload.data)
                flamegraphViewPayload.data.tooltipValue=summaryViewPayload.TotalTime;
            end

            flamegraphViewPayload.ProfilerInvokedStatus=obj.ProfileInterface.getProfilerInvokedStatus();
            flamegraphViewPayload.DataPayloadLoadStatus=isDataPayloadLoaded;
        end
    end

    methods(Hidden)
        function isCompatible=isTimerCompatibleWithFlamegraph(obj)
            isCompatible=false;
            timer=obj.ProfileInterface.getProfileTimer();




            if timer==3||timer==4
                isCompatible=true;
            end
        end

        function status=getProfileStatusForFlamegraph(obj)
            status.Timer=obj.ProfileInterface.getProfileTimer();
            status.HistoryTracking=obj.ProfileInterface.getHistoryTracking();
            status.HistorySize=obj.ProfileInterface.getHistorySize();
        end
    end
end
