function configureBlockPropertyOperationsLambda(doFunction,model,oldInputs,newInputs)

    if~isempty(model)
        syntax=model.getDiagramSyntax;
        syntax.modify(@(operations)configureBlockPropertyOperations(operations,model,doFunction,oldInputs));
    end

    redoTransaction=SimBiology.Transaction.create(model);
    redoTransaction.push(@()SimBiology.web.diagram.undo.configureBlockPropertyOperationsLambda(doFunction,model,newInputs,oldInputs));
    redoTransaction.commit();

end


function configureBlockPropertyOperations(operations,model,doFunction,values)

    try
        syntax=model.getDiagramSyntax;
        doFunction(operations,model,syntax.root,values);
    catch ex %#ok<NASGU>    
    end

    if isfield(values,'selection')
        SimBiology.web.eventhandler('undoInDiagram',model.SessionID,[values.selection.sessionID],strcmp(values.property,'visible'));
    elseif isfield(values,'positionInfo')
        SimBiology.web.eventhandler('undoInDiagram',model.SessionID,[values.positionInfo.sessionID],strcmp(values.property,'visible'));
    end

end