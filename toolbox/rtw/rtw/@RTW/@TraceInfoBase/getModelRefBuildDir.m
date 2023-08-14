function out=getModelRefBuildDir(h)






    if~isempty(h.BuildDirRoot)
        mdlRefDir=fullfile(h.BuildDirRoot,h.ModelRefRelativeBuildDir);
    else
        dirs=RTW.getBuildDir(h.Model);
        mdlRefDir=fullfile(dirs.CodeGenFolder,h.ModelRefRelativeBuildDir);
    end

    if exist(fullfile(mdlRefDir,'html','traceInfo.mat'),'file')
        out=mdlRefDir;
    else
        out='';
    end


