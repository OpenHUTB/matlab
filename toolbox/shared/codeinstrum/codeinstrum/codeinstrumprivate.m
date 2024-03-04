function varargout=codeinstrumprivate(funName,varargin)

    if strcmp(funName,'feature')
        funName='cifeature';
    end

    [varargout{1:nargout}]=feval(funName,varargin{1:end});
