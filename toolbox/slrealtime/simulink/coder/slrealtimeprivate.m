function varargout=slrealtimeprivate(varargin)











    nout=nargout;
    if nout==0
        feval(varargin{:});
    else
        [varargout{1:nout}]=feval(varargin{:});
    end
