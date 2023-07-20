function varargout=coder(varargin)








































    try
        varargout=codergui.evalprivate('codercommand',varargin{:});
    catch me
        if coderapp.internal.globalconfig('RethrowInternalErrors')
            me.rethrow();
        else
            me.throwAsCaller();
        end
    end
