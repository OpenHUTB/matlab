
classdef MatlabAPIJavaExceptionHandler<...
    matlab.internal.project.util.exceptions.ExceptionHandler

    methods(Access=public)
        function handled=handleException(~,exception)
            handled=false;
            if(strcmpi(exception.identifier,'MATLAB:Java:GenericException'))

                javaException=exception.ExceptionObject;

                if isa(javaException,'com.mathworks.toolbox.slproject.project.matlab.api.MatlabAPIJavaException')
                    import matlab.internal.project.util.exceptions.Prefs;

                    errorID=javaException.getMatlabID();
                    errorMsg=char(javaException.getLocalizedMessage());
                    processedException=MException(errorID,'%s',errorMsg);
                    if(~Prefs.ShortenStacks)
                        processedException=addCause(processedException,exception);
                    end
                    throw(processedException);
                end
            end
        end
    end

end

