function varargout=evalprivate(varargin)

    if nargout>0
        [varargout{1:nargout}]=feval(varargin{:});
    else
        feval(varargin{:});
    end
end

