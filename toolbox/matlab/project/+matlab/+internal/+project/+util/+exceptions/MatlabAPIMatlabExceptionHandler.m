
classdef MatlabAPIMatlabExceptionHandler<...
    matlab.internal.project.util.exceptions.AutoConvertExceptionHandler

    properties(Access=protected)
        JavaClassName='com.mathworks.toolbox.slproject.project.matlab.api.MatlabAPIMatlabException'
    end

    methods(Access=protected)

        function handleMessageAndID(~,message,id,exception)
            import matlab.internal.project.util.exceptions.Prefs;

            processedException=MException(id,'%s',message);
            if(~Prefs.ShortenStacks)
                processedException=addCause(processedException,exception);
            end
            throw(processedException);

        end
    end

end
