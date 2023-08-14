function[match,prune]=matchSystemRegisteredAsLookupTableBlock(handle)
    match=lutdesigner.lutfinder.LookupTableFinder.isLookupTableBlock(handle);
    prune=match;
end
