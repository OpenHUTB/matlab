function varargout=unregisterplugins(varargin)

    if nargout==0
        ticcsext.Utilities.registerplugins(false);
    else
        [isok,msg]=ticcsext.Utilities.registerplugins(false);
        varargout{1}=isok;
        varargout{2}=msg;
    end


