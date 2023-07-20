function varargout=chol(varargin)



    A=single(varargin{1});
    [varargout{1:nargout}]=chol(A,varargin{2:nargin});
    varargout{1}=half(varargout{1});

end
