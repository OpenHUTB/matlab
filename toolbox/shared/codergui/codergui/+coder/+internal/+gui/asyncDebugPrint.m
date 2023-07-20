function asyncDebugPrint(arg,varargin)


    if~coder.internal.gui.debugmode
        return;
    end

    if isa(arg,'MException')&&com.mathworks.toolbox.coder.util.InternalUtilities.isTest()
        com.mathworks.toolbox.coder.util.InternalUtilities.logErrorForTest(arg.getReport());
    else
        coder.internal.gui.asyncPrint(arg,varargin{:});
    end
end