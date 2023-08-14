classdef(Sealed)RestorePointPaths<handle






    properties(GetAccess=private,SetAccess=private)
RestorePaths
    end

    methods(Access=?restorepoint.internal.utils.SessionInformationManager)
        function obj=RestorePointPaths
            obj.RestorePaths=containers.Map;
        end
    end
    methods
        function addToRestorePaths(obj,path)
            obj.RestorePaths(path)=1;
        end

        function deleteFromRestorePaths(obj,path)
            remove(obj.RestorePaths,path);
        end

        function allPaths=getAllPaths(obj)
            allPaths=keys(obj.RestorePaths);
        end
    end
end
