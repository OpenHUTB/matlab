classdef ServiceInterface<handle
    methods(Abstract)
        result=getResult(this,testId,filepath);
        results=getAllResults(this,filepath);
    end
    methods
        function fileTime=getTimestampFromFile(~,filepath)




            fileTime=datetime(NaT);
            fileInfo=dir(filepath);
            if~isempty(fileInfo)
                fileTime=datetime(fileInfo.datenum,'ConvertFrom','datenum','TimeZone','Local');
            end
        end
    end
end