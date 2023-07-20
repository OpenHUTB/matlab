function removeUninstalledDirsFromPath(spRoot)








    validateattributes(spRoot,{'char'},{'nonempty'},'removeUninstalledDirsFromPath','spRoot',1);

    spRoot=matlabshared.supportpkg.internal.biGetCanonicalPath(spRoot);
    assert(logical(exist(spRoot,'dir')),sprintf('spRoot directory: %s does not exist',spRoot));

    spRootEntriesOnPath=matlabshared.supportpkg.internal.ssi.util.getCurrentSprootPathEntries(spRoot);

    if isempty(spRootEntriesOnPath)
        return;
    end


    phlPathEntries=matlabshared.supportpkg.internal.ssi.util.readAllPhlFiles(spRoot);



    changeInPathEntries=setdiff(spRootEntriesOnPath,phlPathEntries);
    if isempty(changeInPathEntries)


        return;
    end



    oldWarnState=warning('off','MATLAB:rmpath:DirNotFound');
    cleanup=onCleanup(@()warning(oldWarnState));
    changeInPathEntries=matlabshared.supportpkg.internal.ssi.util.ensurePlatformAppropriatePath(changeInPathEntries);
    rmpath(changeInPathEntries{:});
end
