classdef(Abstract)RestoreDataStrategy<handle



    methods(Abstract,Access=public)
        allRestoreData=run(obj)
    end

    methods(Abstract,Access=protected)
        getFullRestoreDir(obj,model)
    end

    methods(Access=protected)
        function initializeRestoreData(obj,allRestoreData)
            allRestoreData.FullRestoreDir=obj.getFullRestoreDir(allRestoreData.Model);
            allRestoreData.ModelRestoreData=obj.getModelRestoreData(allRestoreData.FullRestoreDir);
            [allRestoreData.FilesToRestore,allRestoreData.FilesThatCannotBeRestored]=...
            restorepoint.internal.utils.findFilesForRestore(allRestoreData.ModelRestoreData);
            allRestoreData.DirtyFilesInModelHierarchy=...
            restorepoint.internal.utils.findDirtyFiles(allRestoreData.ModelRestoreData);
        end

        function modelRestoreData=getModelRestoreData(~,fullRestoreDir)
            restoreDataFile=fullfile(fullRestoreDir,'restoreData.mat');

            modelRestoreData=importdata(restoreDataFile);
        end
    end


end
