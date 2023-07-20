function warning(exception)





    w=warning('QUERY','BACKTRACE');
    warning('OFF','BACKTRACE');
    cleanup=onCleanup(@()warning(w.state,w.identifier));
    exception=prepareException(exception);
    handleException(exception);
end

function exception=prepareException(exception)
    import matlab.exception.JavaException;

    if isa(exception,'MException')
        return;
    end

    exception=matlab.exception.JavaException(...
    'MATLAB:Java:GenericException',...
    sprintf('%s',exception.getLocalizedMessage()),...
exception...
    );
end

function handleException(exception)
    import comparisons.internal.exception.MExceptionHandler;

    try
        MExceptionHandler().handleException(exception);
    catch formattedException
        builtin(...
        'warning',...
        formattedException.identifier,...
        '%s',...
        formattedException.message...
        );
    end
end
