function genTMWFile(buildInfo,toolchainOrTemplateDesc,projName,bldMode)




    switch bldMode
    case coder.internal.BuildMode.Normal
        tmwfile='rtw_proj.tmw';
    case coder.internal.BuildMode.Example
        tmwfile='rtw_proj_example.tmw';
    end
    [file,fspec]=OpenSupportFile(buildInfo,tmwfile,bldMode,'');
    if bldMode==coder.internal.BuildMode.Normal
        buildInfo.addNonBuildFiles(fspec);
    end
    fprintf(file,'Code generation project for %s using %s. MATLAB root = %s.\n',...
    projName,toolchainOrTemplateDesc,matlabroot);
    fclose(file);
end
