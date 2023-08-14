classdef(Sealed)SessionIdentifierManager<handle




    methods(Access=private)
        function obj=SessionIdentifierManager
            obj.Identifier=restorepoint.internal.utils.SessionIdentifier;
            mlock;
        end
    end

    properties(GetAccess=private,SetAccess=private)
        Identifier restorepoint.internal.utils.SessionIdentifier
    end

    methods(Static)
        function currentSessionId=getSessionIdentifier
            persistent localObj
            if isempty(localObj)||~isvalid(localObj)
                localObj=restorepoint.internal.utils.SessionIdentifierManager;
            end
            currentSessionId=localObj.Identifier;
        end
    end
end


