function[ccPrebuiltExeFullPath,ccPrebuiltInterfaceHeaderFullPath]=getPreBuiltCCDependency(mdlName)


    ccPrebuiltExeFullPath='';
    ccPrebuiltInterfaceHeaderFullPath='';

    if~isfolder(SLCC.OOP.PrebuiltCC.getPrebuitTopFolderPath(mdlName))||...
        strcmp(SLCC.OOP.PrebuiltCC.prebuildMdlDesc,get_param(mdlName,'Description'))
        return;
    end

    headerFullPath=SLCC.OOP.PrebuiltCC.getInterfaceHeaderPath(mdlName);
    exeFullPath=SLCC.OOP.PrebuiltCC.getExecutablePath(mdlName);
    if~isfile(headerFullPath)||~isfile(exeFullPath)
        error('Internal error: Custom code prebuilt dependency files do not exist. Report this bug to MathWorks Technical Support.');
    end

    ccPrebuiltInterfaceHeaderFullPath=headerFullPath;
    ccPrebuiltExeFullPath=exeFullPath;

end