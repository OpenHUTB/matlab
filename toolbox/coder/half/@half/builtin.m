function[varargout]=builtin(fcn,varargin)
    try
        varargout{:}=feval(fcn,varargin{:});
    catch ex
        throwAsCaller(ex);
    end
end
