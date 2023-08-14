classdef(ConstructOnLoad)MeasurementUndoRedoEventData<event.EventData





    properties

ToolName

Position

Parent

PreviousPosition
    end

    methods

        function data=MeasurementUndoRedoEventData(toolType,pos,parent,previouspos)
            data.ToolName=toolType;
            data.Position=pos;
            data.Parent=parent;

            if nargin==4
                data.PreviousPosition=previouspos;
            end
        end

    end

end