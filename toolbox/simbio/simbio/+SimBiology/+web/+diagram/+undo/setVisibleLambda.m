function setVisibleLambda(model,oldValue,newValue)


    if~isempty(model)
        syntax=model.getDiagramSyntax;
        syntax.modify(@(operations)setVisibleOperations(operations,model,oldValue));
    end

    redoTransaction=SimBiology.Transaction.create(model);
    redoTransaction.push(@()SimBiology.web.diagram.undo.setVisibleLambda(model,newValue,oldValue));
    redoTransaction.commit();

end


function setVisibleOperations(operations,model,inputs)

    SimBiology.web.diagramhandler('showBlocksInternal',operations,model,inputs);

    SimBiology.web.eventhandler('undoInDiagram',model.SessionID,inputs.sessionIDs,true);

end