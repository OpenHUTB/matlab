classdef RegionEventData<matlab.internal.editor.events.EvaluationBaseEventData




    properties
        RegionNumber;
        RegionLineNumber;
        isFigureStreamPoint;
    end

    methods
        function data=RegionEventData(regionNumber,regionLineNumber,isFigureStreamPoint,callbackData)
            data=data@matlab.internal.editor.events.EvaluationBaseEventData(callbackData);
            data.RegionNumber=regionNumber;
            data.RegionLineNumber=regionLineNumber;
            data.isFigureStreamPoint=isFigureStreamPoint;
        end
    end

end

