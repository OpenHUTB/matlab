classdef dlcodegenConfigBase<handle


























    properties(Access=public)
        DeepLearningConfig;
        GpuConfig;
        BatchSize;
        GenCodeOnly;
        CustomInclude;
        CustomLibrary;
        CustomSource;
        TargetDir;
        Hardware;
    end

    properties(Hidden,SetAccess=public,GetAccess=public)
        TargetLang;
        TargetFile;
        DebugMode;
        Toolchain;
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        coderCfg;
        OutputType;
    end

    methods(Hidden)
        function cfgObj=dlcodegenConfigBase(OutputType,targetlib)
            narginchk(0,2);
            try
                if nargin<1


                    OutputType='lib';
                    targetlib=dlcoder_base.internal.getDefaultTargetLib();
                elseif nargin<2



                    targetlib=dlcoder_base.internal.getDefaultTargetLib();
                end


                cfgObj.OutputType=upper(OutputType);


                cfgTypes={'DLL','LIB','EXE'};
                if~any(strcmpi(cfgObj.OutputType,cfgTypes))
                    error(message('gpucoder:validate:UnsupportedConfigType',cfgObj.OutputType));
                end


                cfgObj.BatchSize=1;
                cfgObj.GenCodeOnly=false;
                cfgObj.DebugMode=false;
                cfgObj.TargetLang='C++';


                cfgObj.TargetFile='cnn_exec.cpp';



                gpuTargetLibs={'cudnn','tensorrt'};
                if any(strcmpi(targetlib,gpuTargetLibs))
                    cfgObj.GpuConfig=coder.GpuCodeConfig;
                    cfgObj.GpuConfig.Enabled=true;
                    cfgObj.GpuConfig.MallocMode='Discrete';
                end


                targetlib=lower(targetlib);




                cfgObj.DeepLearningConfig=coder.DeepLearningConfig(targetlib);

            catch e
                throw(e);
            end
        end




        function setCoderConfig(dlcodeCfg)


            dlcodeCfg.coderCfg=coder.config(dlcodeCfg.OutputType);


            dlcodeCfg.coderCfg.DeepLearningConfig=dlcodeCfg.DeepLearningConfig;


            if(~isempty(dlcodeCfg.GpuConfig))
                dlcodeCfg.coderCfg.GpuConfig=dlcodeCfg.GpuConfig;
                dlcodeCfg.coderCfg.GpuConfig.Enabled=true;
                dlcodeCfg.coderCfg.GpuConfig.MallocMode='Discrete';
            end


            dlcodeCfg.coderCfg.GenCodeOnly=dlcodeCfg.GenCodeOnly;
            dlcodeCfg.coderCfg.TargetLang=dlcodeCfg.TargetLang;

            if(~isempty(dlcodeCfg.CustomSource))
                dlcodeCfg.coderCfg.CustomSource=dlcodeCfg.CustomSource;
            end

            if(~isempty(dlcodeCfg.CustomInclude))
                dlcodeCfg.coderCfg.CustomInclude=dlcodeCfg.CustomInclude;
            end

            if(~isempty(dlcodeCfg.CustomLibrary))
                dlcodeCfg.coderCfg.CustomLibrary=dlcodeCfg.CustomLibrary;
            end

            if(~isempty(dlcodeCfg.Hardware))
                dlcodeCfg.coderCfg.Hardware=dlcodeCfg.Hardware;
            end
            dlcodeCfg.coderCfg.BuildConfiguration='Faster Runs';
            if(~isempty(dlcodeCfg.DebugMode)&&dlcodeCfg.DebugMode)
                dlcodeCfg.coderCfg.BuildConfiguration='Debug';
            end
        end

        function validateToolchainOptions(dlcodeCfg)
            tcNames={'NVIDIA CUDA for Jetson Tegra K1 v6.5 | gmake (64-bit Linux)',...
            'NVIDIA CUDA for Jetson Tegra X1 | gmake (64-bit Linux)',...
            'NVIDIA CUDA for Jetson Tegra X2 | gmake (64-bit Linux)'};
            aValue=dlcodeCfg.Toolchain;

            matchingTCs={};
            for i=1:numel(tcNames)
                if contains(tcNames{i},aValue,'IgnoreCase',true)
                    matchingTCs{end+1}=tcNames{i};%#ok<AGROW>
                end
            end
            if numel(matchingTCs)>1


                for i=1:numel(matchingTCs)
                    if strcmp(aValue,matchingTCs{i})
                        matchingTCs={matchingTCs{i}};%#ok<CCAT1>
                        break;
                    end
                end

                if numel(matchingTCs)>1
                    error(message('Coder:configSet:MultipleMatchingToolchainName',aValue,strjoin(matchingTCs,'\n')));
                end
            elseif(isempty(matchingTCs))
                error(message('Coder:configSet:Invalid_ToolchainName',dlcodeCfg.Toolchain,strjoin(tcNames,'\n')));
            end
            dlcodeCfg.coderCfg.Toolchain=matchingTCs{1};
        end




        function setToolchain(dlcodeCfg)


            if~isempty(dlcodeCfg.Toolchain)
                supportedTargetLibs={'cudnn'};
                if any(strcmpi(dlcodeCfg.coderCfg.DeepLearningConfig.TargetLibrary,supportedTargetLibs))


                    validateToolchainOptions(dlcodeCfg);
                else
                    error('Unsupported Toolchain for selected DeepLearning TargetLib');
                end
            else
                switch dlcodeCfg.coderCfg.DeepLearningConfig.TargetLibrary
                case{'cudnn','tensorrt'}
                    if(~contains(dlcodeCfg.coderCfg.Toolchain,'NVCC for NVIDIA Embedded Processors'))
                        dlcodeCfg.coderCfg.Toolchain=dltargets.cudnn.getToolchainForHost();
                    end
                case{'mkldnn','onednn'}
                    dlcodeCfg.coderCfg.Toolchain=dltargets.onednn.getToolchainForHost(dlcodeCfg);
                case 'arm-compute'
                    if(isempty(dlcodeCfg.coderCfg.Hardware))
                        dlcodeCfg.coderCfg.GenCodeOnly=true;

                        spkgroot=dlcoder_base.internal.getSpkgRoot('arm_neon');
                        assert(~isempty(spkgroot));
                        addpath(genpath(fullfile(spkgroot,'shared_dl_targets','registry')));
                        RTW.TargetRegistry.getInstance('reset');
                        dlcodeCfg.coderCfg.Toolchain='GNU Tools for ARM_COMPUTE';
                    end
                case 'arm-compute-mali'
                    dlcodeCfg.coderCfg.GenCodeOnly=true;
                    spkgroot=dlcoder_base.internal.getSpkgRoot('arm_mali');
                    assert(~isempty(spkgroot));
                    addpath(genpath(fullfile(spkgroot,'shared_dl_targets','registry')));
                    RTW.TargetRegistry.getInstance('reset');
                    dlcodeCfg.coderCfg.Toolchain='GNU Tools for ARM_COMPUTE';
                end
            end
        end


        function cleanup(this)

            if(strcmp(this.DeepLearningConfig.TargetLibrary,'arm-compute'))
                spkgroot=dlcoder_base.internal.getSpkgRoot('arm_neon');
            end

            if(strcmp(this.DeepLearningConfig.TargetLibrary,'arm-compute-mali'))
                spkgroot=dlcoder_base.internal.getSpkgRoot('arm_mali');
            end

            armTargetLibs={'arm-compute','arm-compute-mali'};
            if any(strcmpi(this.DeepLearningConfig.TargetLibrary,armTargetLibs))
                rmpath(fullfile(spkgroot,'shared_dl_targets','registry'));
                RTW.TargetRegistry.getInstance('reset');
            end
        end



        function setupDeepLearningConfig(dlcodeCfg)
            if isprop(dlcodeCfg.coderCfg,'DeepLearningConfig')&&~isempty(dlcodeCfg.coderCfg.DeepLearningConfig)
                GpuEnabledState=~isempty(dlcodeCfg.coderCfg.GpuConfig)&&dlcodeCfg.coderCfg.GpuConfig.Enabled;
                try
                    dlcodeCfg.coderCfg.DeepLearningConfig.preBuild(dlcodeCfg.coderCfg);
                catch err
                    throw(err);
                end
                if~GpuEnabledState&&(~isempty(dlcodeCfg.coderCfg.GpuConfig)&&dlcodeCfg.coderCfg.GpuConfig.Enabled)

                    dlcodeCfg.coderCfg.GpuConfig.MallocMode='Discrete';
                end
            end
        end



        function validateAndSetBuildConfig(this)

            dlcodeCfg=this;


            validateattributes(dlcodeCfg.BatchSize,{'numeric'},{'scalar','>',0});
            validateattributes(dlcodeCfg.DebugMode,{'logical'},{});
            dlcodeCfg.TargetDir=createLogDir(dlcodeCfg);




            setCoderConfig(dlcodeCfg);


            setupDeepLearningConfig(dlcodeCfg);


            dlcodeCfg.coderCfg.DeepLearningConfig.validate(dlcodeCfg.coderCfg,true);


            setToolchain(dlcodeCfg);

        end

    end
