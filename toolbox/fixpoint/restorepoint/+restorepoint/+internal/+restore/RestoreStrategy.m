classdef(Abstract)RestoreStrategy<handle




    methods
        function run(obj,allRestoreData)
            restorepoint.internal.utils.restoreWorkspace(allRestoreData.FullRestoreDir,allRestoreData.ModelRestoreData);

            obj.restoreFiles(allRestoreData.FilesToRestore,allRestoreData.ModelRestoreData);
        end
    end

    methods(Abstract,Access=protected)
        restoreFiles(obj,filesToRestore,modelRestoreData);
    end

end
