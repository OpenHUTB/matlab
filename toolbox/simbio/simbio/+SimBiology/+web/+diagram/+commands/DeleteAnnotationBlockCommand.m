classdef DeleteAnnotationBlockCommand<diagram.editor.Command
    properties
        blockInfo=[];
    end

    methods(Access=protected)
        function execute(obj)
            input=obj.data;



            model=input.model;
            sessionIDs=input.sessionIDs;
            template=struct('sessionID','','uuid','');
            obj.blockInfo=repmat(template,1,numel(sessionIDs));

            for i=1:numel(sessionIDs)
                block=model.getEntitiesInMap(sessionIDs(i));
                obj.blockInfo(i).sessionID=sessionIDs(i);
                obj.blockInfo(i).uuid=block.uuid;
            end


            obj.syntax.modify(@(operations)input.deleteAnnotationBlocksOperationsFcn(operations,model,sessionIDs));


            transaction=SimBiology.Transaction.create(input.model);
            transaction.push(@()obj.deleteCommandUndoLambda());
            transaction.commit();
        end
    end

    methods
        function cmd=DeleteAnnotationBlockCommand(data,syntax)
            cmd@diagram.editor.Command(data,syntax);
        end

        function deleteCommandUndoLambda(obj)
            try
                obj.data.commandProcessor.undo();
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


            for i=1:numel(obj.blockInfo)
                blockToAdd=obj.syntax.findElement(obj.blockInfo(i).uuid);
                obj.data.model.addEntitiesToMap(obj.blockInfo(i).sessionID,blockToAdd);
            end
        end

        function redo(obj)



            for i=1:numel(obj.blockInfo)
                block=obj.data.model.getEntitiesInMap(obj.blockInfo(i).sessionID);
                obj.data.model.deleteEntitiesInMap(obj.blockInfo(i).sessionID,block);
            end


            obj.redoDefault();
        end
    end
end