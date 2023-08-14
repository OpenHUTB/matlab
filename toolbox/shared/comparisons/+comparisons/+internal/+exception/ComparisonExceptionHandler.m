classdef ComparisonExceptionHandler<...
    comparisons.internal.exception.AbstractJavaExceptionHandler




    properties(Constant,Access=private)
        InnerExceptionType='com.mathworks.comparisons.exception.ComparisonException';
    end

    methods(Access=public)

        function obj=ComparisonExceptionHandler()
            import comparisons.internal.exception.ComparisonExceptionHandler;

            obj@comparisons.internal.exception.AbstractJavaExceptionHandler(...
            ComparisonExceptionHandler.InnerExceptionType...
            );
        end

        function result=handleException(~,exception)%#ok<STOUT>
            identifier='comparisons:comparisons:ComparisonFailed';
            messageString=comparisons.internal.message(...
            'message',...
            identifier,...
            char(exception.ExceptionObject.getLocalizedMessage())...
            );
            mException=MException(...
            identifier,...
            '%s',messageString...
            );
            mException=mException.addCause(exception);
            throw(mException);
        end

    end

end