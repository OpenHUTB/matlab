classdef MatFileType<evolutions.internal.filetypehandler.FileType





    methods
        function obj=MatFileType(filePath)
            obj.FilePath=filePath;
        end

        function accept(obj,visitor)
            visitor.visit(obj);
        end
    end
end
