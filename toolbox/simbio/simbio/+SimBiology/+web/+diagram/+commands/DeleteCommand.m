classdef DeleteCommand<diagram.editor.Command
    properties
        uuid={};
        sessionID=-1;
    end

    methods(Access=protected)
        function execute(obj)
            input=obj.data;
            model=input.model;
            syntax=model.getDiagramSyntax;
            blocks=model.getEntitiesInMap(input.input.obj);
            sobj=sbioselect(model,'SessionID',input.input.obj);
            obj.uuid={blocks.uuid};
            obj.sessionID=input.input.obj;

            syntax.modify(@(operations)input.objectDeletedOperationsFcn(operations,syntax,blocks,model,sobj));


            transaction=SimBiology.Transaction.create(input.model);
            transaction.push(@()obj.deleteCommandUndoLambda());
            transaction.commit();
        end
    end

    methods
        function cmd=DeleteCommand(data,syntax)
            cmd@diagram.editor.Command(data,syntax);
        end

        function deleteCommandUndoLambda(obj)
            try
                obj.data.commandProcessor.undo()
                transaction=SimBiology.Transaction.create(obj.data.model);
                transaction.push(@()obj.deleteCommandRedoLambda());
                transaction.commit();
            catch

            end
        end

        function deleteCommandRedoLambda(obj)
            try
                obj.data.commandProcessor.redo();
                transaction=SimBiology.Transaction.create(obj.data.model);
                transaction.push(@()obj.deleteCommandUndoLambda());
                transaction.commit();
            catch

            end
        end
    end

    methods(Access=protected)
        function undo(obj)


            obj.undoDefault();


            blocks=obj.data.model.getEntitiesInMap(obj.sessionID);
            blocksUUID={blocks.uuid};

            for i=1:numel(obj.uuid)
                if~any(strcmp(obj.uuid{i},blocksUUID))


                    blockToAdd=obj.syntax.findElement(obj.uuid{i});
                    obj.data.model.addEntitiesToMap(obj.sessionID,blockToAdd);
                end
            end
        end

        function redo(obj)



            blocks=obj.data.model.getEntitiesInMap(obj.sessionID);
            for i=1:numel(blocks)
                obj.data.model.deleteEntitiesInMap(obj.sessionID,blocks(i));
            end


            obj.redoDefault();
        end
    end
end