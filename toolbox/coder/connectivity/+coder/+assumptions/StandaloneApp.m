classdef(Hidden=true)StandaloneApp<handle








    properties(Constant,Access=private)
        MainFilePostfix='_ca';
        AppNamePostfix='_ca';
        SourceExt='.c';
        HeaderExt='.h';
        AppBuildFolderName='standalone';
        StaticSrcFile='coder_assumptions_standalone';
    end

    properties(Access=private)
        ComponentName;
        CodeGenDir;
        ConfigInterface;
        ComponentBuildInfo;
    end


    properties(Dependent,Access=private)
        StartDir;
    end

    methods(Static,Access=public)

        function generate(codeGenDir)

            standaloneApp=coder.assumptions.StandaloneApp(codeGenDir);
            standaloneApp.doGenerate;
        end

        function fileName=getMainFileName(component)

            fileName=[component...
            ,coder.assumptions.StandaloneApp.MainFilePostfix,...
            coder.assumptions.StandaloneApp.SourceExt];
        end

        function dir=getBuildFolder(codeGenDir)

            caLibPath=coder.assumptions.CoderAssumptions.getBuildFolder(codeGenDir);
            dir=fullfile(caLibPath,...
            coder.assumptions.StandaloneApp.AppBuildFolderName);
        end

        function appName=getAppName(component)

            appName=[component,coder.assumptions.StandaloneApp.AppNamePostfix];
        end

    end

    methods
        function startDir=get.StartDir(this)



            startDir=regexprep(...
            this.ComponentBuildInfo.Settings.LocalAnchorDir,...
            '[\\/]',filesep);
        end
    end

    methods(Access=private)

        function this=StandaloneApp(codeGenDir)


            this.validateCodeGenDir(codeGenDir);

        end

        function doGenerate(this)


            checksControlStruct=struct('CoderAssumptionsDAZCheckEnabled',{true},...
            'getComponentCodePath',{@()fileparts(this.getBuildInfoFileName)});

            obfuscateCode=false;


            isHost=false;


            cs=getResolvedConfig(this.ConfigInterface);
            if isa(cs,'Simulink.ConfigSet')
                lIsSilAndPws=false;
                lDefaultCompInfo=coder.internal.DefaultCompInfo.createDefaultCompInfo;
                lXilCompInfo=coder.internal.utils.XilCompInfo.slCreateXilCompInfo...
                (cs,lDefaultCompInfo,lIsSilAndPws);
            else
                lXilCompInfo=coder.internal.utils.XilCompInfo...
                .mlCreateXilCompInfo(cs);
            end


            coder.assumptions.CoderAssumptions.generateCoderAssumptionsChecks(...
            this.CodeGenDir,this.StartDir,this.ConfigInterface,...
            checksControlStruct,isHost,this.getBuildInfoFileName,obfuscateCode,lXilCompInfo,'UTF-8');


            standaloneDir=coder.assumptions.StandaloneApp.getBuildFolder(this.CodeGenDir);
            coder.assumptions.CoderAssumptions.mkdir(standaloneDir);


            appMainWriter=coder.assumptions.StandaloneAppMainWriter(standaloneDir,this.ComponentName);
            appMainWriter.writeOutput(obfuscateCode);


            appBuildInfo=this.createAppBuildInfo(lXilCompInfo);


            isVerboseBuild=true;





            lBuildVariant='STANDALONE_EXECUTABLE';
            lBuildName=coder.make.internal.getFinalTargetName(lBuildVariant,appBuildInfo.ModelName);


            lBuildOpts=coder.make.BuildOpts;
            lBuildOpts.BuildMethod=lXilCompInfo.ToolchainOrTMF;
            lBuildOpts.BuildName=lBuildName;
            lBuildOpts.BuildVariant=lBuildVariant;
            lBuildOpts.MakefileBasedBuild=true;



            appBuildInfo.ComponentBuildFolder=standaloneDir;

            coder.make.internal.saveBuildArtifacts(appBuildInfo,lBuildOpts);


            [lBuildConfiguration,lCustomToolchainOptions]=...
            coder.internal.overrideBuildConfigAndOptionsForDebug...
            (lXilCompInfo.ToolchainOrTMF,lXilCompInfo.BuildConfiguration,...
            lXilCompInfo.CustomToolchainOptions,appBuildInfo);

            appBuildInfo.ComponentBuildFolder=standaloneDir;
            codebuild(appBuildInfo,...
            'ComponentsToBuild',{appBuildInfo.ComponentName},...
            'BuildMethod',lXilCompInfo.ToolchainOrTMF,...
            'RTWVerbose',isVerboseBuild,...
            'BuildConfiguration',lBuildConfiguration,...
            'CustomToolchainOptions',lCustomToolchainOptions,...
            'generateCodeOnly',false,...
            'BuildVariant',lBuildVariant);
        end


        function validateCodeGenDir(this,codeGenDir)


            validateattributes(codeGenDir,{'char'},{'nonempty'},'','codeGenDir');
            codeGenDir=coder.internal.fullfileIfRelativePath(codeGenDir,pwd);
            if~isfolder(codeGenDir)
                rtw.connectivity.ProductInfo.error(...
                'target','CoderAssumptionsAppInvalidDir',codeGenDir);
            end
            codeDescName='codedescriptor.dmr';
            codeDescriptorPath=fullfile(codeGenDir,codeDescName);
            if isfile(codeDescriptorPath)
                this.CodeGenDir=codeGenDir;
            else
                rtw.connectivity.ProductInfo.error(...
                'target','CoderAssumptionsAppMissingFile',...
                codeGenDir,codeDescName);
            end

            [buildInfoFullName,buildInfoName]=this.getBuildInfoFileName;
            if isfile(buildInfoFullName)
                this.ComponentBuildInfo=targets_load_buildinfo(this.getBuildInfoFileName);
            else
                rtw.connectivity.ProductInfo.error(...
                'target','CoderAssumptionsAppMissingFile',...
                this.CodeGenDir,buildInfoName);
            end


            codeInfoFile=dir(fullfile(this.CodeGenDir,'*codeInfo.mat'));
            if isempty(codeInfoFile)
                rtw.connectivity.ProductInfo.error(...
                'target','CoderAssumptionsAppMissingFile',...
                this.CodeGenDir,'codeInfo.mat');
            else

                assert(isequal(numel(codeInfoFile),1),'Should have only one codeinfo file.');
                codeInfoStruct=load(fullfile(this.CodeGenDir,codeInfoFile.name));
                this.ComponentName=codeInfoStruct.codeInfo.Name;
                assert(~isempty(this.ComponentName),'Empty component name.');
            end


            if isfield(codeInfoStruct,'configInfo')

                coderConfig=codeInfoStruct.configInfo;
                this.ConfigInterface=coder.connectivity.MATLABConfig(coderConfig,this.ComponentName);
            else

                if strcmp(codeInfoFile.name,'codeInfo.mat')
                    buildType=rtw.pil.InTheLoopType.ModelBlockStandalone;
                else
                    buildType=rtw.pil.InTheLoopType.ModelBlock;
                end

                infoStruct=coder.connectivity.ComponentInterfaceArtifacts.createLocatorAndGetInfoStruct(...
                this.CodeGenDir,buildType,'WrapException',false);
                configSet=infoStruct.configSet;
                assert(~isempty(configSet),'Empty configset.');
                this.ConfigInterface=coder.connectivity.SimulinkConfig(configSet,this.ComponentName);


                if strcmp(this.ConfigInterface.getParam('TemplateMakefile'),'RTW.MSVCBuild')
                    rtw.connectivity.ProductInfo.error(...
                    'target','CoderAssumptionsMSVCBuildNotSupported',...
                    this.ComponentName);
                end
            end

        end


        function appBuildInfo=createAppBuildInfo(this,lXilCompInfo)



            appBuildInfo=RTW.BuildInfo;


            appBuildInfo.CompilerRequirements=inheritRequirementsFromDonor...
            (appBuildInfo.CompilerRequirementsDirect,...
            this.ComponentBuildInfo.CompilerRequirements);

            appBuildInfo.ModelName=coder.assumptions.StandaloneApp.getAppName(this.ComponentName);
            appBuildInfo.setStartDir(this.StartDir);
            standaloneAppPath=coder.assumptions.StandaloneApp.getBuildFolder(this.CodeGenDir);
            appBuildInfo.setOutputFolder(standaloneAppPath);


            appBuildInfo.addBuildArgs('MAKEFILEBUILDER_TGT','1');

            xilSrcPath=rtw.pil.RtIOStreamApplicationFramework.getXILSrcPath;
            appBuildInfo.addSourcePaths(standaloneAppPath,{'BuildDir'});
            appBuildInfo.addSourcePaths(xilSrcPath);

            caPath=coder.assumptions.CoderAssumptions.getBuildFolder(this.CodeGenDir);
            appBuildInfo.addIncludePaths(caPath);
            appBuildInfo.addIncludePaths(xilSrcPath);

            appBuildInfo.addSourceFiles(...
            coder.assumptions.StandaloneApp.getMainFileName(this.ComponentName),standaloneAppPath);

            appBuildInfo.addIncludeFiles(...
            coder.assumptions.CoderAssumptions.getHeaderFileName(this.ComponentName),caPath);

            appBuildInfo.addSourceFiles(...
            coder.assumptions.StandaloneApp.getStaticCFileName,xilSrcPath);
            appBuildInfo.addIncludeFiles(...
            coder.assumptions.StandaloneApp.getStaticHFileName,xilSrcPath);

            isHost=false;
            isPWS=false;
            libExt=lXilCompInfo.XilLibraryExt;
            caLibPath=coder.assumptions.CoderAssumptions.getLibraryBuildFolder(caPath,isHost,isPWS);
            caLibName=fullfile(caLibPath,...
            coder.assumptions.CoderAssumptions.getLibraryName(...
            this.ComponentName,libExt));
            rtw.pil.RtIOStreamApplicationFramework.addLibsToBuildInfo(appBuildInfo,caLibName);



            coder.internal.mergeBuildInfoContent(this.ComponentBuildInfo,appBuildInfo);


            appBuildInfo.addIncludePaths(this.ComponentBuildInfo.getIncludePaths(true));

            appBuildInfo.Settings.TargetInfo=this.ComponentBuildInfo.Settings.TargetInfo;
        end


        function[fullFilename,filename]=getBuildInfoFileName(this)
            assert(~isempty(this.CodeGenDir),'CodeGenDir should not be empty.');
            filename='buildInfo.mat';
            fullFilename=fullfile(this.CodeGenDir,filename);
        end

    end


    methods(Static,Access=private)

        function file=getStaticCFileName()
            file=[coder.assumptions.StandaloneApp.StaticSrcFile...
            ,coder.assumptions.StandaloneApp.SourceExt];
        end

    end

    methods(Static,Access=public)

        function file=getStaticHFileName()
            file=[coder.assumptions.StandaloneApp.StaticSrcFile...
            ,coder.assumptions.StandaloneApp.HeaderExt];
        end

    end
end
