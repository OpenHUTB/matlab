function result=getSupportPackageRoot
    result=coderapp.internal.screener.cache.unsafe.getSupportPackageRoot;
    if ismissing(result)
        result='';
    else
        result=char(result);
    end
end
