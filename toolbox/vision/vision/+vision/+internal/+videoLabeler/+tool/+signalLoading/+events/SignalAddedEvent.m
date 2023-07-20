classdef(ConstructOnLoad)SignalAddedEvent<event.EventData

    properties
SignalInfoTable
    end

    methods
        function this=SignalAddedEvent(signalInfoTable)
            this.SignalInfoTable=signalInfoTable;
        end
    end
end