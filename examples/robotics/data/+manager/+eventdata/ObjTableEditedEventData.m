classdef(ConstructOnLoad)ObjTableEditedEventData<event.EventData



    properties
NewVal
OldVal
    end

    methods
        function eventData=ObjTableEditedEventData(newVal,oldVal)
            eventData.NewVal=newVal;
            eventData.OldVal=oldVal;
        end
    end
end

