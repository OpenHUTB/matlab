classdef ClassDiagramLayoutCommand<diagram.editor.Command&...
    classdiagram.app.core.commands.ClassDiagramUndoRedo
    properties(Access={
        ?diagram.editor.Command,...
        ?classdiagram.app.core.commands.ClassDiagramUndoRedo
        })
        App;
    end

    methods
        function cmd=ClassDiagramLayoutCommand(data,syntax,app)
            cmd@diagram.editor.Command(data,syntax);
            cmd.App=app;
        end
    end

    methods(Access=protected)
        function execute(obj)
            obj.syntax.modify(@(operations)obj.App.doLayout(operations));
        end

        function undo(obj)
            obj.undoDefault;
        end

        function redo(obj)
            obj.redoDefault;
        end
    end
end