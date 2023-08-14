classdef(ConstructOnLoad)HistoryUpdatedEventData<event.EventData





    properties

CanUndo
CanRedo

    end

    methods

        function data=HistoryUpdatedEventData(undo,redo)

            data.CanUndo=undo;
            data.CanRedo=redo;

        end

    end

end