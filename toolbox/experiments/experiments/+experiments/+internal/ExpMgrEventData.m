classdef(ConstructOnLoad)ExpMgrEventData<event.EventData




    properties
data
    end

    methods
        function this=ExpMgrEventData(evtData)
            this.data=evtData;
        end
    end
end
