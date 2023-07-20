classdef(ConstructOnLoad)SimTimeEventData<event.EventData




    properties
NewTime
    end

    methods
        function data=SimTimeEventData(newTime)
            data.NewTime=newTime;
        end
    end
end
