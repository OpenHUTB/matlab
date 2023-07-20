function[isInstallable,info,errMsg]=isSupportPkgInstallable(sppkg)

















    info.PlatformIsCompatible=ismember(computer,sppkg.Platform);
    info.BaseProductIsPresent=hwconnectinstaller.internal.isProductInstalled(sppkg.BaseProduct);
    isInstallable=info.PlatformIsCompatible&&info.BaseProductIsPresent;

    if(nargout==3)
        if isInstallable
            errMsg='';
        else



            platformList=hwconnectinstaller.util.getPrettyPlatform(sppkg.PlatformStr);
            msg=message('hwconnectinstaller:setup:Signpost_UI_PkgNotInstallable',...
            sppkg.FullName,sppkg.BaseProduct,platformList);
            errMsg=msg.getString();
        end
    end
