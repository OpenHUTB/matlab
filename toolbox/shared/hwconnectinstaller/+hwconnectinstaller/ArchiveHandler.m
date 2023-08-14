classdef ArchiveHandler<hwconnectinstaller.internal.PackageInfo







    properties(Constant,Hidden)
        TPPKGXMLFILE='thirdparty_package_registry.xml';
        SPPKGXMLFILE='support_package_registry.xml';
    end

    methods(Static)
        function handler=getInstance()




            useNewStyleArchive=hwconnectinstaller.util.getSupportPackageFormat();

            if strcmpi(useNewStyleArchive,'UBERZIP')
                handler=hwconnectinstaller.ComponentArchiveHandler();

            else
                handler=hwconnectinstaller.SSIComponentArchiveHandler();

            end
        end
    end

    methods(Abstract,Access=public)

        spPkg=getPkgListFromFolder(obj,folder)
        toolboxPath=getToolboxPath(obj,options)
        tpPkg=loadTpPkgInfo(obj,loadTarget,thirdPartyXML,options)
        spPkg=loadSpPkgInfo(obj,loadTarget,options)
        diagnoseInstallFromFolder(obj,folder)
    end

    methods(Access=protected)
        function pattern=getSpPkgArchiveNameRegexpPattern(~)



            mlRelease=hwconnectinstaller.util.getCurrentRelease();
            mlRelTag=hwconnectinstaller.SupportPackage.getReleaseTag(mlRelease);
            pattern=['(?<pkgTag>[a-zA-Z0-9]+)_',mlRelTag,'_(?<verTag>\w+)'];
        end

        function spPkg=getLatestSppkgs(~,spPkg)
            if~isempty(spPkg)
                [spPkgNames{1:length(spPkg)}]=deal(spPkg.Name);
                spPkgNames=unique(spPkgNames);
                if length(spPkgNames)~=length(spPkg)
                    for i=1:length(spPkgNames)
                        pkgIndx=false(1,length(spPkg));
                        pkgVer=zeros(1,length(spPkg));
                        for j=1:length(spPkg)
                            if isequal(spPkg(j).Name,spPkgNames{i})
                                pkgVer(j)=spPkg(j).NumericVersion;
                                pkgIndx(j)=true;
                            end
                        end
                        [~,j_max]=max(pkgVer);
                        pkgIndx(j_max)=false;
                        spPkg(pkgIndx)=[];
                    end
                end
            end
        end
    end
end