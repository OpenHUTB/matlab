function ccwarningid(id,varargin)




    btStruct=warning('QUERY','BACKTRACE');
    warning('OFF','BACKTRACE');
    warning(message(id,varargin{:}));
    warning(btStruct);


