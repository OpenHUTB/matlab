classdef ExecutionExceptionHandler<...
    comparisons.internal.exception.AbstractJavaExceptionHandler




    properties(Constant,Access=private)
        InnerExceptionType='java.util.concurrent.ExecutionException';
    end

    properties(Access=private)
        DelegateHandler;
    end

    methods(Access=public)

        function obj=ExecutionExceptionHandler()
            import comparisons.internal.exception.ExecutionExceptionHandler;
            import comparisons.internal.exception.JavaExceptionHandler;

            obj@comparisons.internal.exception.AbstractJavaExceptionHandler(...
            ExecutionExceptionHandler.InnerExceptionType...
            );
            obj.DelegateHandler=JavaExceptionHandler();
        end

        function result=handleException(this,exception)
            innerException=this.transform(exception);
            result=this.DelegateHandler.handleException(innerException);
        end

    end

    methods(Access=private)

        function innerException=transform(this,exception)
            cause=this.getInnerCause(exception.ExceptionObject);
            innerException=matlab.exception.JavaException(...
            'MATLAB:Java:GenericException',...
            sprintf('%s',cause.getLocalizedMessage()),...
cause...
            );
            innerException=innerException.addCause(exception);
        end

        function cause=getInnerCause(~,exception)
            if isempty(exception.getCause())
                cause=exception;
                return;
            end
            cause=exception.getCause();
        end

    end

end