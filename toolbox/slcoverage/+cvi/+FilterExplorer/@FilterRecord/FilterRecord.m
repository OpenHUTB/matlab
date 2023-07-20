classdef FilterRecord<handle




    properties(SetObservable=true)
        filterObj=[]
        uuid=''
        fileName=''
        fileDir=''
    end
    methods
        function obj=FilterRecord(filter,fileName)
            obj.filterObj=filter;
            obj.uuid=filter.getUUID;
            obj.fileName=fileName;
            [~,fullName]=SlCov.FilterEditor.findFile(fileName);
            obj.fileDir=fileparts(fullName);

        end
    end
end

