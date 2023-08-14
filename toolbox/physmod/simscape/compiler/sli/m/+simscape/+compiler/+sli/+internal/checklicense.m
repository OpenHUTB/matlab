function[licenseFound,errorStruct]=checklicense(hBlock)









    narginchk(1,1);

    licenseFound=true;
    errorStruct=struct('message','');



    skipLicenseCheck=pm.sli.isBlockInLibrary(hBlock)||...
    simscape.compiler.sli.internal.isbuildinglib()||...
    pm.simscape.internal.isSimscapeComponentDependent(hBlock);


    if~skipLicenseCheck

        product=pmsl_defaultproduct();
        if pm.sli.internal.isDefaultProductInstalled()
            licenseFound=pmsl_checklicense(product);
        else


            licenseFound=false;
        end

        if~licenseFound
            msg=message('physmod:pm_sli:sl:InvalidLicense',...
            product,getfullname(hBlock));
            errorStruct=struct('message',msg.getString());
        end

    end

end
