classdef FigureManagerEventData<event.EventData



    properties
EditorId
FigureId
Figure
    end

    methods
        function obj=FigureManagerEventData(editorID,figureId,figH)
            obj.EditorId=editorID;
            obj.FigureId=figureId;
            if nargin>=3
                obj.Figure=figH;
            end
        end
    end

end