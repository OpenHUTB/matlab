function[libraryBuildInfo,isUpToDate]=...
    getUpdatedLibraryBuildInfo(buildInfo,rootDirBase,...
    sharedSourcesDir,sharedObjFolder,libName,srcExts)





    [libraryBuildInfo,isUpToDate1]=coder.internal.getSharedSourceBuildInfo...
    (buildInfo,...
    rootDirBase,...
    sharedSourcesDir,...
    sharedObjFolder,...
    libName,...
    srcExts);



    isUpToDate2=coder.internal.updateSharedSourceBuildInfo...
    (libraryBuildInfo,buildInfo);

    isUpToDate=isUpToDate1&&isUpToDate2;
end
