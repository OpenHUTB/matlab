classdef Hardware<coder.HardwareBase




    properties(SetAccess=private,GetAccess=public)
Name
    end

    properties
        CPUClockRate=1000
    end

    properties(Access=private,Dependent)
TargetAttributes
    end

    properties(Access=private)
        ValidateCPUClockRateFcn function_handle
AttributesObj
    end

    properties(Hidden,GetAccess=public,SetAccess=private)
        Version='1.0'
TargetVersion
    end

    properties(Hidden,Constant)
        SUPPORTED_DATA_TYPES={...
        'double',...
        'single',...
        'logical',...
        'char',...
        'int8',...
        'uint8',...
        'int16',...
        'uint16',...
        'int32',...
        'uint32',...
        'int64',...
        'uint64'}
    end


    methods(Access=public)
        function obj=Hardware(name)
            name=convertStringsToChars(name);
            validateattributes(name,{'char'},{'nonempty','row'},...
            '','name');

            obj.HardwareInfo=i_targetHardwareInfo(name);


            if~i_supportsMATLABPIL(obj.HardwareInfo)
                error(message('codertarget:utils:NoMATLABPIL',name));
            end


            obj.Name=obj.HardwareInfo.Name;
            if~isempty(obj.HardwareInfo.MATLABPILInfo.GetPropsFcn)&&...
                ~obj.HardwareInfo.SupportsOnlySimulation
                [props,paramInfo]=...
                feval(obj.HardwareInfo.MATLABPILInfo.GetPropsFcn);


                [targetVersion,idx]=coder.matlabtarget.getTargetVersion(props);
                if~isempty(targetVersion)
                    obj.TargetVersion=targetVersion;
                    props(idx)=[];
                end

                obj=i_addDynamicHardwareProps(obj,props);

                CPUClockRateProps=i_getCPUClockRateProps(props);
                if~isempty(CPUClockRateProps)

                    if isfield(CPUClockRateProps,'SetMethod')
                        obj.ValidateCPUClockRateFcn=CPUClockRateProps.SetMethod;
                    end

                    if isfield(CPUClockRateProps,'DefaultValue')
                        obj.CPUClockRate=CPUClockRateProps.DefaultValue;
                    end
                end
            else
                paramInfo=[];
            end


            if~isempty(paramInfo)
                obj.ParameterInfo=paramInfo;
            end
        end

        function addedToConfig(obj,cfg)
            if cfg.HardwareImplementation.ProdEqTarget
                cfg.HardwareImplementation.ProdHWDeviceType=obj.HardwareInfo.ProdHWDeviceType;
            else
                cfg.HardwareImplementation.TargetHWDeviceType=obj.HardwareInfo.ProdHWDeviceType;
            end
            cfg.Toolchain=obj.HardwareInfo.ToolChainInfo(1).Name;
            cfg.BuildConfiguration='Faster Runs';

            if~isempty(obj.TargetVersion)&&(obj.TargetVersion>=2)

                if~isempty(obj.TargetAttributes.OnHardwareSelectHook)
                    feval(obj.TargetAttributes.OnHardwareSelectHook,cfg);
                end
            end
        end

        function preBuild(obj,cfg)








            if~ismember(cfg.OutputType,{'LIB','EXE','DLL'})
                error(message('codertarget:build:UnsupportedMATLABCoderBuild',obj.Name));
            end

            if~isempty(obj.TargetVersion)&&(obj.TargetVersion>=2)

                if~isempty(obj.TargetAttributes.OnCodeGenEntryHook)
                    feval(obj.TargetAttributes.OnCodeGenEntryHook,cfg);
                end
            end
        end

        function postCodegen(obj,cfg,buildInfo)
            codertarget.postCodeGenHookMATLABTarget(obj,cfg,buildInfo);

            if~isempty(obj.TargetVersion)&&(obj.TargetVersion>=2)

                addTargetSourceFiles(obj.TargetAttributes,cfg,buildInfo);
                if~isempty(obj.TargetAttributes.OnAfterCodeGenHook)
                    feval(obj.TargetAttributes.OnAfterCodeGenHook,cfg,buildInfo);
                end
            end
        end

        function errorHandler(obj,cfg)

            if isfield(obj.TargetAttributes,'OnErrorHook')&&...
                ~isempty(obj.TargetAttributes.OnErrorHook)
                feval(obj.TargetAttributes.OnErrorHook,cfg);
            end
        end

        function postBuild(obj,cfg,buildInfo)
            if isa(cfg,'coder.EmbeddedCodeConfig')&&~isequal(cfg.VerificationMode,'None')

                return;
            end

            if~isempty(obj.TargetVersion)&&(obj.TargetVersion>=2)
                targetInfo=codertarget.targethardware.getTargetHardware(cfg);
                if~isequal(targetInfo.ToolChainInfo.LoadCommand,'dummy')
                    if isprop(cfg.Hardware,'BuildAction')
                        if~isequal(cfg.Hardware.BuildAction,'Build')
                            invokeDownloader(cfg,buildInfo,targetInfo.ToolChainInfo)
                        end
                    else
                        invokeDownloader(cfg,buildInfo,targetInfo.ToolChainInfo)
                    end
                end
            end
        end
    end


    methods
        function set.CPUClockRate(obj,val)
            validateattributes(val,{'double'},...
            {'scalar','real','finite','positive','nonnan'},'','CPUClockRate');

            if~isempty(obj.ValidateCPUClockRateFcn)%#ok<MCSUP>
                obj.ValidateCPUClockRateFcn(obj,val);%#ok<MCSUP>
            end

            obj.CPUClockRate=val;
        end

        function set.ValidateCPUClockRateFcn(obj,val)
            obj.ValidateCPUClockRateFcn=val;
        end

        function s=saveobj(obj)

            s.Name=obj.Name;
            s.CPUClockRate=obj.CPUClockRate;
            s.Version=obj.Version;
        end

        function targetAttributes=get.TargetAttributes(obj)
            if isempty(obj.AttributesObj)


                obj.AttributesObj=codertarget.attributes.getTargetHardwareAttributesForHardwareName(obj.HardwareInfo,'matlab');
            end
            targetAttributes=obj.AttributesObj;
        end
    end

    methods(Static)
        function obj=loadobj(s)
            if isstruct(s)



                obj=coder.hardware(s.Name);
                obj.CPUClockRate=s.CPUClockRate;
                obj.Version=s.Version;
            end
        end
    end
