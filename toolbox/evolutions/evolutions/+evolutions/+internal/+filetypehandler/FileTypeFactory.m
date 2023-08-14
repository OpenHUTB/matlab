classdef FileTypeFactory<handle




    methods(Static=true,Access=?evolutions.internal.FileTypeHandler)
        function fileType=getFileType(filepath)
            [~,~,fileExtension]=fileparts(filepath);
            switch fileExtension
            case{'.slx','.mdl'}
                fileType=evolutions.internal.filetypehandler.ModelFileType(filepath);
            case '.m'
                fileType=evolutions.internal.filetypehandler.MFileType(filepath);
            case '.mlx'
                fileType=evolutions.internal.filetypehandler.MlxFileType(filepath);
            case '.sldd'
                fileType=evolutions.internal.filetypehandler.DDFileType(filepath);
            case '.mat'
                fileType=evolutions.internal.filetypehandler.MatFileType(filepath);
            case(['.',mexext])

                fileType=evolutions.internal.filetypehandler.MexFileType(filepath);
            otherwise
                fileType=evolutions.internal.filetypehandler.OtherFileType(filepath);
            end
        end
    end
end


