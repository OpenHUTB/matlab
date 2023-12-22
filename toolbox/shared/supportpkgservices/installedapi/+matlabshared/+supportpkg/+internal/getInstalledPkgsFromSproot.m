function spList=getInstalledPkgsFromSproot(spRoot)

    spList=[];
    installedPkgs=matlabshared.supportpkg.internal.getInstalledMathWorksProducts(spRoot);

    for i=1:numel(installedPkgs)
        baseCode=char(installedPkgs(i).basecode);

        pluginInfo=matlabshared.supportpkg.internal.getSpPkgInfoForBaseCode(baseCode);
        if isempty(pluginInfo)


            baseProduct='';
        else

            baseProduct=pluginInfo.BaseProduct;
        end
        pkgStruct=struct('DisplayName',char(installedPkgs(i).name),...
        'Version',char(installedPkgs(i).version),...
        'BaseProduct',baseProduct,...
        'BaseCode',baseCode,...
        'Visible',true);
        spList=[spList,pkgStruct];%#ok<AGROW>
    end

end
