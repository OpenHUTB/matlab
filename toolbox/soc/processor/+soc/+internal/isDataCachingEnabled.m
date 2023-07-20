function out=isDataCachingEnabled(modelName,isRefModel)%#ok<INUSD>




    out=false;
    cs=getActiveConfigSet(modelName);
    paramStorage=DAStudio.message('codertarget:ui:CacheDataStorage');
    if codertarget.data.isParameterInitialized(cs,paramStorage)
        out=boolean(codertarget.data.getParameterValue(cs,paramStorage));
    end
end
