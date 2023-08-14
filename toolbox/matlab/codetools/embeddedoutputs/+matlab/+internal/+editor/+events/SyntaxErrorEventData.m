classdef SyntaxErrorEventData<matlab.internal.editor.events.ErrorEventData




    properties
RegionLineNumber
    end

    methods
        function data=SyntaxErrorEventData(errorEventData,regionLineNumber)
            data=data@matlab.internal.editor.events.ErrorEventData(errorEventData.Exception,errorEventData.CallbackData,errorEventData.FullFilePath);
            data.RegionLineNumber=regionLineNumber;
        end
    end
end