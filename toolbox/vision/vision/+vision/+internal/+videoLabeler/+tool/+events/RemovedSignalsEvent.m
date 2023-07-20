classdef(ConstructOnLoad)RemovedSignalsEvent<event.EventData

    properties
RemovedSignals
        SignalsBeingAdded=false
    end

    methods
        function this=RemovedSignalsEvent(removedSignalNames,signalsBeingAdded)
            this.RemovedSignals=removedSignalNames;
            this.SignalsBeingAdded=signalsBeingAdded;
        end
    end
end