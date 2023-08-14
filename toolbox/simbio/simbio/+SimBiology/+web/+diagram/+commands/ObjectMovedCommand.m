classdef ObjectMovedCommand<diagram.editor.Command
    properties
    end

    methods(Access=protected)
        function execute(obj)
            input=obj.data;

            obj.syntax.modify(@(operations)input.objectMovedOperationsFcn(operations,input.model,obj.syntax,input.input))


            transaction=SimBiology.Transaction.create(input.model);
            transaction.push(@()obj.objectMovedCommandUndoLambda());
            transaction.commit();
        end
    end

    methods
        function cmd=ObjectMovedCommand(data,syntax)
            cmd@diagram.editor.Command(data,syntax);
        end

        function objectMovedCommandUndoLambda(obj)
            try
                obj.data.commandProcessor.undo();
                transaction=SimBiology.Transaction.create(obj.data.model);
                transaction.push(@()obj.objectMovedCommandRedoLambda());
                transaction.commit();
            catch

            end
        end

        function objectMovedCommandRedoLambda(obj)
            try
                obj.data.commandProcessor.redo();
                transaction=SimBiology.Transaction.create(obj.data.model);
                transaction.push(@()obj.objectMovedCommandUndoLambda());
                transaction.commit();
            catch

            end
        end
    end

    methods(Access=protected)
        function undo(obj)

            obj.undoDefault();
        end

        function redo(obj)

            obj.redoDefault();
        end
    end
end