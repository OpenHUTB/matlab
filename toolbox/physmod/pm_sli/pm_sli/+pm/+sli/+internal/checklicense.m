function[licenseFound,errorMsg]=checklicense(hBlock)




    licenseFound=true;
    errorMsg='';

    skipLicenseCheck=pm.sli.isBlockInLibrary(hBlock)||...
    pm.simscape.internal.isSimscapeComponentDependent(hBlock);

    if~skipLicenseCheck
        product=pmsl_defaultproduct;
        licenseFound=pmsl_checklicense(product);

        if~licenseFound
            errorMsg=getString(message('physmod:pm_sli:sl:InvalidLicense',...
            product,getfullname(hBlock)));
        end
    end

end
