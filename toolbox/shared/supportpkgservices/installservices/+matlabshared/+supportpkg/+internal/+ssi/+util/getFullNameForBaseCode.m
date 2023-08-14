function spNameFromInstallData=getFullNameForBaseCode(baseCode,spRoot)






    validateattributes(baseCode,{'char'},{'nonempty'},'getFullNameForBaseCode','baseCode',1);
    validateattributes(spRoot,{'char'},{'nonempty'},'getFullNameForBaseCode','spRoot',2);
    assert(logical(exist(spRoot,'dir')),sprintf('spRoot directory: %s does not exist',spRoot));
    installedSupportPackages=matlabshared.supportpkg.internal.getInstalledMathWorksProducts(spRoot);
    spNameFromInstallData='';

    for i=1:numel(installedSupportPackages)
        if strcmp(installedSupportPackages(i).basecode,baseCode)
            spNameFromInstallData=char(installedSupportPackages(i).name);
            return;
        end
    end
end
