function varargout=runInClass(className,functionName,varargin)





    functionStr=sprintf('%s.%s',className,functionName);
    if nargout>=1
        [varargout{1:nargout}]=feval(functionStr,varargin{:});
    else
        feval(functionStr,varargin{:});
    end

end