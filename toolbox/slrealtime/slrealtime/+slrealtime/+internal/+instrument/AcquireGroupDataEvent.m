classdef(ConstructOnLoad)AcquireGroupDataEvent<event.EventData






    properties
AcquireGroupData
ExecTime
Map

    end
    methods
        function data=AcquireGroupDataEvent(ExecTime,AcquireGroupData,Map)
            data.ExecTime=ExecTime;
            data.AcquireGroupData=AcquireGroupData;
            data.Map=Map;
        end
    end
end
