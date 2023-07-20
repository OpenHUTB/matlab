classdef ThirdPartyPkgStrategy



    properties(Constant)
        THIRDPARTYPACKAGE_DL_TIMEOUT_SECONDS=15;
        INSTALLTP_PCT_INIT=0.05;
        INSTALLTP_PCT_START=0.1;
        INSTALLTP_PCT_END=0.9;
    end

    properties(Access=public)
hSetup
    end


    methods(Abstract,Access=public)











        tppkg=installThirdPartyPackages(obj,pkgInstaller,spPkg,tppkg,downloadDir,installDir,opts)









        tppkg=downloadThirdPartyPackage(obj,tppkg,downloadDir,opts)





        tpInfo=preDownloadCmd(obj,tppkg,instructionSetFile)



        localInstructionSetFile=downloadInstructionSet(obj,downloadDir,tppkg,spPkg)
    end


    methods(Static,Access=public)

        function thirdPartyConsistencyCheck(alltpPkgObj)






            validateattributes(alltpPkgObj,{'hwconnectinstaller.ThirdPartyPackage'},{'nonempty'});

            alltppkgNames={alltpPkgObj.Name};

            tpPkgName=unique(alltppkgNames);



            for i=1:numel(tpPkgName)
                index=ismember(alltppkgNames,tpPkgName{i});
                currTpPkgObjs=alltpPkgObj(index);
                isConsistent=hwconnectinstaller.internal.ThirdPartyPkgStrategy.verifyThirdPartyStrategyConsistency...
                (currTpPkgObjs);
                assert(isConsistent,sprintf('All platforms for %s must either use instruction set or legacy SPI based strategy for download and install of third-party tools',tpPkgName{i}))
            end
        end

        function flag=areAllTpPkgsInstructionSets(alltpPkgObj)
            validateattributes(alltpPkgObj,{'hwconnectinstaller.ThirdPartyPackage'},{'nonempty'});
            flag=all(~cellfun(@isempty,{alltpPkgObj.InstructionSet}));
        end



        function checkInstallDirectory(thirdPartyPkgName,installDir)





            validateattributes(thirdPartyPkgName,{'char'},{'nonempty'});
            validateattributes(installDir,{'char'},{'nonempty'});

            hdir=hwconnectinstaller.util.Location(installDir);
            if~hdir.exists
                error((message('hwconnectinstaller:installapi:InstallFolderDoesNotExist',thirdPartyPkgName,installDir)));
            end
            if~hdir.isFolderWritable
                error(message('hwconnectinstaller:installapi:NoWritePermissions',...
                thirdPartyPkgName,installDir));
            end
        end

        function tppkg=getTpPkgObject(tppkg,downloadDir,varargin)
            if nargin==3
                installDir=varargin{1};
                tppkg.InstallDir=fullfile(installDir);
                tppkg.RootDir=fullfile(installDir,tppkg.DestDir);
                tppkg.IsInstalled=true;
            end
            tppkg.Archive=fullfile(regexprep(tppkg.Archive,'\$\(INSTALLER\)',...
            tppkg.Installer));


            tppkg.DestDir=fullfile(tppkg.DestDir);
            tppkg.Installer=fullfile(tppkg.Installer);
            tppkg.DownloadDir=downloadDir;
        end
    end


    methods(Static,Hidden,Access=private)

        function isConsistent=verifyThirdPartyStrategyConsistency(tpPkgObjs)



            hasInstructionSet=~cellfun(@isempty,{tpPkgObjs.InstructionSet});
            isConsistent=all(hasInstructionSet==hasInstructionSet(1));
        end

    end

end