function out=processJavaCall(javaCall,varargin)








    try
        if nargout==0
            javaCall();
        else
            out=javaCall();
        end

    catch exception
        try
            iProcessException(exception,varargin{:});
        catch innerException
            import matlab.internal.project.util.exceptions.Prefs;
            if(Prefs.ShortenStacks)
                innerException.throwAsCaller();
            else
                innerException.rethrow();
            end

        end
    end

end

function iProcessException(exception,varargin)

    handlers=iGetExceptionHandlers(varargin{:});

    for handlerIndex=1:numel(handlers)
        handled=handlers{handlerIndex}.handleException(exception);
        if(handled)
            return;
        end
    end

    rethrow(exception);
end


function handlers=iGetExceptionHandlers(varargin)

    import matlab.internal.project.util.exceptions.*;

    handlers{1}=MatlabAPIJavaExceptionHandler();
    handlers{2}=MatlabAPIMatlabExceptionHandler();
    handlers{3}=MatlabAPIMatlabWarningHandler();

    if(nargin>0)
        extraHandlers=varargin{1};
        for handlerIndex=1:numel(extraHandlers)
            assert(isa(extraHandlers{handlerIndex},...
            'matlab.internal.project.util.exceptions.ExceptionHandler'));
            handlers{end+1}=extraHandlers{handlerIndex};%#ok<AGROW>
        end
    end

end


