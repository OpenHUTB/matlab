function[success,mdlRefBlkH]=convertToModelReference(varargin)












































































































    switch nargout
    case 0
        slprivate('convertSSToModelReferenceImpl',varargin{:});
    case 1
        success=slprivate('convertSSToModelReferenceImpl',varargin{:});
    case 2
        [success,mdlRefBlkH]=slprivate('convertSSToModelReferenceImpl',varargin{:});
    end

end

