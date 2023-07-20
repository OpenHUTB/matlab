classdef ErrorType
    enumeration
        Runtime,
        Syntax,
None
    end
    methods
        function flag=isSyntaxError(obj)
            flag=(obj==matlab.internal.editor.ErrorType.Syntax);
        end

        function flag=isRuntimeError(obj)
            flag=(obj==matlab.internal.editor.ErrorType.Runtime);
        end

        function flag=isNonError(obj)
            flag=(obj==matlab.internal.editor.ErrorType.None);
        end

        function str=char(obj)
            import matlab.internal.editor.ErrorType
            switch obj
            case ErrorType.Runtime
                str='runtime';
            case ErrorType.Syntax
                str='syntax';
            case ErrorType.None
                str='';
            otherwise
                str='';
            end
        end
    end
end