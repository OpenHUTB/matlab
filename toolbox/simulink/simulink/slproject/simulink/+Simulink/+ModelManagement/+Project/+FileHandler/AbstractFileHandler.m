classdef AbstractFileHandler




    methods(Abstract,Static)
        problemFiles=close(files);
        problemFiles=save(files);
        problemFiles=discardChanges(files);
        problemFiles=open(files);
    end

    methods(Access=protected)
        function fileTypes=createFileTypes(~,functionHandle,modelFiles)
            fileTypes=cellfun(functionHandle,modelFiles,'UniformOutput',false);
        end

        function successFlags=callOnEachFile(obj,fileTypes,fileTypeTransformer,functionHandle)
            successFlags=cellfun(@(x)obj.bulkOperation({x},fileTypeTransformer,functionHandle),fileTypes);
        end

        function successFlags=bulkOperation(~,fileTypes,fileTypeFilter,functionHandle)
            transformedFileTypes=cellfun(@(x)fileTypeFilter(x),fileTypes,'UniformOutput',false);
            successFlags=cellfun(@isempty,transformedFileTypes);
            reducedFileTypes=transformedFileTypes(~successFlags);
            [fileNames,filePaths]=cellfun(@(x)fileTypeTransformer(x),reducedFileTypes,'UniformOutput',false);

            try
                functionHandle(fileNames,filePaths);
            catch exception
                matlab.internal.project.logging.logException(exception);
                return;
            end

            successFlags=~successFlags;
        end
    end

end

function[fileName,filePath]=fileTypeTransformer(fileType)
    if isempty(fileType)
        fileName=[];
        filePath=[];
    else
        fileName=fileType.FileName;
        filePath=fileType.FilePath;
    end
end