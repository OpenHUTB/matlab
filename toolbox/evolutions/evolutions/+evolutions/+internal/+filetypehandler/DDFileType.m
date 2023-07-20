classdef DDFileType<evolutions.internal.filetypehandler.FileType




    methods
        function obj=DDFileType(filePath)
            obj.FilePath=filePath;
        end

        function accept(obj,visitor)
            visitor.visit(obj);
        end
    end
end
