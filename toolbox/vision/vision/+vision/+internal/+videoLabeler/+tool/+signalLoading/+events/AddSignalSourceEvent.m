classdef(ConstructOnLoad)AddSignalSourceEvent<event.EventData

    properties
SignalSourceObj
    end

    methods
        function this=AddSignalSourceEvent(loaderObj)
            this.SignalSourceObj=loaderObj;
        end
    end
end