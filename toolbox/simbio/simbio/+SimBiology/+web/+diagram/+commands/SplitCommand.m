classdef SplitCommand<diagram.editor.Command
    properties
        undoUUIDs=[];
        redoUUIDs=[];
    end

    methods(Access=protected)
        function execute(obj)
            input=obj.data;


            obj.undoUUIDs=SimBiology.web.diagram.clonehandler('getUUIDsInMap',input.model,input.input);


            obj.syntax.modify(@(operations)input.splitInternalFcn(operations,input.root,input.input));


            obj.redoUUIDs=SimBiology.web.diagram.clonehandler('getUUIDsInMap',input.model,input.input);


            transaction=SimBiology.Transaction.create(input.model);
            transaction.push(@()obj.splitCommandUndoLambda());
            transaction.commit();
        end
    end

    methods
        function cmd=SplitCommand(data,syntax)
            cmd@diagram.editor.Command(data,syntax);
        end

        function splitCommandUndoLambda(obj)
            try
                obj.data.commandProcessor.undo();
                transaction=SimBiology.Transaction.create(obj.data.model);
                transaction.push(@()obj.splitCommandRedoLambda());
                transaction.commit();
            catch

            end
        end

        function splitCommandRedoLambda(obj)
            try
                obj.data.commandProcessor.redo();
                transaction=SimBiology.Transaction.create(obj.data.model);
                transaction.push(@()obj.splitCommandUndoLambda());
                transaction.commit();
            catch

            end
        end
    end

    methods(Access=protected)
        function undo(obj)



            for i=1:numel(obj.undoUUIDs)

                next=obj.undoUUIDs(i);
                sessionID=next.sessionID;
                uuid=next.uuid;


                blocks=obj.data.model.getEntitiesInMap(sessionID);

                for j=1:numel(blocks)


                    blockUUID=blocks(j).uuid;
                    if~any(strcmp(blockUUID,uuid))
                        obj.data.model.deleteEntitiesInMap(sessionID,blocks(j));
                    end
                end
            end


            obj.undoDefault();
        end

        function redo(obj)


            obj.redoDefault();


            for i=1:numel(obj.redoUUIDs)

                next=obj.redoUUIDs(i);
                sessionID=next.sessionID;
                uuid=next.uuid;


                blocks=obj.data.model.getEntitiesInMap(sessionID);
                blocksUUID={blocks.uuid};

                for j=1:numel(uuid)
                    if~any(strcmp(uuid{j},blocksUUID))


                        blockToAdd=obj.syntax.findElement(uuid{j});
                        obj.data.model.addEntitiesToMap(sessionID,blockToAdd);
                    end
                end
            end
        end
    end
end