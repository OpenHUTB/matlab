classdef FigureReadyEventData<event.EventData





    properties
        FigureStruct;
EditorId
    end

    methods
        function obj=FigureReadyEventData(figureStruct,editorId)
            obj.FigureStruct=figureStruct;
            obj.EditorId=editorId;
        end
    end

end