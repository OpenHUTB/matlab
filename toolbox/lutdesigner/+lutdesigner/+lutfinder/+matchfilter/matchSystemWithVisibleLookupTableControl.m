function[match,prune]=matchSystemWithVisibleLookupTableControl(handle)
    match=lutdesigner.lutfinder.LookupTableFinder.hasLookupTableControl(handle,'Visible','on');
    prune=lutdesigner.lutfinder.LookupTableFinder.isLookupTableBlock(handle);
end
