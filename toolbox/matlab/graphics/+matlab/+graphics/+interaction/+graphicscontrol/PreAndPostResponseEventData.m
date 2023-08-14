classdef PreAndPostResponseEventData<event.EventData




    properties
InteractionID
Action
    end

    methods
        function this=PreAndPostResponseEventData(id,action)
            this.InteractionID=id;
            this.Action=action;
        end
    end
end