end



function ret=i_supportsMATLABPIL(hwInfo)

    ret=isprop(hwInfo,'MATLABPILInfo')&&...
    ~isempty(hwInfo.MATLABPILInfo);
end


function tgtHWInfo=i_targetHardwareInfo(name)
    tgtHWInfo=codertarget.targethardware.getTargetHardwareFromName(name,'matlab');
    if numel(tgtHWInfo)==1

        return
    elseif isempty(tgtHWInfo)

        supportedBoards=i_cell2DisplayStr(coder.internal.getHardwareNames());
        error(message('codertarget:utils:NoSuchHardware').getString(),supportedBoards,name);
    elseif numel(tgtHWInfo)>1



        tgtHWInfo=codertarget.targethardware.getTargetHardwareFromNameForEC(name,'matlab');
    end
end


function obj=i_addDynamicHardwareProps(obj,props)

    CPUClockRateIdx=arrayfun(@(x)isequal(x.Name,'CPUClockRate'),props);
    props(CPUClockRateIdx)=[];

    for j=1:numel(props)
        P=addprop(obj,props(j).Name);
        if~isempty(props(j).SetMethod)
            P.SetMethod=props(j).SetMethod;
        end
        if~isempty(props(j).GetMethod)
            P.GetMethod=props(j).GetMethod;
        end
        if isfield(props(j),'SetAccess')
            if~isempty(props(j).SetAccess)
                P.SetAccess=props(j).SetAccess;
            end
        end

        if isfield(props(j),'Dependent')
            P.Dependent=logical(props(j).Dependent);
        end

        if isfield(props(j),'DefaultValue')
            if~P.Dependent
                P.HasDefault=true;
                P.DafaultValue=props(j).DefaultValue;
            end
        end
    end
