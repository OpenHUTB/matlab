function openHwSetupForBaseCodes(baseCodeArray)









    baseCodeArray=cellstr(string(baseCodeArray));




    try
        matlab.internal.msgcat.setAdditionalResourceLocation(...
        matlabshared.supportpkg.getSupportPackageRoot);
    catch
    end



    if numel(baseCodeArray)>1

        entryPoint='ssiSetupNow';
        matlabshared.supportpkg.internal.ssi.util.openAddOnsManager(entryPoint);



    else

        sppkgObj=matlabshared.supportpkg.internal.getSpPkgInfoForBaseCode(...
        baseCodeArray{1});


        fwUpdateClassName=sppkgObj.FwUpdate;

        assert(~isempty(fwUpdateClassName),...
        ['No Hardware Setup available for the specified base code: ',baseCodeArray{1}]);



        fwUpdateSuperClassList=superclasses(fwUpdateClassName);



        if any(ismember(fwUpdateSuperClassList,'hwconnectinstaller.FirmwareUpdate'))
            matlabshared.supportpkg.internal.sppkglegacy.launchTargetupdaterForBaseCodes(baseCodeArray);


        elseif any(ismember(fwUpdateSuperClassList,...
            'matlab.hwmgr.internal.hwsetup.Workflow'))
            matlab.hwmgr.internal.hwsetup.launchHardwareSetupApp(fwUpdateClassName,char(baseCodeArray));

        else
            assert(false,['Incorrect value for the field fwupdate in the support_package_registry.xml for support package with Base Code: ',baseCodeArray{1}]);
        end
    end


