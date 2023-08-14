function addInstalledDirsToPath(spRoot)














    validateattributes(spRoot,{'char'},{'nonempty'},'addInstalledDirsToPath','spRoot',1);


    spRoot=matlabshared.supportpkg.internal.biGetCanonicalPath(spRoot);
    assert(logical(exist(spRoot,'dir')),sprintf('spRoot directory: %s does not exist',spRoot));


    spRootEntriesOnPath=matlabshared.supportpkg.internal.ssi.util.getCurrentSprootPathEntries(spRoot);



    phlPathEntries=matlabshared.supportpkg.internal.ssi.util.readAllPhlFiles(spRoot);






    newPathEntries=setdiff(phlPathEntries,spRootEntriesOnPath);


    if isempty(newPathEntries)
        return;
    end



    newPathEntries=newPathEntries(cellfun(@isdir,newPathEntries));


    if isempty(newPathEntries)
        return;
    end


    addDirsToPath(newPathEntries);
end


function addDirsToPath(pathEntries)



    correctedPathEntries=matlabshared.supportpkg.internal.ssi.util.ensurePlatformAppropriatePath(pathEntries);
    addpath(correctedPathEntries{:});
end
