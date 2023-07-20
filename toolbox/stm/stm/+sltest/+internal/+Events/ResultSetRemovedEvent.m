



classdef ResultSetRemovedEvent<event.EventData
    properties
        UUID(1,:)string;
    end

    methods
        function this=ResultSetRemovedEvent(uuid)
            this.UUID=uuid;
        end
    end
end
