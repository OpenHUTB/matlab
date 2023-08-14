classdef FileTypeFactory<handle




    methods(Static=true)
        function fileType=getFileType(filepath)
            [~,~,fileExtension]=fileparts(filepath);
            switch fileExtension
            case{'.slx','.mdl'}
                fileType=evolutions.internal.filetypehandler.ModelFileType(filepath);
            case '.xml'
                fileType=evolutions.internal.filetypehandler.XMLFileType(filepath);
            otherwise
                fileType=evolutions.internal.filetypehandler.OtherFileType(filepath);
            end
        end
    end
end
