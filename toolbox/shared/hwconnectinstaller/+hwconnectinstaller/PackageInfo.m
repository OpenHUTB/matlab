classdef PackageInfo<handle














    methods

        function h=PackageInfo
        end
    end

    methods(Static,Access=public)
        function rootDir=getTpPkgRootDir(tpPkgName,spPkg)
































            validateattributes(tpPkgName,{'char'},{'nonempty'});

            try


                rootDir=hwconnectinstaller.internal.ComponentDispNameReader.get3PInstallLocByDispName(tpPkgName);
            catch






                if isempty(spPkg)
                    rootDir='';
                    return;
                end




                validateattributes(spPkg,{'hwconnectinstaller.LegacySupportPackage'},{});
                internalSpPkg=spPkg.getInternalSupportPkgObj();
                rootDir=hwconnectinstaller.internal.PackageInfo.getTpPkgRootDir(tpPkgName,internalSpPkg);
            end
        end


        function supportPkg=getSpPkgInfo(name)
















            validateattributes(name,{'char'},{'nonempty'},'getSpPkgInfo','name');
            supportPkg=hwconnectinstaller.RegistryUtils.getRegistrationInfo(name);
            if~isempty(supportPkg)
                supportPkg=hwconnectinstaller.LegacySupportPackage(supportPkg);
            end
        end

    end

end


