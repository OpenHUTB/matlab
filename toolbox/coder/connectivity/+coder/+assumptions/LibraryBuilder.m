classdef(Hidden=true)LibraryBuilder<handle







    properties(Hidden,Access=private)
        CheckManagers={};
        ComponentName;
        ComponentArgs;
        CAPath;
        CABuildInfo;
        IsHost;
        AuxiliaryMakefileContent;
        ConfigInterface;
    end


    methods(Static,Access=public)

        function buildStaticLibrary(buildDir,startDir,configInterface,...
            componentArgs,isHost,componentBuildInfoPath,...
            lXilCompInfo)




            lAuxiliaryMakefileContent=coder.internal.getCoderTargetAuxMakefileContent...
            (componentArgs.getComponentCodePath());


            builder=coder.assumptions.LibraryBuilder(...
            buildDir,startDir,configInterface,componentArgs,...
            isHost,componentBuildInfoPath,...
            lAuxiliaryMakefileContent);


            doBuild(builder,lXilCompInfo);
        end

    end

    methods(Access=private)

        function this=LibraryBuilder(buildDir,startDir,configInterface,...
            componentArgs,isHost,componentBuildInfoPath,...
            lAuxiliaryMakefileContent)


            this.ConfigInterface=configInterface;
            this.ComponentName=this.ConfigInterface.getCodeGenComponent;
            this.ComponentArgs=componentArgs;
            this.CAPath=coder.assumptions.CoderAssumptions.getBuildFolder(...
            buildDir);
            this.IsHost=isHost;


            this.AuxiliaryMakefileContent=lAuxiliaryMakefileContent;


            assert(exist(componentBuildInfoPath,'file')==2,'Component buildInfo not found');
            componentBuildInfo=targets_load_buildinfo(componentBuildInfoPath);





            this.addManager(...
            coder.assumptions.StandardChecksBuildManager(componentBuildInfo,...
            this.ConfigInterface,this.ComponentName,this.CAPath,startDir,this.IsHost));

            this.addManager(...
            coder.assumptions.DAZCheckBuildManager(componentBuildInfo,...
            this.ConfigInterface,this.ComponentName,this.CAPath,startDir,this.IsHost));
        end


        function doBuild(this,lXilCompInfo)

            numManagers=numel(this.CheckManagers);
            assert(numManagers>=1,'CaLibrary builder has no check build-managers');

            this.CABuildInfo=this.CheckManagers{1}.getEmptyLibraryBuildInfo(lXilCompInfo);



            for idx=1:numManagers
                this.CheckManagers{idx}.addToLibrary(this.CABuildInfo,this.ComponentArgs,lXilCompInfo);
            end



            isPWS=strcmp(this.ConfigInterface.getParam('PortableWordSizes'),'on');
            buildPath=coder.assumptions.CoderAssumptions.getLibraryBuildFolder(...
            this.CAPath,this.IsHost,isPWS);
            coder.assumptions.CoderAssumptions.mkdir(buildPath);

            this.CABuildInfo.addSourcePaths(buildPath,{'BuildDir'});




            isVerboseBuild=strcmp(this.ConfigInterface.getParam('RTWVerbose'),'on');




            tmfDebug=tmfIsDebugBuild(this);
            if tmfDebug

                removeBuildArgs(this.CABuildInfo,'DEBUG_BUILD');
                addBuildArgs(this.CABuildInfo,'DEBUG_BUILD','1','MakeArg');
            end

            if isPWS&&this.IsHost

                addDefines(this.CABuildInfo,'-DPORTABLE_WORDSIZES','OPTS');
            end


            lBuildVariant='STATIC_LIBRARY';
            lBuildName=coder.make.internal.getFinalTargetName(lBuildVariant,this.CABuildInfo.ModelName);


            lBuildOpts=coder.make.BuildOpts;
            lBuildOpts.BuildMethod=lXilCompInfo.ToolchainOrTMF;
            lBuildOpts.BuildName=lBuildName;
            lBuildOpts.BuildVariant=lBuildVariant;
            lBuildOpts.MakefileBasedBuild=true;



            this.CABuildInfo.ComponentBuildFolder=buildPath;

            coder.make.internal.saveBuildArtifacts(this.CABuildInfo,lBuildOpts);

            caLibName=coder.assumptions.CoderAssumptions.getLibraryName(...
            this.ComponentName,lXilCompInfo.XilLibraryExt);




            lUpdatedLibPoller=coder.make.internal.UpdatedLibArchivePoller...
            ({buildPath},{caLibName});

            buildResult=coder.internal.doCompile(buildPath,this.CABuildInfo,lXilCompInfo.ToolchainOrTMF,...
            'RTWVerbose',isVerboseBuild,...
            'BuildConfiguration',lXilCompInfo.BuildConfiguration,...
            'CustomToolchainOptions',lXilCompInfo.CustomToolchainOptions,...
            'generateCodeOnly',false,...
            'CoderTargetAuxMakeContent',this.AuxiliaryMakefileContent,...
            'LegacyTargetLibSuffix',lXilCompInfo.XilLibraryExt);


            pollForUpdatedLibArchives(lUpdatedLibPoller,buildResult);

        end

        function addManager(this,aManager)

            assert(isa(aManager,'coder.assumptions.CheckBuildManager'));
            this.CheckManagers{end+1}=aManager;
        end

        function tmfDebug=tmfIsDebugBuild(this)

            makeCommand=this.ConfigInterface.getParam('MakeCommand');

            tmfDebug=coder.internal.isDebugFromMakeCommand(makeCommand);

        end
    end
end
