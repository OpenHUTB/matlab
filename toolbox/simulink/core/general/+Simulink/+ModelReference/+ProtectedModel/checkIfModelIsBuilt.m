function checkIfModelIsBuilt(h)









    mdl=h.ModelName;
    mdlRefBuildArgs=h.MdlRefBuildArgs;
    mdlRefTgtType=mdlRefBuildArgs.ModelReferenceTargetType;

    if(locIsDoingMRefRTWBuild(mdlRefBuildArgs)||...
        locIsDoingTopRTWBuild(mdlRefBuildArgs))&&...
        locIsTryingToUpdateTarget(mdlRefBuildArgs)

        info=coder.internal.infoMATFileMgr('load','minfo',mdl,mdlRefTgtType);



        if isempty(info.protectedModelRefs)
            return;
        end

        mdlRefsProtected=unique(reshape(info.protectedModelRefs,1,length(info.protectedModelRefs)));
        nMdlRefs=length(mdlRefsProtected);

        for i=1:nMdlRefs
            protectedMdlRef=mdlRefsProtected{i};




            pBuildDir=coder.internal.ParallelAnchorDirManager('get',mdlRefTgtType);



            buildDirs=RTW.getBuildDir(protectedMdlRef);
            lModelRefRelativeBuildDir=buildDirs.ModelRefRelativeBuildDir;

            if isempty(pBuildDir)

                lAnchorDir=buildDirs.CodeGenFolder;
            else

                lAnchorDir=pBuildDir;
            end

            if ismember(protectedMdlRef,info.protectedModelRefsWithTopModelXIL)

                lBinfoFileName='binfo.mat';
            else

                lBinfoFileName='binfo_mdlref.mat';
            end

            file=fullfile(lAnchorDir,lModelRefRelativeBuildDir,'tmwinternal',lBinfoFileName);
            if~exist(file,'file')
                DAStudio.error('RTW:buildProcess:infoMATFileMgrMatFileNotFound',file);
            end
        end
    end
end

function out=locIsDoingMRefRTWBuild(mdlRefBuildArgs)
    out=strcmp(mdlRefBuildArgs.ModelReferenceTargetType,'RTW');
end

function out=locIsDoingTopRTWBuild(mdlRefBuildArgs)
    out=strcmp(mdlRefBuildArgs.ModelReferenceTargetType,'NONE')&&...
    ~((isfield(mdlRefBuildArgs,'IsSimulinkAccelerator')&&mdlRefBuildArgs.IsSimulinkAccelerator)||...
    (isfield(mdlRefBuildArgs,'IsRapidAccelerator')&&mdlRefBuildArgs.IsRapidAccelerator));
end

function out=locIsTryingToUpdateTarget(mdlRefBuildArgs)
    out=isfield(mdlRefBuildArgs,'UpdateThisModelReferenceTarget')&&...
    isempty(mdlRefBuildArgs.UpdateThisModelReferenceTarget);
end


