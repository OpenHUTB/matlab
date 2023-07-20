classdef BlockMoveCommand<diagram.editor.Command



    properties
        uuid={};
        sessionID=-1;
    end

    methods(Access=protected)
        function execute(obj)
            input=obj.data;
            model=input.model;
            syntax=model.getDiagramSyntax;

            function applyChanges(operations,input,model,syntax)
                for i=1:numel(input.input.reparentInfo)
                    if(model.SessionID==input.input.reparentInfo(i).parent)
                        parentBlockContainer=syntax.root;
                    else
                        parentBlock=model.getEntitiesInMap(input.input.reparentInfo(i).parent);
                        parentBlockContainer=parentBlock.subdiagram;
                    end

                    pos=input.input.reparentInfo(i).position;



                    block=syntax.findElement(input.input.reparentInfo(i).blockUUID);


                    operations.setParent(block,parentBlockContainer);
                    operations.setPosition(block,pos.x,pos.y);
                    operations.setAttributeValue(block,'parentSessionID',input.input.reparentInfo(i).parent);









                    if input.input.reparentInfo(i).isReparentOperation&&...
                        ismember(block.type,["species","compartment"])
                        operations.setAttributeValue(block,'needsConfiguration',true);
                    end
                end
            end

            syntax.modify(@(operations)applyChanges(operations,input,model,syntax));


            transaction=SimBiology.Transaction.create(input.model);
            transaction.push(@()obj.blockMoveCommandUndoLambda());
            transaction.commit();
        end
    end

    methods
        function cmd=BlockMoveCommand(data,syntax)
            cmd@diagram.editor.Command(data,syntax);
        end

        function blockMoveCommandUndoLambda(obj)
            try
                obj.data.commandProcessor.undo();
                transaction=SimBiology.Transaction.create(obj.data.model);
                transaction.push(@()obj.blockMoveCommandRedoLambda());
                transaction.commit();
            catch

            end
        end

        function blockMoveCommandRedoLambda(obj)
            try
                obj.data.commandProcessor.redo();
                transaction=SimBiology.Transaction.create(obj.data.model);
                transaction.push(@()obj.blockMoveCommandUndoLambda());
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