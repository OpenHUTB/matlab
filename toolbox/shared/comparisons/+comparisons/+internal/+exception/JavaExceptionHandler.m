classdef(Sealed)JavaExceptionHandler<...
    comparisons.internal.exception.AbstractJavaExceptionHandler




    properties(Constant,Access=private)
        InnerExceptionType='java.lang.Exception';
        ExceptionHandlers=comparisons.internal.exception.JavaExceptionHandler.getExceptionHandlers();
    end

    methods(Access=public)

        function obj=JavaExceptionHandler()
            import comparisons.internal.exception.JavaExceptionHandler;

            obj@comparisons.internal.exception.AbstractJavaExceptionHandler(...
            JavaExceptionHandler.InnerExceptionType...
            );
        end

        function result=handleException(this,exception)
            for handler=this.ExceptionHandlers
                if handler.canHandle(exception)
                    result=handler.handleException(exception);
                    return;
                end
            end
        end

    end

    methods(Static,Access=private)

        function handlers=getExceptionHandlers()
            handlers=[...
            comparisons.internal.exception.NoSuitableComparisonTypeExceptionHandler(),...
            comparisons.internal.exception.ComparisonMatlabExceptionHandler(),...
            comparisons.internal.exception.IdenticalFilesExceptionHandler(),...
            comparisons.internal.exception.JMIExceptionHandler,...
            comparisons.internal.exception.ComparisonExceptionHandler(),...
            comparisons.internal.exception.ExecutionExceptionHandler(),...
            comparisons.internal.exception.DefaultJavaExceptionHandler()...
            ];
        end

    end

end