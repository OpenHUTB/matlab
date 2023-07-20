classdef PreRestoreCloseModifiedElement<restorepoint.internal.restore.PreRestoreStrategy




    methods
        function run(obj,allRestoreData)
            filesToRestore=allRestoreData.FilesToRestore;
            dirtyFilesToClose=allRestoreData.DirtyFilesInModelHierarchy;
            allFilesToClose=[filesToRestore;dirtyFilesToClose];
            restoreData=allRestoreData.ModelRestoreData;
            if~isempty(allFilesToClose)
                obj.closeModifiedInMemoryElements(allFilesToClose,restoreData);
            end
        end
    end

    methods(Static=true,Access=private)
        function closeModifiedInMemoryElements(allFilesToClose,restoreData)
            fileTypeHandler=restorepoint.internal.FileTypeHandler;
            for restoreIdx=1:numel(allFilesToClose)
                curRestoreInfo=restorepoint.internal.utils.makeCell(allFilesToClose{restoreIdx});

                fileData=struct('CurrentFullFile',curRestoreInfo{1},'RestoreData',restoreData);
                fileTypeHandler.closeElements(fileData);
            end
        end
    end
end


