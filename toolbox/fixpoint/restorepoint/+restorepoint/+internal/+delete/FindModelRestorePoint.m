classdef FindModelRestorePoint<restorepoint.internal.delete.FindStrategy



    methods
        function filesToDelete=run(obj,model)
            filesToDelete=obj.findFiles(model);
            filesToDelete=restorepoint.internal.utils.makeCell(filesToDelete);
        end
    end

    methods(Static=true,Access=private)
        function filesToDelete=findFiles(model)
            filesToDelete=...
            restorepoint.internal.utils.getExistingRestorePointDirectoryForModel(model);
        end
    end
end