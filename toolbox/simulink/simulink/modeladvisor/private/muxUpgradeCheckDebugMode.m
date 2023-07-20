function varargout=muxUpgradeCheckDebugMode(action,varargin)







    persistent DEBUG_MODE

    varargout={};

    switch action

    case 'get',
        if isempty(DEBUG_MODE)
            varargout{1}=false;
        else
            varargout{1}=DEBUG_MODE;
        end

    case 'set',
        DEBUG_MODE=logical(varargin{1});

    otherwise,
        DAStudio.error('Simulink:tools:MAUnknownAction');
    end
