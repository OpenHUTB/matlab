classdef(ConstructOnLoad)CheckExecutionStartEventDataClass<event.EventData
    properties
        CheckID='';
        CheckTitle='';
        SystemName='';
    end
    methods
        function eventData=CheckExecutionStartEventDataClass(value1,value2,value3)
            eventData.CheckID=value1;
            eventData.CheckTitle=value2;
            eventData.SystemName=value3;
        end
    end
end
