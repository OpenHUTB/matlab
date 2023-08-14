

classdef RegisterUndoRedoSubplotAction<matlab.internal.editor.figure.RegisterUndoRedoToolStripAction

    methods


        function undoToolstripAction(~,~,fig,actionID,cmd,varargin)


            actionManager=varargin{1};
            actionManager.performGallerySubplotCallback(actionID,fig,'',cmd.prevState{1},cmd.prevState{2});
        end

        function redoToolstripAction(~,~,fig,actionID,cmd,varargin)
            actionManager=varargin{1};
            actionManager.performGallerySubplotCallback(actionID,fig,'',cmd.nextState{1},cmd.nextState{2});
        end
    end
end