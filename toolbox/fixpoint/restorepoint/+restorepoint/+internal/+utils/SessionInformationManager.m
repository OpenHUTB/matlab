classdef(Sealed)SessionInformationManager<handle




    methods(Access=private)
        function obj=SessionInformationManager
            obj.Identifier=restorepoint.internal.utils.SessionIdentifier;
            obj.RestorePaths=restorepoint.internal.utils.RestorePointPaths;
            mlock;
        end
    end

    properties(GetAccess=private,SetAccess=private)
        Identifier restorepoint.internal.utils.SessionIdentifier
        RestorePaths restorepoint.internal.utils.RestorePointPaths
    end

    methods(Static)
        function currentSessionId=getSessionIdentifier
            persistent localObj
            if isempty(localObj)||~isvalid(localObj)
                localObj=restorepoint.internal.utils.SessionInformationManager;
            end
            currentSessionId=localObj.Identifier;
        end
        function restorePointPaths=getRestorePointPaths
            persistent localObj
            if isempty(localObj)||~isvalid(localObj)
                localObj=restorepoint.internal.utils.SessionInformationManager;
            end
            restorePointPaths=localObj.RestorePaths;
        end
    end
end


