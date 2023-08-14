function result=process(task)







    try
        if nargout>0
            result=task();
        else
            task();
        end
    catch exception
        result=handle(exception);
    end
end

function result=handle(exception)
    import comparisons.internal.exception.MExceptionHandler;

    persistent ExceptionHandler;

    if isempty(ExceptionHandler)
        ExceptionHandler=MExceptionHandler();
    end

    result=ExceptionHandler.handleException(exception);
end