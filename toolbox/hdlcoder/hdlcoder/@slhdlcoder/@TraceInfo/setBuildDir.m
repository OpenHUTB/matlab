function setBuildDir(h,buildDir)






    if isempty(buildDir)
        h.getBuildDir();
        return
    end
    h.BuildDirRoot=buildDir{1};
    h.RelativeBuildDir=buildDir{2};
    h.BuildDir=fullfile(h.BuildDirRoot,h.RelativeBuildDir);
