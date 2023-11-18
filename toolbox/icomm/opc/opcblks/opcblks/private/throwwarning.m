function throwwarning(varargin)

    warnState=warning('backtrace','off');
    warning(varargin{:});
    warning(warnState);