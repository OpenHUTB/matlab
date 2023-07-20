function varargout=dpigprivate(func,varargin)

    if nargout==0
        feval(func,varargin{:});
    else
        [varargout{1:nargout}]=feval(func,varargin{:});
    end
end
