classdef(Abstract)AbstractJavaExceptionHandler<...
    comparisons.internal.exception.AbstractExceptionHandler












    properties(Constant,Access=private)
        OuterExceptionType='matlab.exception.JavaException';
    end

    methods(Access=public)

        function obj=AbstractJavaExceptionHandler(innerExceptionType)

            obj@comparisons.internal.exception.AbstractExceptionHandler(...
innerExceptionType...
            );
        end

        function bool=canHandle(this,exception)
            if isa(exception,this.OuterExceptionType)
                bool=this.canHandle@comparisons.internal.exception...
                .AbstractExceptionHandler(exception.ExceptionObject);
                return;
            end

            bool=false;
        end

    end

end