classdef ErrorEventData<matlab.internal.editor.events.EvaluationBaseEventData




    properties
Exception
FullFilePath
    end

    methods
        function data=ErrorEventData(exception,callbackData,fullFilePath)
            data=data@matlab.internal.editor.events.EvaluationBaseEventData(callbackData);
            data.Exception=exception;
            data.FullFilePath=fullFilePath;
        end
    end
end