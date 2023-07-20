classdef EvaluationCompletionData<matlab.internal.editor.events.EvaluationBaseEventData






    properties
DidRunToCompletion
ErrorType
Exception
    end

    methods
        function obj=EvaluationCompletionData(callbackData,ranToCompletion,errorType,e)
            obj=obj@matlab.internal.editor.events.EvaluationBaseEventData(callbackData);
            obj.DidRunToCompletion=ranToCompletion;
            if nargin<3
                obj.ErrorType=matlab.internal.editor.ErrorType.None;
                obj.Exception=[];
            else
                obj.ErrorType=errorType;
                obj.Exception=e;
            end
        end
    end

end

