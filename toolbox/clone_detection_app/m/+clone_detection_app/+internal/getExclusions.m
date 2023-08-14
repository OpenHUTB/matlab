
function[excludeLibraries,excludeModelReferences,excludeInactiveRegions,...
    blockExclusions]=getExclusions(model)




    exclusionsObj=CloneDetector.Exclusions(get_param(model,'name'));
    excludeLibraries=exclusionsObj.getExcludeLibraryLinks();
    excludeModelReferences=exclusionsObj.getExcludeModelReferences();
    excludeInactiveRegions=exclusionsObj.getExcludeInactiveRegions();
    blockExclusions=exclusionsObj.getExcludedBlocks();
end

