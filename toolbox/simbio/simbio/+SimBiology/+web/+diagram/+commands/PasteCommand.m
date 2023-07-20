classdef PasteCommand<diagram.editor.Command




    properties
pastedAnnotationBlockInfo
    end

    methods(Access=protected)
        function execute(obj)
            input=obj.data;

            obj.syntax.modify(@(operations)input.pasteBlocksFcn(operations,input.model,input.target,input.blockInfo,input.objectsAdded,input.input))

            template=struct('sessionID','','uuid','');
            obj.pastedAnnotationBlockInfo=template([]);

            blockInfo=input.blockInfo;







            annotationSessionID=input.input.lastSessionID;
            for i=1:numel(blockInfo)
                if blockInfo(i).sessionID<0
                    annotationSessionID=annotationSessionID-1;
                    pastedAnnotationBlock=obj.data.model.getEntitiesInMap(annotationSessionID);
                    obj.pastedAnnotationBlockInfo(end+1)=template;
                    obj.pastedAnnotationBlockInfo(end).sessionID=annotationSessionID;
                    obj.pastedAnnotationBlockInfo(end).uuid=pastedAnnotationBlock.uuid;
                end
            end


            transaction=SimBiology.Transaction.create(input.model);
            transaction.push(@()obj.pasteCommandUndoLambda());
            transaction.commit();
        end
    end

    methods
        function cmd=PasteCommand(data,syntax)
            cmd@diagram.editor.Command(data,syntax);
        end

        function pasteCommandUndoLambda(obj)
            try
                obj.data.commandProcessor.undo();
                transaction=SimBiology.Transaction.create(obj.data.model);
                transaction.push(@()obj.pasteCommandRedoLambda());
                transaction.commit();
            catch

            end
        end

        function pasteCommandRedoLambda(obj)
            try
                obj.data.commandProcessor.redo();
                transaction=SimBiology.Transaction.create(obj.data.model);
                transaction.push(@()obj.pasteCommandUndoLambda());
                transaction.commit();
            catch

            end
        end
    end

    methods(Access=protected)
        function undo(obj)




            for i=1:numel(obj.pastedAnnotationBlockInfo)
                block=obj.data.model.getEntitiesInMap(obj.pastedAnnotationBlockInfo(i).sessionID);
                obj.data.model.deleteEntitiesInMap(obj.pastedAnnotationBlockInfo(i).sessionID,block);
            end


            obj.undoDefault();


        end

        function redo(obj)

            obj.redoDefault();


            for i=1:numel(obj.pastedAnnotationBlockInfo)
                blockToAdd=obj.syntax.findElement(obj.pastedAnnotationBlockInfo(i).uuid);
                obj.data.model.addEntitiesToMap(obj.pastedAnnotationBlockInfo(i).sessionID,blockToAdd);
            end

        end
    end
end
