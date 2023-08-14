classdef IdenticalFilesExceptionHandler<...
    comparisons.internal.exception.AbstractJavaExceptionHandler




    properties(Constant,Access=private)
        InnerExceptionType='com.mathworks.toolbox.rptgenxmlcomp.plugin.IdenticalFilesException';
    end

    methods(Access=public)

        function obj=IdenticalFilesExceptionHandler()
            import comparisons.internal.exception.IdenticalFilesExceptionHandler;

            obj@comparisons.internal.exception.AbstractJavaExceptionHandler(...
            IdenticalFilesExceptionHandler.InnerExceptionType...
            );
        end

        function result=handleException(~,exception)
            fprintf(1,'%s',exception.ExceptionObject.getLocalizedMessage());
            result=[];
        end

    end

end