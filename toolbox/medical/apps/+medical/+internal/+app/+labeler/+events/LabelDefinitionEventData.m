classdef(ConstructOnLoad)LabelDefinitionEventData<event.EventData




    properties

LabelName
LabelColor
LabelPixelID
LabelVisible

SelectedIdx

    end

    methods

        function data=LabelDefinitionEventData(name,color,pixelID,visible,selectedIdx)

            data.LabelName=name;
            data.LabelColor=color;
            data.LabelPixelID=pixelID;
            data.LabelVisible=visible;
            data.SelectedIdx=selectedIdx;

        end

    end

end