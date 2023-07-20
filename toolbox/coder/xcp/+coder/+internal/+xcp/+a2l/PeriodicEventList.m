classdef PeriodicEventList<handle








    properties(SetAccess=immutable,GetAccess=public)
        TIDs;
        Rates;
        NumEvents;
    end

    methods(Access=public)
        function obj=PeriodicEventList(componentInterface)


            tids=componentInterface.TimingInternalIds;
            timingProperties=componentInterface.TimingProperties;

            isPeriodic=arrayfun(@(x)strcmp(x.TimingMode,'PERIODIC'),timingProperties);


            unsortedPeriodicTids=tids(isPeriodic);
            unsortedPeriodicTimingProperties=timingProperties(isPeriodic);


            [obj.TIDs,idx]=sort(unsortedPeriodicTids,'ascend');
            periodicTimingProperties=unsortedPeriodicTimingProperties(idx);
            obj.Rates=arrayfun(@(x)x.SamplePeriod,periodicTimingProperties);
            obj.NumEvents=numel(obj.Rates);
        end
    end
end