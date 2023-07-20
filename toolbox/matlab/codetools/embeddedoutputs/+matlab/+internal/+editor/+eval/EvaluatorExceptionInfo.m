classdef EvaluatorExceptionInfo



    properties(Constant,Access=private)
        UNSUPPORTED_LANGUAGE_OP='MATLAB:lang:UnsupportedOperation';
        GRAPHICS_USER_BREAK='MATLAB:handle_graphics:exceptions:UserBreak';
        UNDEFINED_FUNCTION='MATLAB:UndefinedFunction';
        PREVIOUSLY_ACCESSIBLE_FILE='MATLAB:err_parse_cannot_access_previously_accessible_file';
    end

    properties
exception
runningScript
    end

    methods(Hidden)
        function obj=EvaluatorExceptionInfo(mException,runningScript)
            obj.exception=mException;
            obj.runningScript=runningScript;
        end
    end

    methods(Access=public)
        function shouldIgnore=shouldIgnoreError(obj)
            shouldIgnore=strcmp(obj.exception.identifier,obj.UNSUPPORTED_LANGUAGE_OP)...
            ||strcmp(obj.exception.identifier,obj.GRAPHICS_USER_BREAK);
        end

        function isUnfound=isUnfoundFile(obj)
            isUnfound=obj.doesMessageContainRunningFile()&&...
            (strcmp(obj.exception.identifier,obj.UNDEFINED_FUNCTION)||...
            strcmp(obj.exception.identifier,obj.PREVIOUSLY_ACCESSIBLE_FILE));
        end

        function isSyntax=isSyntaxError(obj)

            isSyntax=obj.doesMessageContainRunningFile();
        end
    end

    methods(Access=private)
        function flag=doesMessageContainRunningFile(obj)
            flag=contains(obj.exception.message,obj.runningScript);
        end
    end
end
