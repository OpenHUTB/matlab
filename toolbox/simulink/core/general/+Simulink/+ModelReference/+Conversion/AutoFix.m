




classdef AutoFix<handle
    properties(SetAccess=protected,GetAccess=public)
        IsModifiedSystemInterface=false;
    end

    methods(Abstract,Access=public)
        fix(this);
        results=getActionDescription(this);
    end
end
