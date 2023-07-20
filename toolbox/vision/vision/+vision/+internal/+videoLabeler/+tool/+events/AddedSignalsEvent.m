classdef(ConstructOnLoad)AddedSignalsEvent<event.EventData

    properties
AddedSignals
TimeInfo
    end

    methods
        function this=AddedSignalsEvent(addedSignals,timeInfo)
            this.AddedSignals=addedSignals;
            this.TimeInfo=timeInfo;
        end
    end
end