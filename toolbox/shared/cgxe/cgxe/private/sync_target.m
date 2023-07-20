function checksums=sync_target(modelName,moduleChksums)



    persistent versionInfo;

    customCodeSettings=CGXE.CustomCode.CustomCodeSettings.createFromModel(modelName);

    cs=getActiveConfigSet(modelName);
    isCpp=strcmpi(get_param(cs,'SimTargetLang'),'C++');
    compilerInfo=cgxeprivate('compilerman','get_compiler_info',isCpp);

    makefileChecksum=CGXE.Utils.md5(moduleChksums...
    ,customCodeSettings.userSources...
    ,customCodeSettings.userLibraries...
    ,compilerInfo.compilerName...
    ,compilerInfo.mexSetEnv);

    checksums.modules=moduleChksums;
    checksums.model=CGXE.Utils.md5(moduleChksums);
    checksums.makefile=CGXE.Utils.md5(makefileChecksum,matlabroot);
    checksums.target=CGXE.Utils.md5(isCpp);

    if isempty(versionInfo)
        versionInfo=ver('simulink');
    end
    checksums.overall=CGXE.Utils.md5(makefileChecksum,modelName,moduleChksums,versionInfo.Version);

    return;
