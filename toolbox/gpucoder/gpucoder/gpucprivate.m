function varargout=gpucprivate(varargin)




    if nargin<1,return;end
    switch varargin{1}
    case 'callfcn'
        varargout=cell(1,nargout);
        [varargout{:}]=feval(varargin{2},varargin{3:end});
    otherwise
        if nargout>0
            [varargout{1:nargout}]=feval(varargin{:});
        else
            feval(varargin{:});
        end
    end
