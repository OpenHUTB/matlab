















function[astContainer,resolvedSymbolIds]=...
    getAbstractSyntaxTree(stateflowObject)

    astContainer=[];
    resolvedSymbolIds=[];

    if stateflowObject.isCommented()
        return;
    end

    if isa(stateflowObject,'Stateflow.State')||...
        isa(stateflowObject,'Stateflow.Transition')
        if nargout>=1


            tempIds=sf('ResolvedSymbolsIn',stateflowObject.Id);
            resolvedSymbolIds=unique(tempIds);
        end
        try
            astContainer=Stateflow.Ast.getContainer(stateflowObject);
        catch ME
            error(message('ModelAdvisor:engine:errorAST'));
        end
    end

end

