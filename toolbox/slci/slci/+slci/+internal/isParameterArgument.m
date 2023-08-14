

function out=isParameterArgument(model,name)
    paramArgMap=slci.internal.buildParamArgMap(model);
    out=false;
    if isKey(paramArgMap,name)
        out=true;
        return;
    end
end