end



function CPUClockRateProp=i_getCPUClockRateProps(props)

    CPUClockRateIdx=find(arrayfun(@(x)isequal(x.Name,'CPUClockRate'),props));
    if any(CPUClockRateIdx)
        CPUClockRateProp=props(CPUClockRateIdx(1));
    else
        CPUClockRateProp=[];
    end
end



function invokeDownloader(cfg,buildInfo,toolchainInfo)
    toolchainName=cfg.Toolchain;
    if isequal(toolchainName,coder.make.internal.getInfo('default-toolchain'))
        toolchainName=coder.make.getDefaultToolchain();
    end
    toolchain=coder.make.internal.getToolchainInfoFromRegistry(toolchainName);
    try


        if length(toolchainInfo)>1
            indx=getToolchainPos(toolchainInfo,toolchainName);
            assert(indx,...
            getString(message('codertarget:build:InvalidToolchain',toolchainName)));
            toolchainInfo=toolchainInfo(indx);
        end

        useToolchainToDownload=~toolchainInfo.IsLoadCommandMATLABFcn...
        &&toolchain.PostbuildTools.isKey('Download');
        if~useToolchainToDownload
            loadCommand=toolchainInfo.LoadCommand;
            if~isempty(toolchainInfo.LoadCommandArgs)
                try
                    try

                        arguments=feval(toolchainInfo.LoadCommandArgs,cfg);
                    catch


                        arguments=eval(toolchainInfo.LoadCommandArgs);
                    end
                catch e %#ok<NASGU>
                    arguments=toolchainInfo.LoadCommandArgs;
                end
            else
                arguments=[];
            end
            exeFile=getExecutable(buildInfo,toolchain);
            hardwareName=cfg.Hardware.Name;
            if toolchainInfo.IsLoadCommandMATLABFcn
                if~isempty(arguments)
                    feval(loadCommand,cfg,arguments,buildInfo.ModelName,exeFile,hardwareName);
                else
                    feval(loadCommand,cfg,buildInfo.ModelName,exeFile,hardwareName);
                end
            else
                system(loadCommand,arguments,exeFile,hardwareName);
            end
        end
    catch e
        DAStudio.error('codertarget:build:DownloadCallbackError',char([10,e.message]));
    end
end



function str=i_cell2DisplayStr(values)
    str=' ';
    for i=1:length(values)
        str=[str,'''',values{i},''''];%#ok<AGROW>
        if i~=length(values)
            str=[str,', '];%#ok<AGROW>
        end
    end
end



function exeFile=getExecutable(buildInfo,toolchain)
    linker=toolchain.getBuildTool('Linker');
    b=linker.FileExtensions;
    c=b.getValue('Executable');
    ext=c.getValue;

    mainSrcDir=getSourcePaths(buildInfo,1,'BuildDir');
    codeGenFolder=fileparts(fileparts(fileparts(mainSrcDir{1})));
    fcnName=buildInfo.ModelName;

    exeFile=fullfile(codeGenFolder,[fcnName,ext]);
end



function addTargetSourceFiles(targetAttributes,cfg,buildInfo)
    srcFiles=codertarget.utils.replaceTokens(cfg,targetAttributes.getSourceFiles(),targetAttributes.Tokens);
    for i=1:length(srcFiles)
        [path,name,exe]=fileparts(srcFiles{i});
        buildInfo.addSourceFiles([name,exe],path);
    end
end




function indx=getToolchainPos(toolchainInfo,toolchainName)
    indx=0;
    for cnt=1:length(toolchainInfo)
        if strcmp(toolchainInfo(cnt).Name,toolchainName)
            indx=cnt;
            break;
        end
    end
end