end


function[TargetDir]=createLogDir(dlcodeCfg)
    if~isempty(dlcodeCfg.TargetDir)
        TargetDir=createDir(dlcodeCfg.TargetDir,'a');
    else
        TargetDir=fullfile(pwd,'codegen');
    end

    checkDirName(TargetDir);
end


function d=createDir(d,mode)
    function exists=directoryExists(d)
        [exists,message]=fileattrib(d);
        if exists
            exists=message.directory==true;
        end
    end
    checkDirName(d);
    makeNewDir=true;
    switch mode
    case 'a'
        if directoryExists(d)
            makeNewDir=false;
        end
    case 'w'
        if directoryExists(d)
            emlcprivate('emcDeleteDir',d);
        end
    end

    if makeNewDir
        [status,msg,~]=mkdir(d);
        if status==0
            emlcprivate('ccdiagnosticid','Coder:configSet:CannotCreateDirectory',d,msg);
        end
    end

    [status,attributes]=fileattrib(d);
    if~status
        emlcprivate('ccdiagnosticid','Coder:configSet:CannotAccessDirectory',d);
    end
    d=attributes.Name;
end


function checkDirName(d)
    function tf=canConvertUTF16ToLCP(d)
        tf=strcmp(native2unicode(unicode2native(d)),d);
    end

    badchars='[\$#*?]';


    badpos=regexp(d,badchars,'once');
    if~isempty(badpos)
        emlcprivate('ccdiagnosticid','Coder:configSet:DirectoryNameHasBadChar',...
        d,d(badpos));
    end
    if~canConvertUTF16ToLCP(d)
        emlcprivate('ccdiagnosticid','Coder:configSet:FolderBadUTF162LCPCompat',d);
    end
end







