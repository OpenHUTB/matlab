function varargout=psbzmeter(varargin)





    if nargout==0,
        power_zmeter_pr(varargin{:});
    else
        [varargout{1:nargout}]=power_zmeter_pr(varargin{:});
    end