classdef ModelFileType<evolutions.internal.filetypehandler.FileType




    methods
        function obj=ModelFileType(filePath)
            obj.FilePath=filePath;
        end

        function accept(obj,visitor)
            visitor.visit(obj);
        end
    end
end
