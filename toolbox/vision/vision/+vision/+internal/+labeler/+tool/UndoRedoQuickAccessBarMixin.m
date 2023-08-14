classdef UndoRedoQuickAccessBarMixin<handle


    properties
UndoAction
RedoAction
UndoListener
RedoListener
    end

    events
EnableUndo
EnableRedo
    end

    methods(Abstract)
        undo(this)
        redo(this)
    end

    methods(Sealed)

        function enableQABUndo(this,TF)


            javaMethodEDT('setEnabled',this.UndoAction,any(TF));
        end


        function enableQABRedo(this,TF)


            javaMethodEDT('setEnabled',this.RedoAction,any(TF));
        end

        function disableUndoRedoQAB(this)
            this.enableQABUndo(false);
            this.enableQABRedo(false);
        end
    end
end