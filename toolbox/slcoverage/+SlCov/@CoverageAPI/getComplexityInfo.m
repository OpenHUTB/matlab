



function varargout=getComplexityInfo(varargin)
    [status,msgId]=SlCov.CoverageAPI.checkCvLicense;
    if status==0
        error(message(msgId));
    end
    [varargout{1:nargout}]=SlCov.CoverageAPI.getComplexityInfoInternal(varargin{1:nargin});

