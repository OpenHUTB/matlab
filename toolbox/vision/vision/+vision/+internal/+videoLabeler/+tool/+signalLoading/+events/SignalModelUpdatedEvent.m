classdef(ConstructOnLoad)SignalModelUpdatedEvent<event.EventData

    properties
SignalModel
    end

    methods
        function this=SignalModelUpdatedEvent(model)
            this.SignalModel=model;
        end
    end
end