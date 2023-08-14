classdef EvaluationBaseEventData<event.EventData



    properties
        CallbackData;
    end

    methods
        function obj=EvaluationBaseEventData(callbackData)
            obj.CallbackData=callbackData;
        end
    end

end

