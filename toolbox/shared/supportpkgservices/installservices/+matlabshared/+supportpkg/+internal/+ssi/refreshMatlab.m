function refreshMatlab()

    rehash pathreset;
    skipSLRefresh=getenv('SSI_MLREFRESH_SKIP_SIMULINK_REFRESH');

    if isempty(skipSLRefresh)...
        &&matlabshared.supportpkg.internal.ssi.util.isProductInstalled('Simulink')
        sl_refresh_customizations;

        lb=slLibraryBrowser('noshow');
        lb.refresh;
    else
        if exist('RTW.TargetRegistry','class')
            RTW.TargetRegistry.getInstance('reset');
        end

    end

    try %#ok<TRYNC> 
        matlab.internal.doc.invalidateSupportPackageCache();
        matlab.internal.reference.cache.ClearAllCaches();
    end
    spRoot=matlabshared.supportpkg.internal.getSupportPackageRootNoCreate();
    if(not(isempty(spRoot)))
        matlabshared.supportpkg.internal.ssi.util.loadMsgCatResourcesIfAvailable(spRoot);
    end
end
