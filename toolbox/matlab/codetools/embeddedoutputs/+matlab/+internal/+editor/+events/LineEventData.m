classdef LineEventData<matlab.internal.editor.events.EvaluationBaseEventData




    properties
        LineNumber;
    end

    methods
        function data=LineEventData(lineNumber,callbackData)
            data=data@matlab.internal.editor.events.EvaluationBaseEventData(callbackData);
            data.LineNumber=lineNumber;
        end
    end

end

