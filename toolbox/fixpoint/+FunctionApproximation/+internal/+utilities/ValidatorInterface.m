classdef(Abstract)ValidatorInterface<handle




    properties(SetAccess=protected)
        Diagnostic=MException.empty
    end

    methods
        success=validate(this,varargin);
    end
end
