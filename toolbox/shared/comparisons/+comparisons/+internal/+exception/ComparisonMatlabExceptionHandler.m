classdef ComparisonMatlabExceptionHandler<...
    comparisons.internal.exception.AbstractJavaExceptionHandler




    properties(Constant,Access=private)
        InnerExceptionType='com.mathworks.comparisons.exception.ComparisonMatlabException';
    end

    methods(Access=public)

        function obj=ComparisonMatlabExceptionHandler()
            import comparisons.internal.exception.ComparisonMatlabExceptionHandler;

            obj@comparisons.internal.exception.AbstractJavaExceptionHandler(...
            ComparisonMatlabExceptionHandler.InnerExceptionType...
            );
        end

        function result=handleException(~,exception)%#ok<STOUT>
            jException=exception.ExceptionObject;
            mException=MException(...
            char(jException.getMatlabErrorID()),...
            '%s',char(jException.getLocalizedMessage())...
            );
            mException=mException.addCause(exception);
            throw(mException);
        end

    end

end