



classdef TestFileClosedEvent<event.EventData
    properties
        FilePaths(1,:)string;
    end

    methods
        function this=TestFileClosedEvent(filePaths)
            this.FilePaths=filePaths;
        end
    end
end
