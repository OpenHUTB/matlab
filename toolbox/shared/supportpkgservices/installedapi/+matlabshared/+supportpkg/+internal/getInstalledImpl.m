function installedPkgList=getInstalledImpl()
















    installedPkgList=getInstalled_SSI();
end

function spList=getInstalled_SSI()





    try
        spRoot=matlabshared.supportpkg.internal.getSupportPackageRootNoCreate();
    catch

        spRoot='';
    end
    spList=matlabshared.supportpkg.internal.getInstalledPkgsFromSproot(spRoot);
end