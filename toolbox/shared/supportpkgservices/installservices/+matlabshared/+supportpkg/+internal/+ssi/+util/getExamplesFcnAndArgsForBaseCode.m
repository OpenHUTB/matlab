function fcnHandle=getExamplesFcnAndArgsForBaseCode(baseCode,spRoot)

    validateattributes(baseCode,{'char'},{'nonempty'},'getExamplesFcnAndArgsForBaseCode','baseCode',1);
    validateattributes(spRoot,{'char'},{'nonempty'},'getExamplesFcnAndArgsForBaseCode','spRoot',2);
    assert(logical(exist(spRoot,'dir')),sprintf('spRoot directory: %s does not exist',spRoot));

    fcnHandle=function_handle.empty;

    try
        installedPackages=matlabshared.supportpkg.internal.InstalledDocUtils.getInstalledDocInfo(spRoot);
        allFullNamesUnderHelpRoot=[installedPackages.DisplayName];
    catch
        installedPackages=[];
        allFullNamesUnderHelpRoot={};
    end

    spPkgHelpRoot=[];
    spNameFromInstallData=matlabshared.supportpkg.internal.ssi.util.getFullNameForBaseCode(baseCode,spRoot);
    pkgIdx=ismember(allFullNamesUnderHelpRoot,{spNameFromInstallData});

    if any(pkgIdx)
        spPkgHelpRoot=char(installedPackages(pkgIdx).SupportPackageHelpRoot);
    end
    featuredExamplesIndex=fullfile(spPkgHelpRoot,'examples.html');

    if~isempty(spPkgHelpRoot)&&logical(exist(featuredExamplesIndex,'file'))
        fcnHandle=@()web(featuredExamplesIndex,'-helpbrowser');
        return;
    end
    pluginInfo=matlabshared.supportpkg.internal.getSpPkgInfoForBaseCode(baseCode);
    if~isempty(pluginInfo)&&~isempty(pluginInfo.ExtraInfoCheckBoxCmd)
        fcnHandle=@()matlabshared.supportpkg.internal.ssi.util.evaluateCmd(pluginInfo.ExtraInfoCheckBoxCmd);
    end
end