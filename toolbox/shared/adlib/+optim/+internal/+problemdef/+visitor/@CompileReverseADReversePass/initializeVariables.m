function initializeVariables(visitor)












    vars=visitor.Variables;
    varnames=string(fieldnames(vars));

    nVars=numel(varnames);



    jacStr="";

    for i=1:nVars
        varname=varnames(i);
        curVar=vars.(varname);
        jacname=getJacobianMemory(curVar);

        jacStr=jacStr+jacname+" = sparse("+numel(curVar)+", "+visitor.NumExpr+");"+newline;
    end

    visitor.ExprBody=visitor.ExprBody+jacStr;
