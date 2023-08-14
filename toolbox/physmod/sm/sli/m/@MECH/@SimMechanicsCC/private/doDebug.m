function isDebuggingOn=doDebug(varargin)




    persistent fDebug

    if nargin==1

        fDebug=varargin{1};

    end

    isDebuggingOn=fDebug;


