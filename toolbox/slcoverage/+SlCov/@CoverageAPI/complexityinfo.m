function varargout=complexityinfo(varargin)



























    try
        args=[{[]},varargin];
        narg=nargin+1;
        [varargout{1:nargout}]=SlCov.CoverageAPI.getComplexityInfoInternal(args{1:narg});
    catch Me
        throwAsCaller(Me);
    end



