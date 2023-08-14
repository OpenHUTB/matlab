classdef(Abstract)AbstractExceptionHandler<...
    comparisons.internal.exception.ExceptionHandler




    properties(Access=private)
        ExceptionType;
    end

    methods(Access=public)

        function obj=AbstractExceptionHandler(type)
            obj.ExceptionType=type;
        end

        function bool=canHandle(this,exception)
            if isa(exception,this.ExceptionType)
                bool=true;
                return;
            end

            bool=false;
        end

    end

    methods(Abstract,Access=public)

        result=handleException(this,exception);

    end

end