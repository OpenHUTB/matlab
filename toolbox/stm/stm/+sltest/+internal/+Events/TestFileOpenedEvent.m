



classdef TestFileOpenedEvent<event.EventData
    properties
        FilePath(1,1)string;
    end

    methods
        function this=TestFileOpenedEvent(filePath)
            this.FilePath=filePath;
        end
    end
end
