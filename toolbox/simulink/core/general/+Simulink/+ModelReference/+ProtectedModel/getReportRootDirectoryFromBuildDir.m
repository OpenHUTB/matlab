function out=getReportRootDirectoryFromBuildDir(buildDir)


    out=fullfile(buildDir,'..','..','..');
end