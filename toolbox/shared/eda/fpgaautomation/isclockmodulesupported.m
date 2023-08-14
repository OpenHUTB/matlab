function varargout=isclockmodulesupported(varargin)















    mlock;


    persistent clockModuleSupported;


    if isempty(clockModuleSupported)
        if any(strcmp(computer,{'PCWIN','PCWIN64'}))
            clockModuleSupported=true;
        else
            clockModuleSupported=false;
        end
    end

    if nargin==1
        clockModuleSupported=varargin{1};
        varargout={};
    else
        varargout={clockModuleSupported};
    end


