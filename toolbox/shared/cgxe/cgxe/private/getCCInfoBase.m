function ccInfo=getCCInfoBase(customCodeSettings,lang,modelName)









    if nargin<3
        modelName='';
    end

    compilerName='';
    if ispc
        genCpp=strcmpi(lang,'C++');
        compilerInfo=cgxeprivate('compilerman','get_compiler_info',genCpp);
        compilerName=compilerInfo.compilerName;
        if ismember(compilerName,supportedPCCompilers('microsoft'))

            compilerName='msvc';
        end
    end

    ccInfo.customCodeSettings=customCodeSettings;
    ccInfo.lang=lang;
    ccInfo.compilerName=compilerName;


    checkSum=CGXE.Utils.md5(feature('CGForceUnsignedConsts'));
    checkSum=ccInfo.customCodeSettings.fieldChecksum(checkSum);
    checkSum=CGXE.Utils.md5(checkSum,ccInfo.lang,ccInfo.compilerName);
    ccInfo.settingsChecksum=cgxe('MD5AsString',checkSum);


    ccInfo.cachedForModelRefRebuild.modelName=modelName;

    ccInfo.cachedForModelRefRebuild.userIncludeDirs=ccInfo.customCodeSettings.userIncludeDirs;
    ccInfo.cachedForModelRefRebuild.userSources=ccInfo.customCodeSettings.userSources;
    ccInfo.cachedForModelRefRebuild.userLibraries=ccInfo.customCodeSettings.userLibraries;

    ccInfo.isTokenized=false;
end
