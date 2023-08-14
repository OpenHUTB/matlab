function positionLambda(model,oldValue,newValue)




    if~isempty(model)
        syntax=model.getDiagramSyntax;
        syntax.modify(@(operations)positionOperations(operations,model,oldValue));
    end

    redoTransaction=SimBiology.Transaction.create(model);
    redoTransaction.push(@()SimBiology.web.diagram.undo.positionLambda(model,newValue,oldValue));
    redoTransaction.commit();

end


function positionOperations(operations,model,value)

    syntax=model.getDiagramSyntax;

    for i=1:numel(value)
        block=getBlockFromUUID(model,value(i).sessionID,value(i).diagramUUID);
        if~isempty(block)

            if isfield(value(i),'parent')&&~isempty(value(i).parent)
                if value(i).parent==-1
                    operations.setParent(block,syntax.root);
                else
                    parentBlock=model.getEntitiesInMap(value(i).parent);
                    operations.setParent(block,parentBlock.subdiagram);
                end
            end

            if isfield(value(i),'size')&&~isempty(value(i).size)
                operations.setSize(block,value(i).size(1),value(i).size(2));
            end

            position=value(i).position;
            if~isempty(position)
                operations.setPosition(block,position(1),position(2));
            end
        end
    end

    SimBiology.web.eventhandler('undoInDiagram',model.SessionID,[value.sessionID],false);

end


function block=getBlockFromUUID(model,sessionID,UUID)

    block=SimBiology.web.diagram.utilhandler('getBlocksFromUUID',model,sessionID,UUID);

end