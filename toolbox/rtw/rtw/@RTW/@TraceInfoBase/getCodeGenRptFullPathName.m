function out=getCodeGenRptFullPathName(h)




    out=fullfile(h.BuildDirRoot,h.getRelativeBuildDir,h.getCodeGenRptDir,...
    h.getCodeGenRptFileName);
