classdef DefaultJavaExceptionHandler<...
    comparisons.internal.exception.AbstractJavaExceptionHandler




    properties(Constant,Access=private)
        InnerExceptionType='java.lang.Exception';
    end

    methods(Access=public)

        function obj=DefaultJavaExceptionHandler()
            import comparisons.internal.exception.DefaultJavaExceptionHandler;

            obj@comparisons.internal.exception.AbstractJavaExceptionHandler(...
            DefaultJavaExceptionHandler.InnerExceptionType...
            );
        end

        function result=handleException(this,exception)%#ok<STOUT,INUSL>
            jException=exception.ExceptionObject;
            mException=MException(...
            strrep(class(jException),'.',':'),...
            '%s',char(jException.getLocalizedMessage())...
            );
            mException=mException.addCause(exception);
            throw(mException);
        end

    end

end