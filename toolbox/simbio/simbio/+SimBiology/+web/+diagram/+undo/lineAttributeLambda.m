function lineAttributeLambda(model,oldValues,newValues)


    if~isempty(model)
        syntax=model.getDiagramSyntax;
        syntax.modify(@(operations)lineAttributeOperations(operations,model,oldValues));
    end

    redoTransaction=SimBiology.Transaction.create(model);
    redoTransaction.push(@()SimBiology.web.diagram.undo.lineAttributeLambda(model,newValues,oldValues));
    redoTransaction.commit();

end


function lineAttributeOperations(operations,model,values)

    for i=1:numel(values)
        line=getLineBetweenBlocksUsingSessionID(model,values(i).sessionID);
        propStruct=values(i).values;
        props=fieldnames(propStruct);

        for j=1:numel(props)
            property=props{j};
            value=propStruct.(property);
            operations.setAttributeValue(line,property,value);
        end
    end

    SimBiology.web.eventhandler('undoInDiagram',model.SessionID,"line",false);

end


function block=getLineBetweenBlocksUsingSessionID(model,sessionIDs)

    block=SimBiology.web.diagram.linehandler('getLineBetweenBlocksUsingSessionID',model,sessionIDs(1),sessionIDs(2));

end