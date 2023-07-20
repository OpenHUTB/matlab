function vars=addVariablesFromExprOrConstr(vars,expr,callerClass)







    if isempty(expr)

        return;
    end

    addVars=getVariables(expr);

    if isempty(fieldnames(addVars))

        return;
    end

    if isempty(vars)

        vars=addVars;
    end

    vars=optim.internal.problemdef.HashMapFunctions.union(vars,addVars,callerClass);