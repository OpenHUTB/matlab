function varargout=lu(varargin)



    A=single(varargin{1});
    [varargout{1:nargout}]=lu(A,varargin{2:nargin});
    for i=1:nargout
        varargout{i}=half(varargout{i});
    end

end