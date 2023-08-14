

classdef(ConstructOnLoad)ImportFromDicomFolderEventData<event.EventData
    properties
DirectoryName
VolType
    end

    methods
        function data=ImportFromDicomFolderEventData(dirName,volType)
            data.DirectoryName=dirName;
            data.VolType=volType;
        end
    end
end