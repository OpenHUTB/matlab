function errorIfFcnOverload(errorMechanism,subfunctions)





















    localDefinedFcns=strings(Fname(subfunctions));
    [areAnyFcnsOverloaded,overloads]=parallel.internal.types.findOverloadedMethods(localDefinedFcns);

    if areAnyFcnsOverloaded
        overloadedFcn=overloads{1};
        fnode=mtfind(subfunctions,'Kind','FUNCTION','Fname.Fun',overloadedFcn);
        setNodeForErrorMechanism(errorMechanism,fnode);
        encounteredError(errorMechanism,...
        message('parallel:gpu:compiler:MethodOverload',...
        overloadedFcn));
    end
