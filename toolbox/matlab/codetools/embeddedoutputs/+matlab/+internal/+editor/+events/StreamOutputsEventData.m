classdef StreamOutputsEventData<matlab.internal.editor.events.EvaluationBaseEventData


    properties
        PreviousRegionNumber;
        PreviousRegionLineNumber;
SectionNumber
    end

    methods
        function data=StreamOutputsEventData(regionNumber,regionLineNumber,sectionNumber,callbackData)
            data=data@matlab.internal.editor.events.EvaluationBaseEventData(callbackData);
            data.PreviousRegionNumber=regionNumber;
            data.PreviousRegionLineNumber=regionLineNumber;
            data.SectionNumber=sectionNumber;
        end
    end

end

