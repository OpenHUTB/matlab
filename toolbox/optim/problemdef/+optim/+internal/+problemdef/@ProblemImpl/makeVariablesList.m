function prob=makeVariablesList(prob)















    vars=struct([]);


    objectives=prob.ObjectivesStore;
    if isstruct(objectives)
        fnames=fieldnames(objectives);
        for i=1:numel(fnames)
            vars=addVariablesFromExprOrConstr(vars,objectives.(fnames{i}),prob.className);
        end
    else
        vars=addVariablesFromExprOrConstr(vars,objectives,prob.className);
    end

    constraints=prob.ConstraintsStore;
    if isstruct(constraints)
        fnames=fieldnames(constraints);
        for i=1:numel(fnames)
            vars=addVariablesFromExprOrConstr(vars,constraints.(fnames{i}),prob.className);
        end
    else
        vars=addVariablesFromExprOrConstr(vars,constraints,prob.className);
    end

    prob.Variables=vars;
end
