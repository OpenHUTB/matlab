







function varargout=slccprivate(function_name,varargin)

    if(nargout>0)
        varargout=cell(1,nargout);
        [varargout{:}]=feval(function_name,varargin{:});
    else
        feval(function_name,varargin{:});
    end


