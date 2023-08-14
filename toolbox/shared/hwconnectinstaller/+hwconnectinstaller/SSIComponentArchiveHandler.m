classdef SSIComponentArchiveHandler<hwconnectinstaller.ArchiveHandler







    methods(Access=public)


        function spPkg=getPkgListFromFolder(obj,folder)
            spPkg=hwconnectinstaller.SupportPackage;
            spPkg(1)=[];

            commonZipFiles=hwconnectinstaller.util.recursiveDir(fullfile(folder,'archives','common'),'*.zip');
            spPkg=obj.getSppkgData(commonZipFiles,spPkg);

            spPkg=hwconnectinstaller.util.getInstallableSupportPackages(fullfile(folder,'archives'),spPkg);
        end

        function diagnoseInstallFromFolder(~,folder)


            error(message(hwconnectinstaller.internal.getAdjustedMessageID(...
            'hwconnectinstaller:setup:Install_NoInstallablePkgFound'),...
            folder));
        end

        function toolboxPath=getToolboxPath(~,options)

            if isequal(options.populateRootDir,false)
                toolboxPath='';
            else
                toolboxPath=fileparts(fileparts(options.dataFiles));
            end
        end

        function tpPkg=loadTpPkgInfo(~,loadTarget,thirdPartyXML,options)











            if~exist('options','var')
                options=struct();
            end

            if~isfield(options,'currentPlatformOnly')
                options.currentPlatformOnly=true;
            end


            if exist('thirdPartyXML','var')&&~isempty(thirdPartyXML)
                loadTarget=thirdPartyXML;
            end

            tpPkg=hwconnectinstaller.internal.PackageInfo.readTpPkgRegistry(loadTarget,options);
        end

        function spPkg=loadSpPkgInfo(~,loadTarget,options)








            spPkg=hwconnectinstaller.internal.PackageInfo.readSpPkgRegistry(loadTarget,options);

        end



    end

end
