classdef MatlabSummaryTableBuilder<matlab.internal.profileviewer.model.PayloadBuilder




    methods
        function obj=MatlabSummaryTableBuilder(profileInterface)
            obj@matlab.internal.profileviewer.model.PayloadBuilder(profileInterface);
            mlock;
        end

        function profileInfoPayload=build(obj,profileInfo)
            obj.ensureIsConfigured();
            profileInfoPayload=obj.addSelfTime(profileInfo);
            profileInfoPayload=obj.addTotalProfileTime(profileInfoPayload);
            if obj.Config.WithMemoryData
                profileInfoPayload=obj.addSelfMemory(profileInfoPayload);
            end
            profileInfoPayload=obj.addTotalTimePlotPercent(profileInfoPayload);
            profileInfoPayload=obj.addFunctionIndex(profileInfoPayload);
        end
    end



    methods(Hidden,Static)
        function profileInfo=addSelfTime(profileInfo)

            for i=1:length(profileInfo.FunctionTable)
                selfTime=profileInfo.FunctionTable(i).TotalTime-...
                sum([profileInfo.FunctionTable(i).Children.TotalTime]);
                profileInfo.FunctionTable(i).SelfTime=selfTime;
            end
        end

        function profileInfo=addSelfMemory(profileInfo)

            for i=1:length(profileInfo.FunctionTable)
                netMemory=profileInfo.FunctionTable(i).TotalMemAllocated-...
                profileInfo.FunctionTable(i).TotalMemFreed;
                childMemory=sum([profileInfo.FunctionTable(i).Children.TotalMemAllocated])-...
                sum([profileInfo.FunctionTable(i).Children.TotalMemFreed]);
                profileInfo.FunctionTable(i).SelfMemory=netMemory-childMemory;
            end
        end

        function profileInfo=addTotalTimePlotPercent(profileInfo)
            import matlab.internal.profileviewer.model.calculatePercentage;

            maxTotalTime=max([profileInfo.FunctionTable.TotalTime]);
            for i=1:length(profileInfo.FunctionTable)
                totalTime=profileInfo.FunctionTable(i).TotalTime;
                selfTime=profileInfo.FunctionTable(i).SelfTime;
                totalTimeRatioPercent=round(calculatePercentage(totalTime,maxTotalTime));
                selfTimeRatioPercent=round(calculatePercentage(selfTime,maxTotalTime));
                profileInfo.FunctionTable(i).PlotData=[selfTimeRatioPercent,totalTimeRatioPercent];
            end
        end

        function profileInfo=addFunctionIndex(profileInfo)

            indexData=num2cell(1:1:numel(profileInfo.FunctionTable));
            [profileInfo.FunctionTable(:).FunctionIndex]=indexData{:};
        end

        function profileInfo=addTotalProfileTime(profileInfo)
            totalProfileTime=0;
            if~isempty(profileInfo.FunctionTable)
                totalProfileTime=sum([profileInfo.FunctionTable.SelfTime]);
            end
            profileInfo.TotalTime=totalProfileTime;
        end
    end
end
