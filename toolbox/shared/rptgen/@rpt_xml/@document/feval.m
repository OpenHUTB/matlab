function varargout=feval(d,methodName,varargin)







    if any(strcmp(methods(d),methodName))
        if nargout==0
            builtin('feval',methodName,d,varargin{:});
        else
            varargout{1}=builtin('feval',methodName,d,varargin{:});
        end
    else
        if nargout==0
            javaMethod(methodName,d.Document,varargin{:});
        else
            varargout{1}=javaMethod(methodName,d.Document,varargin{:});
        end
    end
