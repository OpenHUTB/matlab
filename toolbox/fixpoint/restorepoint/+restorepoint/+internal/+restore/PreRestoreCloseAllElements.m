classdef PreRestoreCloseAllElements<restorepoint.internal.restore.PreRestoreStrategy




    methods
        function run(obj,allRestoreData)
            restoreData=allRestoreData.ModelRestoreData;
            allFiles=restoreData.getOriginalFiles;
            obj.closeAllElements(allFiles,restoreData);
        end
    end

    methods(Static=true,Access=private)
        function closeAllElements(allFiles,restoreData)
            fileTypeHandler=restorepoint.internal.FileTypeHandler;
            for restoreIdx=1:numel(allFiles)
                curRestoreInfo=allFiles{restoreIdx};

                fileData=struct('CurrentFullFile',curRestoreInfo,'RestoreData',restoreData);
                fileTypeHandler.closeElements(fileData);
            end
        end
    end
end
