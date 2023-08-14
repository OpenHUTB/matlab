
classdef UndoRedoStateEvent<event.EventData
    properties
RedoState
UndoState
    end
    methods
        function this=UndoRedoStateEvent(undoTF,redoTF)
            this.UndoState=undoTF;
            this.RedoState=redoTF;
        end

    end
end