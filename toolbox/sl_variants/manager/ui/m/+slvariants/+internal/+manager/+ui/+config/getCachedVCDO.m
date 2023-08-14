function vcdoCache=getCachedVCDO(sourceCacheObj,skipVCDOMissingInWksCheck)






    vcdoCache=[];
    if skipVCDOMissingInWksCheck||~sourceCacheObj.IsVariantConfigurationMissingInWks





        vcdoCache=sourceCacheObj.VariantConfigurationCatalogCache;
    end
end


