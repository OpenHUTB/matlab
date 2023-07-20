
classdef AutoConvertExceptionHandler<...
    matlab.internal.project.util.exceptions.ExceptionHandler

    properties(Access=protected,Abstract)
        JavaClassName;
    end

    methods(Access=public)
        function handled=handleException(obj,exception)
            handled=false;
            if(strcmpi(exception.identifier,'MATLAB:Java:GenericException'))
                javaException=exception.ExceptionObject;
                if(isa(javaException,obj.JavaClassName));
                    handled=true;
                    id=javaException.getMatlabID();
                    msgArgs=obj.getMessageArguments(javaException);
                    matlabMessage=message(id,msgArgs{:});

                    obj.handleMessageAndID(matlabMessage.getString(),id,exception);

                end
            end
        end

    end

    methods(Access=private)
        function messageArgs=getMessageArguments(~,matlabAPIException)

            numberOfArguments=matlabAPIException.getNumberOfMessageArguments();
            messageArgs=cell(numberOfArguments,1);

            for argIndex=1:numberOfArguments
                messageArgs{argIndex}=...
                matlabAPIException.getMessageArgument(argIndex-1);
            end

        end
    end

    methods(Access=protected,Abstract)
        handleMessageAndID(obj,message,id,exception);
    end

end
