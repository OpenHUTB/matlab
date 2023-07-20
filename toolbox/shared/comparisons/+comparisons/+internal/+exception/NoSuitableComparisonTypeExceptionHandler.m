classdef NoSuitableComparisonTypeExceptionHandler<...
    comparisons.internal.exception.AbstractJavaExceptionHandler




    properties(Constant,Access=private)
        InnerExceptionType='com.mathworks.comparisons.main.NoSuitableComparisonTypeException';
    end

    methods(Access=public)

        function obj=NoSuitableComparisonTypeExceptionHandler()
            import comparisons.internal.exception.NoSuitableComparisonTypeExceptionHandler;

            obj@comparisons.internal.exception.AbstractJavaExceptionHandler(...
            NoSuitableComparisonTypeExceptionHandler.InnerExceptionType...
            );
        end

        function result=handleException(~,exception)%#ok<STOUT>
            jException=exception.ExceptionObject;
            mException=MException(...
            'comparisons:comparisons:UnknownComparisonType',...
            '%s',char(jException.getLocalizedMessage())...
            );
            mException=mException.addCause(exception);
            throw(mException);
        end

    end

end
