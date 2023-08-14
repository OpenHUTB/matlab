classdef(Abstract,Hidden=true)CheckBuildManager<handle









    properties(Hidden,Access=protected)
        ComponentBuildInfo;
        ConfigInterface;
        ComponentName;
        CAPath;
        IsHost;
        StartDir;
    end

    methods
        function this=CheckBuildManager(aComponentBuildInfo,aConfigInterface,aComponentName,aCAPath,aStartDir,isHost)

            this.ComponentBuildInfo=aComponentBuildInfo;
            this.ConfigInterface=aConfigInterface;
            this.ComponentName=aComponentName;
            this.CAPath=aCAPath;
            this.StartDir=aStartDir;
            this.IsHost=isHost;
        end
    end

    methods(Abstract,Access=public)


        addToLibrary(this,aBuildInfo,componentArgs);
    end

    methods(Sealed,Access=public)

        function caBuildInfo=getEmptyLibraryBuildInfo(this,lXilCompInfo)





            caBuildInfo=RTW.BuildInfo;


            caBuildInfo.CompilerRequirements=inheritRequirementsFromDonor...
            (caBuildInfo.CompilerRequirementsDirect,...
            this.ComponentBuildInfo.CompilerRequirements);

            libExt=lXilCompInfo.XilLibraryExt;
            [~,libraryName]=fileparts(...
            coder.assumptions.CoderAssumptions.getLibraryName(...
            this.ComponentName,libExt));
            caBuildInfo.ModelName=libraryName;

            caBuildInfo.setStartDir(this.StartDir);

            staticSrcPath=rtw.pil.RtIOStreamApplicationFramework.getXILSrcPath;
            caBuildInfo.addSourcePaths({staticSrcPath,this.CAPath});


            componentInclPaths=this.ComponentBuildInfo.getIncludePaths(true);
            caBuildInfo.addIncludePaths([...
            {staticSrcPath},...
            {this.CAPath},...
            componentInclPaths]);



            purelyIntegerCode=this.ConfigInterface.getParam('PurelyIntegerCode');
            checkFloatingPoint=strcmp(purelyIntegerCode,'off');
            caCheckFloatingPointDefineName='CA_CHECK_FLOATING_POINT_ENABLED';
            caBuildInfo.addDefines(sprintf('%s=%d',caCheckFloatingPointDefineName,checkFloatingPoint),'OPTS');



            coder.internal.mergeBuildInfoContent(this.ComponentBuildInfo,caBuildInfo);


            if this.IsHost&&strcmp(this.ConfigInterface.getParam('PortableWordSizes'),'on')
                rtw.pil.BuildInfoHelpers.updateBuildInfoToSkipLinkLibsAndOptions(caBuildInfo);
            end


            caBuildInfo.Settings.TargetInfo=this.ComponentBuildInfo.Settings.TargetInfo;
        end
    end

    methods(Access=protected)

        function success=trapDoCompile(this,buildInfo,lXilCompInfo)




            success=true;


            isPWS=strcmp(this.ConfigInterface.getParam('PortableWordSizes'),'on');
            buildPath=coder.assumptions.CoderAssumptions.getLibraryBuildFolder(...
            this.CAPath,this.IsHost,isPWS);
            coder.assumptions.CoderAssumptions.mkdir(buildPath);

            if isPWS&&this.IsHost

                addDefines(buildInfo,'-DPORTABLE_WORDSIZES','OPTS');
            end

            try
                buildInfo.ComponentBuildFolder=buildPath;
                codebuild(buildInfo,...
                'ComponentsToBuild',{buildInfo.ComponentName},...
                'BuildMethod',lXilCompInfo.ToolchainOrTMF,...
                'BuildConfiguration',lXilCompInfo.BuildConfiguration,...
                'CustomToolchainOptions',lXilCompInfo.CustomToolchainOptions,...
                'generateCodeOnly',false,...
                'LegacyTargetLibSuffix',lXilCompInfo.XilLibraryExt);
            catch ME %#ok<NASGU>
                success=false;
            end

            if success

                libExt=lXilCompInfo.XilLibraryExt;
                coder.assumptions.CoderAssumptions.deleteLibraryFile(...
                fullfile(buildPath,...
                coder.assumptions.CoderAssumptions.getLibraryName(...
                this.ComponentName,libExt)));
            end
        end

    end

end
