classdef(Abstract)SummaryViewPayloadBuilder<matlab.internal.profileviewer.model.PayloadBuilder



    properties(Access=protected)
SummaryTablePayloadBuilder
    end

    methods(Access=protected)
        function config=customizeConfig(obj,config)



            summaryTableConfig=obj.SummaryTablePayloadBuilder.makeDefaultBuilderConfig();
            summaryTableConfig.WithMemoryData=config.WithMemoryData;
            obj.SummaryTablePayloadBuilder.configure(summaryTableConfig);
        end
    end

    methods
        function obj=SummaryViewPayloadBuilder(profileInterface,summaryTablePayloadBuilder)
            obj@matlab.internal.profileviewer.model.PayloadBuilder(profileInterface);
            obj.SummaryTablePayloadBuilder=summaryTablePayloadBuilder;
            mlock;
        end

        function payload=build(obj,profileInfo,timer,isProfilerInvoked,dataPayloadLoadState)
            obj.ensureIsConfigured();
            payload=obj.SummaryTablePayloadBuilder.build(profileInfo);
            payload.SessionType=obj.Config.SessionType;
            payload.Timer=timer;
            payload.ProfilerInvokedStatus=isProfilerInvoked;
            payload.DataPayloadLoadStatus=dataPayloadLoadState;
            payload.IsMemoryProfile=obj.Config.WithMemoryData;
        end
    end
    methods(Static)
        function config=makeDefaultBuilderConfig()



            config=matlab.internal.profileviewer.model.PayloadBuilder.makeDefaultBuilderConfig();
            config.SessionType='';
        end
    end
end
