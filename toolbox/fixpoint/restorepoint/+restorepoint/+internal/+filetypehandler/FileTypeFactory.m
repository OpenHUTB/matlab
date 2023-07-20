classdef FileTypeFactory<handle




    methods(Static=true,Access=?restorepoint.internal.FileTypeHandler)
        function fileType=getFileType(fileData)
            [~,~,fileExtension]=fileparts(fileData.CurrentFullFile);
            switch fileExtension
            case{'.slx','.mdl'}
                fileType=restorepoint.internal.filetypehandler.ModelFileType(fileData);
            case{'.m','.mlx'}
                fileType=restorepoint.internal.filetypehandler.ScriptFileType(fileData);
            case '.sldd'
                fileType=restorepoint.internal.filetypehandler.DDFileType(fileData);
            case(['.',mexext])

                fileType=restorepoint.internal.filetypehandler.MexFileType(fileData);
            otherwise
                fileType=restorepoint.internal.filetypehandler.OtherFileType(fileData);
            end
        end
    end
end


