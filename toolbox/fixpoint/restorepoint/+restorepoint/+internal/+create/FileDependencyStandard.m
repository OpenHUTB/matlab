classdef FileDependencyStandard<restorepoint.internal.create.FileDependencyStrategy




    methods
        function run(obj,restoreData)








            load_system(restoreData.OriginalModel);
            [originalFiles,originalMissingFiles]=...
            dependencies.fileDependencyAnalysis(restoreData.OriginalModel,[],true);
            restoreData.OriginalFiles=...
            restorepoint.internal.utils.makeCell(originalFiles);
            restoreData.OriginalMissingFiles=...
            restorepoint.internal.utils.makeCell(originalMissingFiles);
            restoreData.OriginalNumDependencies=length(restoreData.OriginalFiles);
            restoreData.populateModelStateInfo;
            obj.findDirtyFiles(restoreData);
        end
    end

    methods(Access=protected)
        function findDirtyFiles(~,restoreData)
            restoreData.OriginalDirtyFiles=...
            restorepoint.internal.utils.findDirtyFiles(restoreData);
        end
    end

end


