classdef EvaluationEventData<matlab.internal.editor.events.EvaluationBaseEventData


    properties
        FinalRegionNumber;
        FinalRegionLineNumber;
    end

    methods
        function data=EvaluationEventData(callbackData,regionNumber,regionLineNumber)
            data=data@matlab.internal.editor.events.EvaluationBaseEventData(callbackData);

            if nargin<3
                data.FinalRegionNumber=[];
                data.FinalRegionLineNumber=[];
            else
                data.FinalRegionNumber=regionNumber;
                data.FinalRegionLineNumber=regionLineNumber;
            end
        end
    end

end

