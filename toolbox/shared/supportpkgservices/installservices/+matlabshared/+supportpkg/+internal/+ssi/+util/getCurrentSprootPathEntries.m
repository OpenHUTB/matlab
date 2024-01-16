function spRootEntries=getCurrentSprootPathEntries(spRoot)
    validateattributes(spRoot,{'char'},{'nonempty'},'getCurrentSprootPathEntries','spRoot',2);
    assert(logical(exist(spRoot,'dir')),sprintf('spRoot directory: %s does not exist',spRoot));
    currentMatlabPath=strsplit(path,pathsep);
    indices=strncmp(spRoot,currentMatlabPath,length(spRoot));
    spRootEntries=currentMatlabPath(indices);
end