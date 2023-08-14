
classdef(ConstructOnLoad)ItemModifiedEvent<event.EventData
    properties

        Index;
        Data;
    end

    methods
        function this=ItemModifiedEvent(idx,data)
            this.Index=idx;
            this.Data=data;
        end
    end
end