classdef(ConstructOnLoad)DeleteSignalEvent<event.EventData

    properties
DeleteIndices
    end

    methods
        function this=DeleteSignalEvent(deleteIndices)
            this.DeleteIndices=deleteIndices;
        end
    end
end