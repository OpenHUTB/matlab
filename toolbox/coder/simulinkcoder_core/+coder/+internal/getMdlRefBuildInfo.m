function[mdlRefBuildFolders,modelLibNames,modelNames]=getMdlRefBuildInfo...
    (mdlRefTgtType,modelRefsAll_in,protectedModelRefs,...
    lSystemTargetFile,modelRefsBuildDirs,...
    protectedModelRefsBuildDirsAll,...
    linkLibraries,directModelRefs_in,protectedMdlRefsDirect)



    if isempty(linkLibraries)
        mdlRefBuildFolders={};
        modelLibNames={};
        modelNames={};
        return
    end





    [directModelRefs,ia]=intersect(directModelRefs_in,modelRefsAll_in,'stable');
    directModelRefBuildFolders=modelRefsBuildDirs(ia);


    [~,directIdx]=intersect(protectedModelRefs,protectedMdlRefsDirect,'stable');


    modelNames=[directModelRefs,protectedModelRefs(directIdx)];
    mrabd=[directModelRefBuildFolders,protectedModelRefsBuildDirsAll(directIdx)];

    if strcmp(mdlRefTgtType,'NONE')&&...
        ~any(strcmp(lSystemTargetFile,{'raccel.tlc','accel.tlc'}))
        mdlRefTgtType='RTW';
    end


    modelLibNames=coder.internal.getModelLibName(modelNames,mdlRefTgtType);


    [~,~,ib]=intersect(linkLibraries,modelLibNames,'stable');


    mdlRefBuildFolders=mrabd(ib);
    modelLibNames=modelLibNames(ib);
    modelNames=modelNames(ib);
