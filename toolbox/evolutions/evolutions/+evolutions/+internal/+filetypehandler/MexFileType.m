classdef MexFileType<evolutions.internal.filetypehandler.FileType




    methods
        function obj=MexFileType(filePath)
            obj.FilePath=filePath;
        end

        function accept(obj,visitor)
            visitor.visit(obj);
        end
    end
end
