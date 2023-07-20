classdef EventData<simevents.EventDataCore





    properties(Access=public)
        Block;
        Storage;
        StorageIdx;
    end

    methods


        function obj=EventData(bdHandle)
            obj@simevents.EventDataCore(bdHandle);
        end

    end

end



