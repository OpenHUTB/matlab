classdef RmiSlDataEvent<event.EventData

    properties
model
id
    end


    methods
        function this=RmiSlDataEvent(model,id)
            this.model=model;
            this.id=id;
        end
    end
end
