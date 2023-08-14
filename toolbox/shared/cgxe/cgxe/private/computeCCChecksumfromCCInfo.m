function[settingsChecksum,interfaceChecksum,fullCheckSum,dllFullPath]=computeCCChecksumfromCCInfo(ccInfo,useCachedChecksumInfo,isRefRebuild)

    [fullCheckSum,settingsChecksum,interfaceChecksum,dllFullPath]=deal('');
    if isempty(ccInfo)
        return;
    end

    if nargin<2
        useCachedChecksumInfo=false;
    end

    if nargin<3
        isRefRebuild=false;
    end

    settingsChecksum=ccInfo.settingsChecksum;

    if nargout==1
        return;
    end

    if useCachedChecksumInfo
        if CGXE.CustomCode.SettingChecksum2InterfaceAndFullChecksumManager.hasCached(settingsChecksum)
            checksumStruct=CGXE.CustomCode.SettingChecksum2InterfaceAndFullChecksumManager.getCached(settingsChecksum);
            interfaceChecksum=checksumStruct.interfaceChecksum;
            fullCheckSum=checksumStruct.fullChecksum;
            dllFullPath=checksumStruct.dllFullPath;
            return;
        end
    end

    if isRefRebuild



        ccInfo.isTokenized=false;
        ccInfo.customCodeSettings.userIncludeDirs=ccInfo.cachedForModelRefRebuild.userIncludeDirs;
        ccInfo.customCodeSettings.userSources=ccInfo.cachedForModelRefRebuild.userSources;
        ccInfo.customCodeSettings.userLibraries=ccInfo.cachedForModelRefRebuild.userLibraries;
        modelName='';
        projRootDir='';
        ccInfo=tokenizeCCInfo(ccInfo,modelName,projRootDir,ccInfo.cachedForModelRefRebuild.modelRootDir);
    end





    ccInfo.feOpts.Preprocessor.SystemIncludeDirs{end+1}=slcc('getSLCCTempHeaderDir');

    chkMgr=CGXE.CustomCode.CheckSumManager(ccInfo.feOpts,settingsChecksum,'',ccInfo.dllFullPath);


    chkCustomCode=[];
    if~isempty(ccInfo.customCodeSettings.customCode)
        customCode=ccInfo.customCodeSettings.customCode;
        chkCustomCode=chkMgr.computeCheckSum(chkCustomCode,customCode,false);
    end
    interfaceChecksumArr=CGXE.Utils.md5(ccInfo.settingsChecksum,chkCustomCode,cgxe('Feature','CFunctionCpp'));
    interfaceChecksum=cgxe('MD5AsString',interfaceChecksumArr);

    checkSum=chkMgr.computeCompilerCheckSum(ccInfo.settingsChecksum);


    if~isempty(ccInfo.customCodeSettings.customSourceCode)
        customSourceCode=ccInfo.customCodeSettings.customSourceCode;
        checkSum=chkMgr.computeCheckSum(checkSum,customSourceCode,false);
    end


    chkFiles=[];
    for ii=1:numel(ccInfo.customCodeSettings.userSources)
        chkFiles=chkMgr.computeCheckSum(chkFiles,...
        ccInfo.customCodeSettings.userSources{ii},true,ccInfo.userSourcesRawTokens{ii});
    end

    for ii=1:numel(ccInfo.customCodeSettings.userLibraries)
        chkFiles=chkMgr.computeLibCheckSum(chkFiles,...
        ccInfo.customCodeSettings.userLibraries{ii});
    end



    checkSum=CGXE.Utils.md5(checkSum,interfaceChecksumArr,chkFiles);
    fullCheckSum=cgxe('MD5AsString',checkSum);
    dllFullPath=ccInfo.dllFullPath;

    if useCachedChecksumInfo
        checksumStruct.interfaceChecksum=interfaceChecksum;
        checksumStruct.fullChecksum=fullCheckSum;
        checksumStruct.dllFullPath=ccInfo.dllFullPath;
        CGXE.CustomCode.SettingChecksum2InterfaceAndFullChecksumManager.setCached(settingsChecksum,checksumStruct);
    end

end

