classdef EvaluationEndInfo<handle

    properties
DidRunToCompletion
ErrorType
ErrorLine
    end

    methods
        function obj=EvaluationEndInfo(ranToCompletion,errorType,errorLine)
            obj.DidRunToCompletion=ranToCompletion;
            if nargin<2
                obj.setError(matlab.internal.editor.ErrorType.None,0);
            else
                obj.setError(errorType,errorLine);
            end
        end

        function setError(obj,errorType,errorLine)
            obj.ErrorType=errorType.char();
            obj.ErrorLine=errorLine;
        end
    end
end

