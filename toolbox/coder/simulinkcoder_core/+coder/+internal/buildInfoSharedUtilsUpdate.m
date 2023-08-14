function lSharedSourceFolder=buildInfoSharedUtilsUpdate...
    (lBuildInfo,...
    lUseSharedUtilities,...
    istrRelativePathToAnchor,...
    istrSharedBinaryDir,...
    istrSharedSourcesDir,...
    src_exts,...
    localAnchorFolder)






    lBuildInfo=loc_addPregeneratedLibraryPaths(lBuildInfo);

    if lUseSharedUtilities

        lSharedSourceFolder=fullfile(istrRelativePathToAnchor,istrSharedSourcesDir);

        sharedLibLinkObj=coder.internal.getSharedLibLinkObj...
        (src_exts,istrSharedSourcesDir,istrSharedBinaryDir,...
        localAnchorFolder);

        if~isempty(sharedLibLinkObj)

            lBuildInfo.addLinkObjects(sharedLibLinkObj);
        end


addIncludePaths...
        (lBuildInfo,fullfile('$(START_DIR)',istrSharedSourcesDir),'Standard');
    else
        lSharedSourceFolder='';
    end



    function lBuildInfo=loc_addPregeneratedLibraryPaths(lBuildInfo)




        [libPaths,libNames]=coder.internal.getRLSPaths(pwd);

        for k=1:length(libPaths)
            libPath=libPaths{k};
            lBuildInfo.addIncludePaths(libPaths);

            linkObj=addLinkObjects(lBuildInfo,...
            libNames{k},...
            libPath,...
            RTW.BuildInfoLinkObj.DefaultLinkPriority,...
            true,true,...
            '');


            linkObj.NeverRebuild=true;


            linkObj.ReferencedBuildInfo=coder.make.enum.ReferencedBuildInfo.Required;
        end

