classdef OtherFileType<evolutions.internal.filetypehandler.FileType




    methods
        function obj=OtherFileType(filePath)
            obj.FilePath=filePath;
        end

        function accept(obj,visitor)
            visitor.visit(obj);
        end
    end
end
