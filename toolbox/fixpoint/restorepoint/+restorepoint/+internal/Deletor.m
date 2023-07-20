classdef Deletor<handle




    properties
FindStrategy
    end

    methods
        function obj=Deletor(findStrategy)
            if nargin>0
                obj.FindStrategy=findStrategy;
            else
                obj.FindStrategy=restorepoint.internal.delete.FindAllRestorePaths;
            end
        end

        function set.FindStrategy(obj,findStrategy)
            validateattributes(findStrategy,...
            {'restorepoint.internal.delete.FindStrategy'},{'nonempty'});
            obj.FindStrategy=findStrategy;
        end

        function run(obj,model)
            if nargin<2
                model=char.empty;
            end

            restorePaths=restorepoint.internal.utils.SessionInformationManager.getRestorePointPaths;
            filesToDelete=obj.FindStrategy.run(model);
            obj.deleteFiles(filesToDelete,restorePaths);
        end
    end

    methods(Static=true,Access=private)
        function deleteFiles(filesToDelete,restorePaths)
            for file=1:numel(filesToDelete)
                restorepoint.internal.Deletor.deleteIfExists(filesToDelete{file});
                restorePaths.deleteFromRestorePaths(filesToDelete{file});
            end
        end
        function deleteIfExists(file)
            if exist(file,'dir')==7
                rmdir(file,'s');
            end
        end
    end
end



