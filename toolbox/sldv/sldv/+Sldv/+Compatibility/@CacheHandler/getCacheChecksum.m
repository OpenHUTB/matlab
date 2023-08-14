




function componentChecksum=getCacheChecksum(obj)

    [dvoFileName,fExt]=obj.getTranslationDvoFileName();
    dvoFileName=fullfile(obj.mCacheDirFullPath,[dvoFileName,fExt]);
    assert(isfile(dvoFileName),'DVO missing from cache');
    dvoChecksum=Simulink.getFileChecksum(dvoFileName);


    [modelMapFileName,fExt]=obj.getTranslationDataFileName();
    modelMapFileName=fullfile(obj.mCacheDirFullPath,[modelMapFileName,fExt]);
    assert(isfile(modelMapFileName),'ModelMap missing from cache');
    modelMapChecksum=Simulink.getFileChecksum(modelMapFileName);

    if~obj.mIsXIL||~slavteng('feature','SILReuseTranslation')
        componentChecksum=struct('dvoChecksum',dvoChecksum,'modelMapChecksum',modelMapChecksum);
        return;
    end

    [xilDbFileName,fExt]=obj.getXILDataFileName();
    xilDbFileName=fullfile(obj.mCacheDirFullPath,[xilDbFileName,fExt]);
    assert(isfile(xilDbFileName),'XIL DB missing from cache')
    xilDbCheckSum=Simulink.getFileChecksum(xilDbFileName);
    componentChecksum=struct('dvoChecksum',dvoChecksum,'modelMapChecksum',modelMapChecksum,'xilDBCheckSum',xilDbCheckSum);
end
