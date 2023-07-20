classdef CalculatePathRestorePoint<restorepoint.internal.create.CalculatePathStrategy




    methods
        function run(obj,restoreData)
            model=restoreData.OriginalModel;
            restoreData.RestoreDirectory=restorepoint.internal.utils.makeCell(obj.getStoreDirectoryForModel(model));

            restoreData.ExistingRestoreDir=...
            restorepoint.internal.utils.getExistingRestorePointDirectoryForModel(restoreData.OriginalModel);
        end
    end

    methods(Access=private)
        function storageDir=getStoreDirectoryForModel(~,model)
            modelFile=restorepoint.internal.utils.getFilePathForModel(model);
            modeChecksum=Simulink.getFileChecksum(modelFile);

            storageDir=...
            fullfile(restorepoint.internal.utils.getCurrentRestoreDir,modeChecksum);
        end
    end

end


