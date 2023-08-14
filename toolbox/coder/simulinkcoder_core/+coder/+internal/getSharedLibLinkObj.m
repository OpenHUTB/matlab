function sharedLibLinkObj=getSharedLibLinkObj...
    (src_exts,sharedSourcesDirRelStartDir,sharedBinaryDirRelStartDir,...
    localAnchorFolder)






    srcFiles=coder.internal.getFilesMatchingExtension...
    (src_exts,fullfile(localAnchorFolder,sharedSourcesDirRelStartDir));

    if~isempty(srcFiles)


        tokenizedSharedBDir=fullfile('$(START_DIR)',sharedBinaryDirRelStartDir);


        sLibName=coder.internal.SharedUtilities.SharedLibName;

        sharedLibLinkObj=RTW.BuildInfoLinkObj(...
        sLibName,...
        tokenizedSharedBDir,...
        RTW.BuildInfoLinkObj.DefaultLinkPriority,...
        'SHARED_SRC_LIB');

        sharedLibLinkObj.BuildInPlace=false;
        sharedLibLinkObj.LinkOnly=true;


        sharedLibLinkObj.ReferencedBuildInfo=...
        coder.make.enum.ReferencedBuildInfo.Required;
    else
        sharedLibLinkObj=[];
    end
