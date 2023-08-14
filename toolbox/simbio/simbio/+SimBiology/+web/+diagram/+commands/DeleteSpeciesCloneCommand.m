classdef DeleteSpeciesCloneCommand<diagram.editor.Command
    properties
        uuid={};
        sessionID=-1;
    end

    methods(Access=protected)
        function execute(obj)
            input=obj.data;



            obj.uuid=input.speciesBlock.uuid;
            obj.sessionID=input.sessionID;


            obj.syntax.modify(@(operations)input.deleteSpeciesCloneOperationsFcn(operations,input.model,input.speciesBlock,input.sessionID));


            transaction=SimBiology.Transaction.create(input.model);
            transaction.push(@()obj.deleteCommandUndoLambda());
            transaction.commit();
        end
    end

    methods
        function cmd=DeleteSpeciesCloneCommand(data,syntax)
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
                obj.data.commandProcessor.redo()
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



            if~any(strcmp(obj.uuid,blocksUUID))
                blockToAdd=obj.syntax.findElement(obj.uuid);
                obj.data.model.addEntitiesToMap(obj.sessionID,blockToAdd);
            end
        end

        function redo(obj)




            blocks=obj.data.model.getEntitiesInMap(obj.sessionID);
            for i=1:numel(blocks)
                if strcmp(blocks(i).uuid,obj.uuid)
                    obj.data.model.deleteEntitiesInMap(obj.sessionID,blocks(i));
                    break;
                end
            end


            obj.redoDefault();
        end
    end
end