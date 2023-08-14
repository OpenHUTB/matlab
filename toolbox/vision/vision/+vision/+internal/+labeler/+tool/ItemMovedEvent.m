
classdef(ConstructOnLoad)ItemMovedEvent<event.EventData
    properties

Index
Data
    end

    methods
        function this=ItemMovedEvent(idx,data)
            this.Index=idx;
            this.Data=data;
        end
    end
end