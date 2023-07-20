classdef MexFileType<restorepoint.internal.filetypehandler.FileType




    properties(SetAccess=private,GetAccess=public)
FileData
    end
    methods
        function obj=MexFileType(fileData)
            obj.FileData=fileData;
        end

        function accept(obj,visitor)
            visitor.visit(obj);
        end
    end
end