classdef RestorePointRestoreData<restorepoint.internal.restore.RestoreDataStrategy




    properties(Access=private)
        Model char
    end

    methods
        function allRestoreData=run(obj)
            allRestoreData=restorepoint.internal.utils.RestoreData(obj.Model);
            obj.initializeRestoreData(allRestoreData);
        end

        function setModelName(obj,model)
            obj.Model=model;
        end
    end
    methods(Access=protected)
        function fullRestoreDir=getFullRestoreDir(~,model)
            fullRestoreDir=...
            restorepoint.internal.utils.getExistingRestorePointDirectoryForModel(model);
            if isempty(fullRestoreDir)
                DAStudio.error('SimulinkFixedPoint:restorepoint:NoValidRestorePoint',model);
            end
        end
    end
end


