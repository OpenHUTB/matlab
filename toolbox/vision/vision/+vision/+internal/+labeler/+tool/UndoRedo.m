



classdef UndoRedo<handle
    methods(Abstract)
        execute(obj)
        undo(obj)
    end
end
