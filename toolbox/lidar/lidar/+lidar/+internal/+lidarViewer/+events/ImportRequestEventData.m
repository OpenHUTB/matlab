classdef(ConstructOnLoad)ImportRequestEventData<event.EventData





    properties
        SourceFileType=''
        IsImportSuccess=[];
    end

    methods
        function data=ImportRequestEventData(sourceFileType,isImportSuccess)
            data.SourceFileType=sourceFileType;
            data.IsImportSuccess=isImportSuccess;
        end
    end

end