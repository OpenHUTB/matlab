classdef(ConstructOnLoad)EventData<event.EventData




    properties(SetAccess=private)

Payload
    end

    methods
        function this=EventData(payload)
            this.Payload=payload;
        end
    end

end