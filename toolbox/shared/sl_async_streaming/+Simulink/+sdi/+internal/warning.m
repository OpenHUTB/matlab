function warning(msg,varargin)



    sw=warning('OFF','BACKTRACE');
    if nargin>1
        warning(msg,varargin{:});
    else
        warning(msg);
    end
    warning(sw);
end
