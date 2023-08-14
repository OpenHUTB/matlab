classdef MFileType<evolutions.internal.filetypehandler.FileType




    methods
        function obj=MFileType(filePath)
            obj.FilePath=filePath;
        end

        function accept(obj,visitor)
            visitor.visit(obj);
        end
    end
end
