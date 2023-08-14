function output=processMatlabCall(fcnName,varargin)






    originalWarningState=warning('off','all');
    resetWarningState=onCleanup(@()warning(originalWarningState));

    try
        output=feval(fcnName,varargin{:});
    catch ex
        import com.mathworks.comparisons.util.WrappedMatlabExceptionMessage;
        newException=MException(...
        ex.identifier,...
        '%s',...
        char(WrappedMatlabExceptionMessage.encode(ex.identifier,ex.message))...
        );

        newException.addCause(ex);
        newException.throw();
    end
end