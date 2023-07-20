classdef XMLFileType<evolutions.internal.filetypehandler.FileType





    methods
        function obj=XMLFileType(filePath)
            obj.FilePath=filePath;
        end

        function accept(obj,visitor)
            visitor.visit(obj);
        end
    end
end
