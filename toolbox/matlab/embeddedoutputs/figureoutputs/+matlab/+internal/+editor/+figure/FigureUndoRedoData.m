classdef FigureUndoRedoData<handle



    properties
        isUndoRedo logical=false;
    end

    methods

        function setUndoRedo(this,state)

            this.isUndoRedo=state;
        end
    end
end
