classdef FindAllRestorePaths<restorepoint.internal.delete.FindStrategy




    methods
        function filesToDelete=run(obj,~)
            filesToDelete=obj.findFiles;
            filesToDelete=restorepoint.internal.utils.makeCell(filesToDelete);
        end
    end

    methods(Static=true,Access=private)
        function filesToDelete=findFiles
            restorePaths=...
            restorepoint.internal.utils.SessionInformationManager.getRestorePointPaths;
            filesToDelete=restorePaths.getAllPaths;
        end
    end
end
