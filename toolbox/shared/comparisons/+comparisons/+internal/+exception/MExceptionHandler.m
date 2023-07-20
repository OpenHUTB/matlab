classdef MExceptionHandler<...
    comparisons.internal.exception.ExceptionHandler




    properties(Access=private)
        ExceptionHandlers;
    end

    methods(Access=public)

        function obj=MExceptionHandler()
            import comparisons.internal.exception.MExceptionHandler;
            obj.ExceptionHandlers=MExceptionHandler.getExceptionHandlers();
        end

        function bool=canHandle(this,exception)%#ok<INUSD>
            bool=true;
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
            comparisons.internal.exception.JavaExceptionHandler(),...
            comparisons.internal.exception.DefaultMExceptionHandler()...
            ];
        end

    end

end