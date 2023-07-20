classdef MlxFileType<evolutions.internal.filetypehandler.FileType




    methods
        function obj=MlxFileType(filePath)
            obj.FilePath=filePath;
        end

        function accept(obj,visitor)
            visitor.visit(obj);
        end
    end
end
