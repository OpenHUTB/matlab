

function outDim=getParameterDim(obj,parameterExpr)



    val=slResolve(parameterExpr,obj.blockObject.Handle);
    if isempty(val)
        outDim=[];
    else
        s=size(val);
        outDim=[length(s),s];
    end
