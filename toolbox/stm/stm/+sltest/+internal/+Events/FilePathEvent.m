



classdef FilePathEvent<event.EventData
    properties
        FilePath(1,1)string;
    end

    methods
        function this=FilePathEvent(filePath)
            this.FilePath=filePath;
        end
    end
end
