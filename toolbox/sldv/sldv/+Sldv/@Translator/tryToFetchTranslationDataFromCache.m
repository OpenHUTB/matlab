function tryToFetchTranslationDataFromCache(obj)
    compatDataInfo=Sldv.CompatDataInfo();
    try
        [filename,fileExt]=obj.getTranslationDataFileName();
        filename=fullfile(obj.mCacheDirFullPath,[filename,fileExt]);
        compatDataInfo.sldvCachePath=filename;

        [filename,fileExt]=obj.getTranslationDvoFileName();
        filename=fullfile(obj.mCacheDirFullPath,[filename,fileExt]);
        compatDataInfo.dvoCachePath=filename;
    catch
        return;
    end

    obj.mCompatDataInfo=compatDataInfo;
end