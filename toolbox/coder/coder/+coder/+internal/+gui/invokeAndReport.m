function varargout=invokeAndReport(func,varargin)






    validateattributes(func,{'char'},{});
    ouputCount=nargout;

    if coder.internal.gui.debugmode
        try
            doInvoke();
        catch me
            coder.internal.gui.asyncDebugPrint(me);
            me.rethrow();
        end
    else

        doInvoke();
    end

    function doInvoke()
        if ouputCount>0
            [varargout{1:ouputCount}]=feval(func,varargin{:});
        else
            feval(func,varargin{:});
        end
    end
end
