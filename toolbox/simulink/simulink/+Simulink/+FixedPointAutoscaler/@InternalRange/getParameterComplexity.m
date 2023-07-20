

function complexity=getParameterComplexity(obj,parameterExpr)



    val=slResolve(parameterExpr,obj.blockObject.Handle);
    if isempty(val)
        complexity=false;
    else
        complexity=~isreal(val);
    end
