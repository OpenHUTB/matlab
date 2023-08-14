classdef InconsistencyCheckLogEntry


    properties
        Name=[];
        TypeName=[];
        checkId=[];
        TypeIndex=[];
        headerFilePath=[];
        InconsistencyInfo=[];
    end

    methods
        function obj=InconsistencyCheckLogEntry(name,typename,checkid,typeindex,headerFilePath,inconsistencyinfo)
            if(nargin>4)
                obj.Name=name;
                obj.TypeName=typename;
                obj.checkId=checkid;
                obj.TypeIndex=typeindex;
                obj.headerFilePath=headerFilePath;
                if(nargin>5)
                    obj.InconsistencyInfo=inconsistencyinfo;
                end
            end
        end
    end

end

