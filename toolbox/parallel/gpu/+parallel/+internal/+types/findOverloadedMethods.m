function[areAnyFnOverloads,theOverloads]=findOverloadedMethods(fn)




    if~iscell(fn)
        fn={fn};
    end

    overloads=parallel.internal.types.getRowVectorOfGpuarrayMethods();



    isOverload=false(size(fn));
    for n=1:numel(fn)
        isOverload(n)=any(strcmp(fn{n},overloads));
    end

    areAnyFnOverloads=any(isOverload);
    if nargout>1
        theOverloads=fn(isOverload);
    end

end
