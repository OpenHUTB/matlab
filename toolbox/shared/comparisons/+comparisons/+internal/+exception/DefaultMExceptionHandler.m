classdef DefaultMExceptionHandler<...
    comparisons.internal.exception.AbstractExceptionHandler




    properties(Constant,Access=private)
        ExceptionType='MException';
    end

    methods(Access=public)

        function obj=DefaultMExceptionHandler()
            import comparisons.internal.exception.DefaultMExceptionHandler;
            obj@comparisons.internal.exception.AbstractExceptionHandler(...
            DefaultMExceptionHandler.ExceptionType...
            );
        end

        function result=handleException(~,exception)%#ok<STOUT>
            if isempty(exception.stack)
                exception.throw();
            else
                exception.rethrow();
            end
        end

    end

end