function[isPropagated,convertedModels]=propagateConfigSet(varargin)

































    switch nargout
    case{0,1}
        isPropagated=slprivate('propagateBDConfigSetImpl',varargin{:});
    case 2
        [isPropagated,convertedModels]=slprivate('propagateBDConfigSetImpl',varargin{:});
    end

end

