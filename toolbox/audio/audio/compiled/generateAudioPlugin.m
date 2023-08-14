function generateAudioPlugin(varargin)









































































    if nargin>0
        [varargin{:}]=convertStringsToChars(varargin{:});
    end


    if nargin==0
        dlg=audio.app.internal.plugin.AudioPluginGeneratorDialog();
        dlg.show();
        return
    end





    if nargin==5&&isequal(varargin{1},'-PostCodeGenCommand')
        postCodeGenCommand(varargin{2:end});
        return
    end

    [className,pluginDstFullFile,win32,universal,format,showDialog,features]=processCommandLine(varargin{:});

    features.PcodeWrappers=false;

    [api,params]=checkPluginClass(className,format);

    outName=outNameFromClassName(className);

    checkWriteability(pluginDstFullFile,outName);

    if showDialog

        dlg=audio.app.internal.plugin.AudioPluginGeneratorDialog();
        dlg.setObjectUnderTest(className);
        dlg.show();
    else

        backend(outName,className,api,params,features,win32,universal,format,pluginDstFullFile);
    end
end

function[className,pluginDstFullFile,win32,universal,format,showDialog,features]=processCommandLine(varargin)














    win32=false;
    universal=false;
    showDialog=false;
    features=featureDefaults;
    outputName='';
    outdirName='';
    format='';
    i=1;
    while i<=nargin&&isOption(varargin{i})
        switch lower(varargin{i})
        case '-win32'
            win32=true;
            if~strcmp(computer('arch'),'win64')
                error(message('audio:plugin:win32OnlyOnWin64'));
            end
            i=i+1;
        case '-mac64universal'
            universal=true;
            if~ismac
                error(message('audio:plugin:universalOnlyOnMac','-mac64universal'));
            end
            i=i+1;
        case '-feature'
            if~(i<nargin&&isstruct(varargin{i+1}))
                error(message('audio:plugin:NoFeature'));
            end
            fs=varargin{i+1};
            if isfield(fs,'Verbose')&&islogical(fs.Verbose)
                features.Verbose=fs.Verbose;
                printVerboseStatus(fs.Verbose);
            end
            if isfield(fs,'PcodeWrappers')&&islogical(fs.PcodeWrappers)
                features.PcodeWrappers=fs.PcodeWrappers;
            end
            if isfield(fs,'DeleteWrappers')&&islogical(fs.DeleteWrappers)
                features.DeleteWrappers=fs.DeleteWrappers;
            end
            if isfield(fs,'CoderMode')&&ischar(fs.CoderMode)...
                &&ismember(fs.CoderMode,{'coderless','codegen','touch'})
                features.CoderMode=fs.CoderMode;
            end
            if isfield(fs,'DynamicMemoryAllocation')
                dma=fs.DynamicMemoryAllocation;
                if isequal(lower(dma),'off')
                    features.DynamicMemoryAllocation='off';
                elseif isa(dma,'double')&&isscalar(dma)&&...
                    isreal(dma)&&fix(dma)==dma&&dma>0
                    features.DynamicMemoryAllocation=dma;
                end
            end
            i=i+2;
        case '-preservecode'
            features.CoderMode='codegen';
            features.PcodeWrappers=true;
            features.DeleteWrappers=true;
            i=i+1;
        case{'-output','-o'}
            if i==nargin||isempty(varargin{i+1})
                error(message('audio:plugin:NoOutputFile'));
            elseif~isString(varargin{i+1})

                error(message('audio:plugin:BadOutputFile'));
            end
            outputName=varargin{i+1};
            i=i+2;
        case{'-outdir'}
            if i==nargin||isempty(varargin{i+1})
                error(message('audio:plugin:NoOutputDir'));
            elseif~isString(varargin{i+1})

                error(message('audio:plugin:BadOutputDir'));
            end
            outdirName=varargin{i+1};
            i=i+2;
        case '-au'
            if~isempty(format)
                error(message('audio:plugin:MultipleFormats',['-',format],varargin{i}));
            end
            if~ismac
                error(message('audio:plugin:AUMacOnly'));
            end
            format='au';
            i=i+1;
        case '-vst'
            if~isempty(format)
                error(message('audio:plugin:MultipleFormats',['-',format],varargin{i}));
            end
            format='vst';
            i=i+1;
        case '-vst3'
            if~isempty(format)
                error(message('audio:plugin:MultipleFormats',['-',format],varargin{i}));
            end
            format='vst3';
            i=i+1;
        case '-auv3'
            if~audio.internal.feature('EnableAUv3PluginGeneration')
                error(message('audio:plugin:BadOption',varargin{i}));
            end
            if~ismac
                error(message('audio:plugin:AUMacOnly'));
            end
            if~isempty(format)
                error(message('audio:plugin:MultipleFormats',['-',format],varargin{i}));
            end
            format='auv3';
            i=i+1;
        case '-juceproject'
            if~license("test","MATLAB_CODER")
                error(message("audio:plugin:NoCoderLicense"));
            end
            if~isempty(format)
                error(message('audio:plugin:MultipleFormats',['-',format],varargin{i}));
            end
            format='juceproject';
            i=i+1;
        case '-exe'
            if~isempty(format)
                error(message('audio:plugin:MultipleFormats',['-',format],varargin{i}));
            end
            format='exe';
            i=i+1;
        case '-audioconfig'
            if isa(varargin{i+1},'audioPluginConfig')
                cmdLineCoderConfig=varargin{i+1};
            else
                cmdLineCoderConfig=evalin('base',varargin{i+1});
                if~isa(cmdLineCoderConfig,'audioPluginConfig')
                    error(message('audio:plugin:BadAudioConfigCmdLine'));
                end
            end
            i=i+2;
        case '-showdialog'
            showDialog=true;
            i=i+1;
        otherwise
            error(message('audio:plugin:BadOption',varargin{i}));
        end
    end

    if i>nargin
        error(message('audio:plugin:NoClassName'));
    elseif i<nargin
        if isOption(varargin{i+1})

            error(message('audio:plugin:MisplacedOption',i+1));
        else

            error(message('audio:plugin:UnexpectedArgument',i+1));
        end
    end

    import matlab.internal.lang.capability.Capability;
    if showDialog

        assert(i==2,message('audio:plugin:ShowDialogLimitation','-showdialog'));
    else

        if~strcmp(format,'juceproject')&&~Capability.isSupported(Capability.LocalClient)
            error(message('audio:plugin:UnsupportedGenBinary','MATLAB Online'));
        end

        switch computer('arch')
        case{'win64','maci64','maca64'}

        case 'glnxa64'

            if~strcmp(format,'juceproject')
                error(message('audio:plugin:UnsupportedGenBinary','glnxa64'));
            end
        otherwise
            error(message('audio:plugin:UnsupportedPlatform',computer('arch')));
        end
    end

    if isempty(format)

        if strcmp(computer('arch'),'glnxa64')
            format='juceproject';
        else
            format='vst';
        end
    end


    className=varargin{i};
    if~isString(className)
        error(message('audio:plugin:NotAClass'));
    end
    className=audio.internal.classFromClassOrFileName(className);

    if~isempty(outputName)
        [p,f,ext]=fileparts(outputName);
        if~isempty(ext)&&~strcmpi(ext,pluginExt(format))
            error(message('audio:plugin:BadOutputExt',ext));
        end
        outputName=f;
        if isempty(outdirName)
            outdirName=p;
        else

        end
    else
        outputName=outNameFromClassName(className);
    end
    if isempty(outdirName)
        outdirName=pwd;
    end
    if~isempty(outdirName)&&~showDialog
        if~exist(outdirName,'dir')
            error(message('audio:plugin:NoOuputDir',outdirName));
        end
        [ok,m]=fileattrib(outdirName);
        if~ok

            error(message('audio:plugin:NoOuputDirAttrib',outdirName,m));
        end
        if~m.UserWrite
            error(message('audio:plugin:OuputDirNotWritable',outdirName));
        end
    end
    pluginDstFullFile=fullfile(outdirName,[outputName,pluginExt(format)]);


    if exist('cmdLineCoderConfig','var')
        crlVal=cmdLineCoderConfig.CodeReplacementLibrary;
        if~isempty(crlVal)
            features.CoderMode='codegen';
            features.CoderConfig.CodeReplacementLibrary=crlVal;
        end

        dlcfg=cmdLineCoderConfig.DeepLearningConfig;
        if~isempty(dlcfg)
            features.CoderConfig.DeepLearningConfig=dlcfg;
            features.PluginOutDir=outdirName;
        end
    else

        metaObj=meta.class.fromName(className);
        PluginPropList={metaObj.PropertyList.Name};
        PropIdx=find(strcmp(PluginPropList,'PluginConfig'),1);

        if~isempty(PropIdx)
            propCoderConfig=metaObj.PropertyList(PropIdx,1).DefaultValue;
            if~isa(propCoderConfig,'audioPluginConfig')
                error(message('audio:plugin:BadAudioConfigConstantProperty'));
            end


            crlVal=propCoderConfig.CodeReplacementLibrary;
            if~isempty(crlVal)
                features.CoderMode='codegen';
                features.CoderConfig.CodeReplacementLibrary=crlVal;
            end


            dlcfg=propCoderConfig.DeepLearningConfig;
            if~isempty(dlcfg)
                features.PluginOutDir=outdirName;
                features.CoderConfig.DeepLearningConfig=dlcfg;
            end
        end
    end

    dlcfg=features.CoderConfig.DeepLearningConfig;
    if win32&&isa(dlcfg,'coder.MklDNNConfig')
        error(message('audio:plugin:InvalidDeepLearningConfigWithWin32'));
    end

    crlVal=features.CoderConfig.CodeReplacementLibrary;
    if strcmp(crlVal,'none')
        features.CoderConfig.CodeReplacementLibrary='';
    end


    if win32&&~isempty(crlVal)
        error(message('audio:plugin:CrlNotSupportedWithWin32'));
    end


    if universal&&~(isempty(crlVal)&&isempty(dlcfg))
        error(message('audio:plugin:universalLimitations','-mac64universal'));
    end

    if~strcmp(format,'juceproject')&&strcmp(crlVal,'DSP Intel AVX2-FMA (Linux)')
        error(message('audio:plugin:UnsupportedBinaryGenForLinuxCRL',crlVal));
    end
end

function features=featureDefaults
    features.Verbose=false;
    features.CoderMode='coderless';
    features.PcodeWrappers=true;
    features.DeleteWrappers=true;
    features.DynamicMemoryAllocation='';
    features.CoderConfig=coderConfigDefaults;
end

function cfg=coderConfigDefaults
    cfg.CodeReplacementLibrary='';
    cfg.DeepLearningConfig='';
    cfg.PluginOutDir=pwd;
end

function checkWriteability(pluginDstFullFile,outName)



    path=sharedLibDstFullFile(pluginDstFullFile,outName);
    if exist(path,'file')
        [fid,msg]=fopen(path,'a');
        if fid<0
            error(message('audio:plugin:WriteCheckFailed',path,msg));
        else
            fclose(fid);
        end
    end
end

function path=emitGetPluginInstanceWrapper(dirName)
    s=sprintf([
'function y = getPluginInstance(varargin)  %%#codegen\n'...
    ,'    coder.inline(''never'');\n'...
    ,'    coder.allowpcode(''plain'');\n'...
    ,'    persistent plugin\n'...
    ,'    if isempty(plugin)\n'...
    ,'        plugin = derivedAudioPlugin(varargin{:});\n'...
    ,'    end\n'...
    ,'    y = plugin;\n'...
    ,'end\n'...
    ]);
    path=fullfile(dirName,'getPluginInstance.m');
    writeOutputFileIndented(path,s);
end

function path=emitDerivedAudioPlugin(dirName,className)
    s={};
    s{end+1}=sprintf([
    'classdef derivedAudioPlugin < ',className,'  %%#codegen\n'...
    ,'    methods\n'...
    ,'        function plugin = derivedAudioPlugin(varargin)\n'...
    ,'            %% Pass constructor args to plugin.\n'...
    ,'            plugin@',className,'(varargin{:});\n'...
    ,'            coder.allowpcode(''plain'');\n'...
    ,'        end\n'...
    ,'        function setSampleRate(~, ~)\n'...
    ,'            %% Throw if plugin sets its own sample rate.\n'...
    ,'            audio.internal.coderAssertWrapper(false, ''A plugin must not call setSampleRate() on itself'');\n'...
    ,'        end\n'...
    ,'        function n = getLatencyInSamplesInt32(plugin)\n'...
    ,'            n = plugin.PrivateLatency;\n'...
    ,'        end\n'...
    ]);
    if isSourcePlugin(className)
        s{end+1}=sprintf([
'        function n = getSamplesPerFrame(plugin)\n'...
        ,'            coder.inline(''always'');\n'...
        ,'            n = getSamplesPerFrame@audioPluginSource(plugin);\n'...
        ,'            %% Assertion helps reduce dynamic memory allocation.\n'...
        ,'            assert(n <= %d);\n'...
        ,'        end\n'...
        ],maxSamplesPerFrame);
    end
    s{end+1}=sprintf([
'    end\n'...
    ,'end\n'...
    ]);
    s=[s{:}];
    path=fullfile(dirName,'derivedAudioPlugin.m');
    writeOutputFileIndented(path,s);
end

function path=emitParamChangeWrapper(dirName,params)
    s={};
    s{end+1}=sprintf('function onParamChangeCImpl(paramIdx, value)  %%#codegen\n');
    s{end+1}=sprintf('coder.allowpcode(''plain'');\n');
    s{end+1}=sprintf('plugin = getPluginInstance;\n');
    s{end+1}=sprintf('switch paramIdx\n');
    for i=1:numel(params)
        param=params(i);
        name=param.Property;
        s{end+1}=sprintf('case %d\n',i-1);
        switch param.Law
        case 'enum'
            s{end+1}=sprintf('switch value\n');
            enums=cellstr(param.Enums);
            for j=1:numel(enums)
                s{end+1}=sprintf('case %d\n',j-1);
                s{end+1}=sprintf('plugin.%s = ''%s'';\n',name,enums{j});
            end
            s{end+1}=sprintf('end\n');
        case 'enumclass'
            defval=param.DefaultValue;
            [~,enumNames]=enumeration(defval);
            enums=sprintf([class(defval),'.%s '],enumNames{:});
            s{end+1}=sprintf('enums = [ %s];\n',enums);
            s{end+1}=sprintf('plugin.%s = enums(value + 1);\n',name);
        case 'logical'
            s{end+1}=sprintf('plugin.%s = logical(value);\n',name);
        otherwise
            s{end+1}=sprintf('plugin.%s = value;\n',name);
        end
    end
    s{end+1}=sprintf('end\n');
    s{end+1}=sprintf('end\n');

    path=fullfile(dirName,'onParamChangeCImpl.m');
    writeOutputFileIndented(path,s);
end

function path=emitProcessWrapper(dirName,className,api)














    s={};
    if matlab.system.isSystemObjectName(className)
        methodName='step';
    else
        methodName='process';
    end

    nin=sum(api.InputChannels);
    nout=sum(api.OutputChannels);
    mkNames=@(p,b,n)arrayfun(@(x)sprintf('%s%d',p,x),b:(b+n-1),'UniformOutput',false);
    inNames=mkNames('i',1,nin);
    outNames=mkNames('o',1,nout);
    [packedInputs,buffers]=packInputs(api.InputChannels,inNames);
    [packedOutputs,unpackingAssigns]=unpackOutputs(api.OutputChannels);

    proto=makeMPrototype('processEntryPoint',['samplesPerFrame',inNames],outNames);
    s{end+1}=sprintf('function %s %%#codegen\n',proto);
    s{end+1}=sprintf('coder.allowpcode(''plain'');\n');
    s{end+1}=[buffers{:}];
    s{end+1}=sprintf('plugin = getPluginInstance;\n');
    s{end+1}=sprintf('assert(samplesPerFrame <= %d);\n',maxSamplesPerFrame);
    if hasMethodNamed(meta.class.fromName(className),'setSamplesPerFrame')
        s{end+1}=sprintf('setSamplesPerFrameForProcess(plugin, samplesPerFrame);\n');
    end
    proto=makeMPrototype(methodName,['plugin',packedInputs],packedOutputs);
    s{end+1}=sprintf('%s;\n',proto);

    s=[s,unpackingAssigns];

    s{end+1}=sprintf('end\n');

    path=fullfile(dirName,'processEntryPoint.m');
    writeOutputFileIndented(path,s);
end


function[packedInputs,bufInits]=packInputs(widths,inputNames)
    packedInputs={};
    bufNameList={};
    bufInits={};
    for width=widths(:)'
        if width>1

            packedInputs{end+1}=['[',strjoin(inputNames(1:width)),']'];
        elseif width>0

            bufName=strrep(inputNames{1},'i','b');
            bufNameList{end+1}=bufName;
            packedInputs{end+1}=bufName;
            bufInits{end+1}=sprintf('%s = %s;\n',packedInputs{end},inputNames{1});
        end
        inputNames(1:width)=[];
    end
    if~isempty(bufNameList)
        bufNameList=strjoin(['persistent',bufNameList]);
        bufInits=[bufNameList,newline,bufInits];
    end
end




function[outputs,assigns]=unpackOutputs(widths)
    outputs={};
    assigns={};
    i=1;
    for j=1:numel(widths)
        width=widths(j);

        outputs{end+1}=sprintf('t%d',j);

        for k=1:width
            assigns{end+1}=sprintf('o%d = t%d(1:samplesPerFrame,%d);\n',i,j,k);

            i=i+1;
        end
    end
end

function touchPlugin(pluginPath)
    if ismac

        [~,~]=mkdir(pluginPath);
    else

        [~,~]=mkdir(fileparts(pluginPath));
        fid=openOutputFile(pluginPath);
        fclose(fid);
    end
end

function num=maxSamplesPerFrame

    num=4096;
end

function proto=makeMPrototype(name,inNames,outNames)
    switch numel(outNames)
    case 0
        out='';
    case 1
        out=[outNames{1},' = '];
    otherwise
        out=['[',strjoin(outNames,', '),'] = '];
    end

    if isempty(inNames)
        in='';
    else
        in=['(',strjoin(inNames,', '),')'];
    end
    proto=[out,name,in];
    assert(ischar(proto));
end

function makeWorkFolder(workFolder)
    if~exist(workFolder,'dir')
        [ok,msg]=mkdir(workFolder);
        if~ok
            error(message('audio:plugin:MkdirFailed',workFolder,msg));
        end
    end
end

function fid=openOutputFile(path)
    [fid,msg]=fopen(path,'w');
    if fid<0
        error(message('audio:plugin:FopenFailed',path,msg));
    end
end

function writeOutputFileIndented(path,s)
    if iscell(s)
        s=[s{:}];
    end
    fid=openOutputFile(path);
    fprintf(fid,'%s',indentcode(s));
    fclose(fid);
end

function writeOutputFile(path,s)
    if~iscell(s)
        s={s};
    end
    fid=openOutputFile(path);
    for i=1:numel(s)
        fprintf(fid,'%s\n',s{i});
    end
    fclose(fid);
end

function yes=isSourcePlugin(mc)
    if ischar(mc)
        mc=meta.class.fromName(mc);
    end
    apsmc=meta.class.fromName('audioPluginSource');
    yes=(mc<apsmc);
end

function yes=hasMethodNamed(mc,methodName)
    if ischar(mc)
        mc=meta.class.fromName(mc);
    end
    allMethodNames={mc.MethodList(:).Name};
    yes=any(strcmp(methodName,allMethodNames));
end

function yes=isString(s)
    yes=ischar(s)&&isrow(s);
end

function yes=isOption(s)
    yes=isString(s)&&~isempty(s)&&s(1)=='-';
end

function ext=pluginExt(format)
    if isequal(format,'juceproject')
        ext='.zip';
    elseif ispc
        switch format
        case 'vst'
            ext='.dll';
        case 'vst3'
            ext='.vst3';
        case 'juceproject'
            ext='.project';
        case 'exe'
            ext='.exe';
        otherwise
            assert(false,['unexpected plugin format: ',format]);
        end
    elseif ismac
        switch format
        case 'au'
            ext='.component';
        case 'auv3'
            ext='.app';
        case 'vst'
            ext='.vst';
        case 'vst3'
            ext='.vst3';
        case 'juceproject'
            ext='.project';
        case 'exe'
            ext='.app';
        otherwise
            assert(false,['unexpected plugin format: ',format]);
        end
    else
        assert(false,'unexpected platform');
    end
end


function ff=sharedLibDstFullFile(pluginDstFullFile,outName)
    if ismac
        ff=fullfile(pluginDstFullFile,'Contents','MacOS',outName);
    else
        ff=pluginDstFullFile;
    end
end



function[sdType,pdType,initFcn,termFcn,termHasArg]=mineCodeInfo(matFile)
    x=load(matFile,'codeInfo');


    assert(~isempty(x),'internal error: failed to load codeInfo.mat');
    assert(~isempty(x.codeInfo.InternalData),'internal error: codeInfo.InternalData is empty');
    impl=x.codeInfo.InternalData(1).Implementation;
    assert(~isempty(impl),'internal error: codeInfo.InternalData.Implementation is empty');
    assert(strcmp(impl.Identifier,'SD'),'internal error: codeInfo.InternalData.Implementation is not SD');
    assert(impl.Type.isPointer==1,'internal error: stack data is not a pointer');
    assert(impl.Type.BaseType.isStructure==1,'internal error: stack data is not a struct pointer');
    sdType=impl.Type.BaseType.Identifier;


    elems=impl.Type.BaseType.Elements;

    ids=arrayfun(@(x)x.Identifier,elems,'UniformOutput',false);
    pd=elems(strcmp(ids,'pd'));
    assert(~isempty(pd),'internal error: stack data field is not pd');
    assert(pd.Type.isPointer==1,'internal error: stack data field pd is not a pointer');
    assert(pd.Type.BaseType.isStructure==1,'internal error: stack data field pd is not a struct pointer');
    pdType=pd.Type.BaseType.Identifier;


    assert(~isempty(x.codeInfo.InitializeFunctions),'internal error: no initialize function were generated');
    assert(numel(x.codeInfo.InitializeFunctions)==1,'internal error: multiple initialize functions were generated');
    assert(~isempty(x.codeInfo.InitializeFunctions.Prototype),'internal error: initialize function prototype is empty');
    initFcn=x.codeInfo.InitializeFunctions.Prototype.Name;
    assert(~isempty(initFcn),'internal error: generated initialize function has no name');


    initArg=x.codeInfo.InitializeFunctions.Prototype.Arguments;
    assert(~isempty(initArg),'internal error: generated initialize function has no arguments');
    assert(numel(initArg)==1,'internal error: generated initialize function has multiple arguments');
    assert(strcmp(initArg.Name,'SD'),'internal error: generated initialize function argument is not SD');
    assert(initArg.Type.isPointer==1,'internal error: generated initialize function argument is not a pointer');
    assert(initArg.Type.BaseType.isStructure==1,'internal error: generated initialize function argument is not a struct pointer');
    assert(strcmp(initArg.Type.BaseType.Identifier,sdType),'internal error: generated initialize function argument is not a stack data pointer');


    if~isempty(x.codeInfo.TerminateFunctions)
        assert(numel(x.codeInfo.TerminateFunctions)==1,'internal error: generated terminate function has multiple arguments');
        assert(~isempty(x.codeInfo.TerminateFunctions.Prototype),'internal error: terminate function prototype is empty');
        termFcn=x.codeInfo.TerminateFunctions.Prototype.Name;
        assert(~isempty(termFcn),'internal error: generated terminate function has no name');


        termHasArg=~isempty(x.codeInfo.TerminateFunctions.Prototype.Arguments);
        if termHasArg

            assert(numel(x.codeInfo.TerminateFunctions.Prototype.Arguments)==1,...
            'internal error: generated terminate function has multiple arguments');
            assert(strcmp(x.codeInfo.TerminateFunctions.Prototype.Arguments.Name,'SD'),...
            'internal error: generated terminate function argument is not SD');
            assert(x.codeInfo.TerminateFunctions.Prototype.Arguments.Type.isPointer==1,...
            'internal error: generated terminate function argument is not a pointer');
            assert(x.codeInfo.TerminateFunctions.Prototype.Arguments.Type.BaseType.isStructure==1,...
            'internal error: generated terminate function argument is not a struct pointer');
            assert(strcmp(x.codeInfo.TerminateFunctions.Prototype.Arguments.Type.BaseType.Identifier,sdType),...
            'internal error: generated terminate function argument is not a stack data pointer');
        end
    end

    checkGeneratedArgs(x.codeInfo);
end

function checkGeneratedArgs(codeInfo)
    fcns=codeInfo.OutputFunctions;
    x=arrayfun(@(f)isequal(f.Prototype.Name,'processEntryPoint'),fcns);
    assert(sum(x)==1,'should be exactly one function ''processEntryPoint''');
    processFcn=fcns(x);
    args=processFcn.Prototype.Arguments;

    assert(strcmp(args(1).Name,'SD')...
    &&args(1).Type.isPointer...
    &&args(1).Type.BaseType.isStructure,...
    'processEntryPoint: first argument is not stack data');

    assert(strcmp(args(2).Name,'samplesPerFrame')...
    &&args(2).Type.isDouble,...
    'processEntryPoint: second argument is not samplesPerFrame');

    i=3;
    narg=1;
    while i<=numel(args)&&args(i).Name(1)=='i'
        checkProcessArgs(args(i:end),narg,false);
        i=i+2;
        narg=narg+1;
    end

    narg=1;
    while i<=numel(args)&&args(i).Name(1)=='o'
        checkProcessArgs(args(i:end),narg,true);
        i=i+2;
        narg=narg+1;
    end

    if~(i==numel(args)+1)
        error(message('audio:plugin:InvalidProcessIO'));
    end
end

function checkProcessArgs(args,idx,isOutput)
    if isOutput
        errid='audio:plugin:InvalidOutTypeSize';
        prefix=sprintf('o%d',idx);
    else
        errid='audio:plugin:InvalidInTypeSize';
        prefix=sprintf('i%d',idx);
    end

    if numel(args)<2
        error(message(errid,idx));
    end

    if~(strcmp(args(1).Name,[prefix,'_data'])&&isData(args(1)))
        error(message(errid,idx));
    end

    if~(strcmp(args(2).Name,[prefix,'_size'])&&isSize(args(2)))
        error(message(errid,idx));
    end

    function yes=isData(arg)
        yes=arg.Type.isMatrix...
        &&strcmp(arg.Type.Name,'matrixdouble')...
        &&arg.Type.BaseType.isDouble;
    end

    function yes=isSize(arg)
        yes=arg.Type.isMatrix...
        &&any(strcmp(arg.Type.Name,{'matrix1xint32','matrix1xint'}))...
        &&arg.Type.BaseType.isInteger;
    end

end

function postCodeGenCommand(~,~,buildInfo,sourceFolder)
    buildFolderSourcePaths=getSourcePaths(buildInfo,true,'BuildDir');
    codegenDir=buildFolderSourcePaths{1};
    files=dir(codegenDir);


    for i=1:numel(files)
        if~files(i).isdir
            copyfile(fullfile(files(i).folder,files(i).name),sourceFolder);
        end
    end
end

function backend(outName,className,api,params,features,win32,universal,format,pluginDstFullFile)

    assert(ispc||ismac||strcmp(format,'juceproject'));

    pcodeWrappers=features.PcodeWrappers;
    deleteWrappers=features.DeleteWrappers;
    coderless=strcmp(features.CoderMode,'coderless');
    dma=features.DynamicMemoryAllocation;

    progressNewline=onCleanup(@()fprintf('\n'));

    if coderless

        workFolder=tempname;
        workFolderDeleter=onCleanup(@()rmdir(workFolder,'s'));
    else
        workFolder=fullfile(pwd,'codegen','lib',outName);
    end
    makeWorkFolder(workFolder);




    juceLocation=fullfile(toolboxdir('audio'),'plugins');
    juceZipFileSrc=fullfile(juceLocation,'accio.mods');
    templatesMatFileSrc=fullfile(juceLocation,'temps');
    jucerFileDst=fullfile(workFolder,[outName,'.jucer']);
    sourceFolder=fullfile(workFolder,'Source');
    pluginProcessorFileDst=fullfile(sourceFolder,[outName,'PluginProcessor.cpp']);
    pluginEditorFileDst=fullfile(sourceFolder,[outName,'PluginEditor.h']);
    pluginRezFileDst=fullfile(sourceFolder,[outName,'PluginEditorResources.h']);
    codeInfoMatFile=fullfile(sourceFolder,'codeInfo.mat');
    buildInfoMatFile=fullfile(sourceFolder,'buildInfo.mat');
    tmwtypeshFileSrc=fullfile(matlabroot,'extern','include','tmwtypes.h');
    tmwtypeshFileDst=fullfile(sourceFolder,'tmwtypes.h');

    pluginProcessorClass=[outName,'AudioProcessor'];
    pluginEditorClass=[outName,'AudioProcessorEditor'];

    nin=sum(api.InputChannels);
    nout=sum(api.OutputChannels);

    printProgressDot;
    printVerboseStatus('Analyzing MATLAB plugin\n');
    wrapperDeleter=generateMATLABWrapperFcns(className,api,params,...
    workFolder,pcodeWrappers,deleteWrappers);%#ok<NASGU>

    mexCfg=mex.getCompilerConfigurations('C++','selected');

    if strcmp(features.CoderMode,'touch')

        assert(ispc||ismac);
        pluginPath=juceBuildPaths(mexCfg,workFolder,outName,format,win32);
        touchPlugin(pluginPath);
    else

        makeWorkFolder(sourceFolder);


        if isa(features.CoderConfig.DeepLearningConfig,'coder.MklDNNConfig')
            weightFolderName=[outName,'_',format,'_NetworkWeights'];
            weightFolder=fullfile(sourceFolder,weightFolderName);
            makeWorkFolder(weightFolder);
        else
            weightFolderName='';
            weightFolder='';
        end

        printProgressDot;
        printVerboseStatus('Translating MATLAB code');
        t=tic;
        runCoder(outName,api,workFolder,features,pcodeWrappers,format,coderless,dma);
        printVerboseStatus('   (%g s)\n',toc(t));

        clear('wrapperDeleter');

        templates=load(templatesMatFileSrc,'-mat');

        printProgressDot;
        printVerboseStatus('Creating C++ plugin\n');

        if~isempty(api.GridLayout)
            editorType="custom";
        else
            editorType="generic";
        end

        generatePluginProcessor(...
        templates.cpp,pluginProcessorFileDst,pluginEditorFileDst,...
        outName,codeInfoMatFile,editorType,pluginProcessorClass,pluginEditorClass,params,nin,nout);

        if editorType=="custom"
            generatePluginEditor(...
            templates.h,pluginEditorFileDst,...
            templates.rez,pluginRezFileDst,...
            templates.images,pluginProcessorClass,pluginEditorClass,api,params);
        end

        cFiles=mineBuildInfo(buildInfoMatFile,workFolder,features.CoderConfig,weightFolder);
        cFiles=[pluginProcessorFileDst,cFiles];
        if exist(pluginRezFileDst,'file')
            cFiles=[pluginRezFileDst,cFiles];
        end
        if exist(pluginEditorFileDst,'file')
            cFiles=[pluginEditorFileDst,cFiles];
        end
        copyfile(tmwtypeshFileSrc,tmwtypeshFileDst,'f');
        cFiles=[cFiles,tmwtypeshFileDst];

        if isa(features.CoderConfig.DeepLearningConfig,'coder.MklDNNConfig')

            fullFilePath=fullfile(sourceFolder,'MWGetWeightFileLocation.cpp');
            writeOutputFile(fullFilePath,templates.findMkldnnWeights);
            cFiles=[cFiles,fullFilePath];

            if strcmp(computer('arch'),'maci64')


                libFolderName=['mkl-dnn','_lib'];
                libFolder=fullfile(sourceFolder,libFolderName);
                makeWorkFolder(libFolder);



                dylibsDnnl={'libdnnl.1.4.dylib','libdnnl.1.dylib','libdnnl.dylib'};
                for dnnLib=1:numel(dylibsDnnl)
                    mkldnnLibUser=fullfile(getenv("INTEL_MKLDNN"),'lib',dylibsDnnl{dnnLib});
                    mkldnnLibDst=fullfile(libFolder,dylibsDnnl{dnnLib});
                    copyCmd=sprintf('cp -Rf "%s" "%s"',mkldnnLibUser,mkldnnLibDst);
                    [ok,~]=system(copyCmd);
                    if ok~=0
                        error(message('audio:plugin:IntermediateFileMoveFailed'));
                    end
                    cFiles=[cFiles,mkldnnLibDst];
                end

                ompLibUser=fullfile(getenv("INTEL_MKLDNN"),'lib','libomp.dylib');
                ompLibDst=fullfile(libFolder,'libomp.dylib');
                [ok,~]=copyfile(ompLibUser,ompLibDst);
                if~ok
                    error(message('audio:plugin:IntermediateFileMoveFailed'));
                end
                cFiles=[cFiles,ompLibDst];
            end
        end

        generateJucerFile(templates.jucer,jucerFileDst,cFiles,api,outName,format,win32,...
        universal,features.CoderConfig,weightFolderName,weightFolder);


        if strcmp(format,'juceproject')
            printProgressDot;
            printVerboseStatus('Exporting project\n');
            exportJuceProject(workFolder,outName,cFiles,jucerFileDst,pluginDstFullFile,weightFolderName);
            return
        end
        assert(ispc||ismac);
        [pluginPath,projectFile,target,sharedProjectFile]=...
        juceBuildPaths(mexCfg,workFolder,outName,format,win32);

        printProgressDot;
        printVerboseStatus('Preparing to compile');
        t=tic;
        unzip(juceZipFileSrc,workFolder);
        printVerboseStatus('   (%g s)\n',toc(t));

        printProgressDot;
        generateProjectFiles(juceLocation,jucerFileDst);

        if ismac

            buildSystemSettingsFile=fullfile(workFolder,"Builds","MacOSX",[outName,'.xcodeproj'],...
            "project.xcworkspace","xcshareddata","WorkspaceSettings.xcsettings");
            if exist(buildSystemSettingsFile,'file')
                oldtext=fileread(buildSystemSettingsFile);
                newtext=replace(oldtext,'Original','Latest');
                if~strcmp(newtext,oldtext)
                    fid=fopen(buildSystemSettingsFile,'wb');
                    fwrite(fid,newtext);
                    fclose(fid);
                end
            end

            if strcmp('auv3',format)




                projectSettingsFile=fullfile(workFolder,"Builds","MacOSX",[outName,'.xcodeproj'],"project.pbxproj");
                if exist(projectSettingsFile,'file')
                    oldtext=fileread(projectSettingsFile);

                    if contains(oldtext,'"$(NATIVE_ARCH_ACTUAL)"')
                        newtext=replace(oldtext,'"$(ARCHS_STANDARD_64_BIT)"','"$(NATIVE_ARCH_ACTUAL)"');
                        if~strcmp(newtext,oldtext)
                            fid=fopen(projectSettingsFile,'wb');
                            fwrite(fid,newtext);
                            fclose(fid);
                        end
                    end
                end
            end


            xcdbld=fullfile(mexCfg.Location,'usr','bin','xcodebuild');
            printProgressDot;
            cmd=sprintf('%s -project ''%s'' -target ''%s'' -configuration Release build',xcdbld,projectFile,[outName,' - Shared Code']);
            timedSystemCommand(cmd,'Compiling shared code','audio:plugins:xcodefailed','Xcode build failed:\n%s');
            if strcmp(target,'auv3')

                printProgressDot;
                targetAUv3=[outName,' - AUv3 AppExtension'];
                cmd=sprintf('%s -project ''%s'' -target ''%s'' -configuration Release build',xcdbld,projectFile,targetAUv3);
                timedSystemCommand(cmd,'Compiling plugin','audio:plugins:xcodefailed','Xcode build failed:\n%s');
            end
            printProgressDot;
            cmd=sprintf('%s -project ''%s'' -target ''%s'' -configuration Release build',xcdbld,projectFile,target);
            timedSystemCommand(cmd,'Compiling plugin','audio:plugins:xcodefailed','Xcode build failed:\n%s');
        else
            devenv=fullfile(mexCfg.Location,'Common7','IDE','devenv.com');
            if mexCfg.Name=="Microsoft Visual C++ 2022"&&...
                exist(sharedProjectFile,'file')&&exist(projectFile,'file')
                updateProjectVS2019ToVS2022(sharedProjectFile);
                updateProjectVS2019ToVS2022(projectFile);
            end
            printProgressDot;
            cmd=sprintf('"%s" "%s" /build Release',devenv,projectFile);
            timedSystemCommand(cmd,'Compiling plugin','audio:plugins:msvcfailed','Visual Studio build failed:\n%s');
        end
    end
    assert(ispc||ismac);


    printProgressDot;
    printVerboseStatus('Copy plugin to output');

    if isa(features.CoderConfig.DeepLearningConfig,'coder.MklDNNConfig')&&ismac


        copyCmd=sprintf('cp -Rf "%s" "%s"',pluginPath,pluginDstFullFile);
        [ok,msg]=system(copyCmd);
        if ok~=0
            error(message('audio:plugin:OutputMoveFailed',pluginDstFullFile,strtrim(msg)));
        end
    else
        [ok,msg]=copyfile(pluginPath,pluginDstFullFile);
        if~ok
            error(message('audio:plugin:OutputMoveFailed',pluginDstFullFile,strtrim(msg)));
        end
    end


    if isa(features.CoderConfig.DeepLearningConfig,'coder.MklDNNConfig')&&ispc
        pluginDLDataDst=fullfile(features.PluginOutDir,weightFolderName);
        if~exist("pluginDataDst","dir")
            makeWorkFolder(pluginDLDataDst);
        end
        [ok,msg]=copyfile(weightFolder,pluginDLDataDst);
        if~ok
            error(message('audio:plugin:OutputMoveFailed',features.PluginOutDir,strtrim(msg)));
        end
    end
end

function updateProjectVS2019ToVS2022(projectFile)
    pf=fileread(projectFile);
    pf=replace(pf,'<?xml version="1.0" encoding="UTF-8"?>',...
    '<?xml version="1.0" encoding="utf-8"?>');
    pf=replace(pf,'<PlatformToolset>v142</PlatformToolset>',...
    '<PlatformToolset>v143</PlatformToolset>');
    fid=fopen(projectFile,'wb');
    fwrite(fid,pf);
    fclose(fid);
end

function printVerboseStatus(varargin)
    persistent verbose
    if islogical(varargin{1})
        verbose=varargin{1};
        return
    end
    if verbose
        fprintf(varargin{:});
    end
end

function printProgressDot
    fprintf('.');
end

function timedSystemCommand(cmd,debugStatus,varargin)
    printVerboseStatus(debugStatus);
    t=tic;
    [status,output]=system(cmd);
    printVerboseStatus('   (%g s)\n',toc(t));
    if status~=0
        error(varargin{:},output);
    end
end

function[pluginPath,projectFile,target,winShared]=juceBuildPaths(mexCfg,workFolder,outName,format,win32)
    buildsDir=fullfile(workFolder,'Builds');
    if ismac
        projectFile=fullfile(buildsDir,'MacOSX',[outName,'.xcodeproj']);
        pluginPath=fullfile(buildsDir,'MacOSX','build','Release',[outName,pluginExt(format)]);
        switch format
        case 'vst'
            target=[outName,' - VST'];
        case 'au'
            target=[outName,' - AU'];
        case 'auv3'
            target=[outName,' - Standalone Plugin'];
        case 'exe'
            target=[outName,' - Standalone Plugin'];
        case 'vst3'
            target=[outName,' - VST3'];
        otherwise
            assert(false,['unexpected plugin format: ',format]);
        end
        winShared='';
    else
        switch mexCfg.Name
        case 'Microsoft Visual C++ 2022'

            juceCompiler='VisualStudio2019';
        case 'Microsoft Visual C++ 2019'
            juceCompiler='VisualStudio2019';
        case 'Microsoft Visual C++ 2017'
            juceCompiler='VisualStudio2017';
        otherwise
            supportedToolchains=sprintf([...
'\nMicrosoft Visual C++ 2022'...
            ,'\nMicrosoft Visual C++ 2019'...
            ,'\nMicrosoft Visual C++ 2017'...
            ]);
            error(message('audio:plugin:UnsupportedToolchain',...
            mexCfg.Name,'mex -setup C++',supportedToolchains));
        end
        if win32
            platform='Win32';
        else
            platform='x64';
        end
        winShared=fullfile(buildsDir,juceCompiler,[outName,'_SharedCode.vcxproj']);
        switch format
        case 'vst'
            projectFile=fullfile(buildsDir,juceCompiler,[outName,'_VST.vcxproj']);
            pluginPath=fullfile(buildsDir,juceCompiler,platform,'Release','VST',[outName,pluginExt(format)]);
        case 'exe'
            projectFile=fullfile(buildsDir,juceCompiler,[outName,'_StandalonePlugin.vcxproj']);
            pluginPath=fullfile(buildsDir,juceCompiler,platform,'Release','Standalone Plugin',[outName,pluginExt(format)]);
        case 'vst3'
            projectFile=fullfile(buildsDir,juceCompiler,[outName,'_VST3.vcxproj']);
            pluginPath=fullfile(buildsDir,juceCompiler,platform,'Release','VST3',[outName,pluginExt(format)]);
        otherwise
            assert(false,['unexpected plugin format: ',format]);
        end
        target='';
    end
end

function wrapperDeleter=generateMATLABWrapperFcns(className,api,params,workFolder,pcodeWrappers,deleteWrappers)
    paths={};
    paths{end+1}=emitGetPluginInstanceWrapper(workFolder);
    paths{end+1}=emitDerivedAudioPlugin(workFolder,className);
    paths{end+1}=emitCreatePluginInstanceWrapper(workFolder,className,api.InputChannels);
    paths{end+1}=emitParamChangeWrapper(workFolder,params);
    paths{end+1}=emitResetWrapper(workFolder,className);
    paths{end+1}=emitGetLatencyWrapper(workFolder);
    paths{end+1}=emitProcessWrapper(workFolder,className,api);
    if pcodeWrappers
        pcode(paths{:},'-inplace');
        cellfun(@delete,paths);
        paths=regexprep(paths,'\.m$','.p');
    end
    if deleteWrappers
        wrapperDeleter=onCleanup(@()cellfun(@conditionalDelete,paths));
    else
        wrapperDeleter=[];
    end
    function conditionalDelete(path)


        if exist(path,'file')
            delete(path);
        end
    end
end

function path=emitResetWrapper(dirName,className)
    s={};
    s{end+1}=sprintf([
'function resetCImpl(rate) %%#codegen\n'...
    ,'    coder.allowpcode(''plain'');\n'...
    ,'    plugin = getPluginInstance;\n'...
...
    ,'        setSampleRateForReset(plugin, rate);\n'...
...
    ]);
    if hasMethodNamed(className,'reset')
        s{end+1}=sprintf('    reset(plugin);\n');
    elseif hasMethodNamed(className,'init')
        s{end+1}=sprintf('    init(plugin);\n');
    end
    s{end+1}=sprintf('end\n');

    path=fullfile(dirName,'resetCImpl.m');
    writeOutputFileIndented(path,s);
end

function path=emitGetLatencyWrapper(dirName)
    s={};
    s{end+1}=sprintf([
'function n = getLatencyInSamplesCImpl %%#codegen\n'...
    ,'    coder.allowpcode(''plain'');\n'...
    ,'    plugin = getPluginInstance;\n'...
    ,'    n = getLatencyInSamplesInt32(plugin);\n'...
    ,'end\n'
    ]);

    path=fullfile(dirName,'getLatencyInSamplesCImpl.m');
    writeOutputFileIndented(path,s);
end

function path=emitCreatePluginInstanceWrapper(dirName,className,inputChannels)
    s={};
    s{end+1}=sprintf([
'function createPluginInstance(thisPtr, varargin)  %%#codegen\n'...
    ,'    coder.allowpcode(''plain'');\n'...
    ,'    audioPlugin.wormholeToConstructor(thisPtr);\n'...
    ,'    plugin = getPluginInstance(varargin{:});\n'...
    ]);

    s{end+1}=emitSetupIfSystemObject(className,inputChannels);

    s{end+1}=sprintf('end\n');

    path=fullfile(dirName,'createPluginInstance.m');
    writeOutputFileIndented(path,s);

    function s=emitSetupIfSystemObject(className,inputChannels)
        s={};
        if matlab.system.isSystemObjectName(className)
            s{end+1}=sprintf('setup(plugin');
            for w=inputChannels(:)'
                if w>0
                    s{end+1}=sprintf(', zeros(2, %d)',w);
                end
            end
            s{end+1}=sprintf(');\n');
        end
        s=[s{:}];
    end
end

function runCoder(outName,api,workFolder,features,pcodeWrappers,format,coderless,dma)
    ctorArgs={};
    verbose=features.Verbose;
    coderconfig=features.CoderConfig;


    crlVal=coderconfig.CodeReplacementLibrary;

    if~isempty(crlVal)
        cfg=coder.config('lib','ECODER',true);
        cfg.CodeReplacementLibrary=crlVal;
    else
        cfg=coder.config('lib','ECODER',false);
    end


    if~isempty(coderconfig.DeepLearningConfig)
        cfg.DeepLearningConfig=coderconfig.DeepLearningConfig;
    end

    cfg.EnableImplicitExpansion=false;
    cfg.MultiInstanceCode=true;
    cfg.FilePartitionMethod='SingleFile';
    cfg.GenerateExampleMain='DoNotGenerate';
    if isequal(dma,'off')
        cfg.DynamicMemoryAllocation='Off';
    elseif isnumeric(dma)
        cfg.DynamicMemoryAllocationThreshold=dma;
    end
    cfg.TargetLang='C++';
    cfg.PostCodeGenCommand=sprintf('generateAudioPlugin(''-PostCodeGenCommand'', modelName, projectName, buildInfo, ''%s'')',...
    fullfile(workFolder,'Source'));


    varSzColType=coder.typeof(double(0),[maxSamplesPerFrame,1],[1,0]);
    nin=sum(api.InputChannels);
    processInputsTypes=repmat({varSzColType},1,nin);
    constArgs=cellfun(@(x)coder.Constant(x),ctorArgs,'UniformOutput',false);
    if pcodeWrappers
        ext='.p';
    else
        ext='.m';
    end

    oldPath=addpath(workFolder);
    restorePath=onCleanup(@()path(oldPath));

    if isa(coderconfig.DeepLearningConfig,'coder.MklDNNConfig')
        openMPSetting='enable:openmp';
    else
        openMPSetting='disable:openmp';
    end

    codeGenArgs={...
    '-O',openMPSetting,...
    '-o',outName,...
    '-c',...
    fullfile(workFolder,['onParamChangeCImpl',ext]),'-args',{int32(0),0},...
    fullfile(workFolder,['resetCImpl',ext]),'-args',{0},...
    fullfile(workFolder,['processEntryPoint',ext]),'-args',[{double(0)},processInputsTypes],...
    fullfile(workFolder,['createPluginInstance',ext]),'-args',[{coder.typeof(uint64(0))},constArgs],...
    fullfile(workFolder,['getLatencyInSamplesCImpl',ext]),...
    '-config',cfg};

    if verbose
        codeGenArgs{end+1}='-launchreport';
    end

    f=coder.internal.FeatureControl;
    f.EnumAddPrefix=1;
    codeGenArgs{end+1}='-feature';
    codeGenArgs{end+1}=f;

    if coderless&&~strcmp(format,'juceproject')
        codeGenArgs{end+1}='-audioplugindumpdir';
        codeGenArgs{end+1}=workFolder;

        codeGenArgs{end+1}='tp835d9653_bad8_4437_bfd0_dc3f1d27bb78';
        coder.internal.generateAudioPlugin(codeGenArgs{:});
    else
        save(fullfile(workFolder,'codeGenArgs.mat'),'codeGenArgs');
        codegen(codeGenArgs{:});
    end

end

function cFiles=mineBuildInfo(matFile,workFolder,coderConfig,weightFolder)
    x=load(matFile,'buildInfo');

    files=x.buildInfo.getFullFileList;

    sourceFolder=fullfile(workFolder,'Source');


    bd=x.buildInfo.getSourcePaths(true,'BuildDir');
    codegenDir=bd;
    files=strrep(files,codegenDir,sourceFolder);


    for i=1:numel(files)
        if isempty(fileparts(files{i}))
            files{i}=fullfile(sourceFolder,files{i});
        end
    end


    deadfilepattern='_coder_*_target';
    hfile=dir(fullfile(sourceFolder,[deadfilepattern,'.h']));
    if~isempty(hfile)
        delete(fullfile(hfile.folder,hfile.name));
        files(contains(files,hfile.name))=[];
    end
    cppfile=dir(fullfile(sourceFolder,[deadfilepattern,'.cpp']));
    if~isempty(cppfile)
        delete(fullfile(cppfile.folder,cppfile.name));
        files(contains(files,cppfile.name))=[];
    end


    noSuchFile=cellfun(@(x)2~=exist(x,'file'),files);
    files(noSuchFile)=[];

    for i=1:numel(files)
        [p,n,e]=fileparts(files{i});
        if~strcmp(p,sourceFolder)
            newfile=fullfile(sourceFolder,[n,e]);
            [ok,~]=copyfile(files{i},newfile,'f');
            if~ok
                error(message('audio:plugin:IntermediateFileMoveFailed'));
            end
            files{i}=newfile;
        end
        if strcmp(e,'.bin')&&exist(weightFolder,'dir')
            networkWeightFile=fullfile(weightFolder,[n,e]);
            [ok,~]=copyfile(files{i},networkWeightFile,'f');
            if~ok
                error(message('audio:plugin:IntermediateFileMoveFailed'));
            end
            delete(files{i});
            files{i}=networkWeightFile;
        end
    end

    if isa(coderConfig.DeepLearningConfig,'coder.MklDNNConfig')
        fileExtensionList={'.c','.cpp','.h','.hpp','.bin','.lib'};
    else
        fileExtensionList={'.c','.cpp','.h'};
    end

    cFiles=files(cellfun(@(x)endsWith(x,fileExtensionList),files));
end

function generateJucerFile(jucerFileTemplate,jucerFileDst,cFiles,api,outName,format,win32,universal,coderConfig,weightFolderName,weightFolder)
    writeOutputFile(jucerFileDst,jucerFileTemplate);
    import matlab.io.xml.dom.*
    jucerFile=parseFile(Parser,jucerFileDst);

    nin=sum(api.InputChannels);
    nout=sum(api.OutputChannels);


    description=api.PluginName;
    copyright='';
    website='';
    email='';

    root=jucerFile.getDocumentElement;
    root.setAttribute('name',outName);
    root.setAttribute('pluginManufacturer',api.VendorName);
    root.setAttribute('pluginManufacturerCode',api.VendorCode);
    root.setAttribute('pluginCode',api.UniqueId);
    root.setAttribute('bundleIdentifier',api.BundleIdentifier);
    root.setAttribute('version',api.VendorVersion);
    root.setAttribute('pluginName',api.PluginName);

    root.setAttribute('pluginDesc',description);
    root.setAttribute('companyCopyright',copyright);

    root.setAttribute('companyName',api.VendorName);
    root.setAttribute('companyWebsite',website);
    root.setAttribute('companyEmail',email);

    root.setAttribute('pluginChannelConfigs',sprintf('{%d, %d}',nin,nout));

    root.setAttribute('pluginIsSynth','0');
    root.setAttribute('pluginWantsMidiIn','0');
    root.setAttribute('pluginProducesMidiOut','0');
    root.setAttribute('pluginIsMidiEffectPlugin','0');

    root.setAttribute('includeBinaryInAppConfig','1');
    root.setAttribute('cppLanguageStandard','11');
    switch format
    case 'vst'
        root.setAttribute('buildVST','1');
        root.setAttribute('buildVST3','0');
        root.setAttribute('buildAU','0');
        root.setAttribute('buildAUv3','0');
        root.setAttribute('buildStandalone','0');
    case 'vst3'
        root.setAttribute('buildVST','0');
        root.setAttribute('buildVST3','1');
        root.setAttribute('buildAU','0');
        root.setAttribute('buildAUv3','0');
        root.setAttribute('buildStandalone','0');
    case 'au'
        root.setAttribute('buildVST','0');
        root.setAttribute('buildVST3','0');
        root.setAttribute('buildAU','1');
        root.setAttribute('buildAUv3','0');
        root.setAttribute('buildStandalone','0');
    case 'auv3'
        root.setAttribute('buildVST','0');
        root.setAttribute('buildVST3','0');
        root.setAttribute('buildAU','0');
        root.setAttribute('buildAUv3','1');
        root.setAttribute('buildStandalone','1');
    case 'exe'
        root.setAttribute('buildVST','0');
        root.setAttribute('buildVST3','0');
        root.setAttribute('buildAU','0');
        root.setAttribute('buildAUv3','0');
        root.setAttribute('buildStandalone','1');
    otherwise
        root.setAttribute('buildVST','0');
        root.setAttribute('buildVST3','0');
        root.setAttribute('buildAU','0');
        root.setAttribute('buildAUv3','0');
        root.setAttribute('buildStandalone','0');
    end
    root.setAttribute('buildRTAS','0');
    root.setAttribute('buildAAX','0');
    root.setAttribute('enableIAA','0');
    root.setAttribute('pluginEditorRequiresKeys','0');
    root.setAttribute('pluginAUExportPrefix',[outName,'AU']);
    root.setAttribute('pluginRTASCategory','');
    root.setAttribute('aaxIdentifier',api.BundleIdentifier);
    root.setAttribute('pluginAAXCategory','AAX_ePlugInCategory_Dynamics');

    x=jucerFile.getElementsByTagName('MAINGROUP');
    assert(x.getLength==1)
    maingroup=x.item(0);
    maingroup.setAttribute('name',outName);

    x=jucerFile.getElementsByTagName('GROUP');
    assert(x.getLength==1)
    group=x.item(0);
    assert(strcmp(group.getAttribute('name'),'Source'))
    sprev=seedRngForRepeatableAlphaNumericUIDs(outName);
    for i=1:numel(cFiles)
        [~,f,e]=fileparts(cFiles{i});
        fileName=[f,e];
        fileNode=jucerFile.createElement('FILE');
        fileNode.setAttribute('id',createAlphaNumericUID);
        fileNode.setAttribute('name',fileName);
        if endsWith(fileName,{'.c','.cpp'})
            fileNode.setAttribute('compile','1');
        else
            fileNode.setAttribute('compile','0');
        end

        if endsWith(fileName,{'.bin'})

            fileNode.setAttribute('resource','1');
            fileNode.setAttribute('file',['Source/',weightFolderName,'/',fileName]);
        elseif endsWith(fileName,{'.dylib'})

            fileNode.setAttribute('resource','1');
            fileNode.setAttribute('file',['Source/','mkl-dnn_lib/',fileName]);
        else
            fileNode.setAttribute('resource','0');
            fileNode.setAttribute('file',['Source/',fileName]);
        end

        group.appendChild(fileNode);
    end
    rng(sprev);
    x=jucerFile.getElementsByTagName('CONFIGURATION');
    for i=0:x.getLength-1
        x.item(i).setAttribute('targetName',outName);
    end





    isAUv3=strcmp(format,'auv3');
    if universal||isAUv3
        x=jucerFile.getElementsByTagName('XCODE_MAC');
        if x.Length>0
            x=x.item(0).getElementsByTagName('CONFIGURATION');
            for i=0:x.getLength-1
                y=x.item(i);
                if universal
                    y.setAttribute('osxArchitecture','64BitUniversal');
                    y.setAttribute('customXcodeFlags','VALID_ARCHS = "x86_64 arm64"');
                end
                if isAUv3
                    y.setAttribute('codeSigningIdentity','-');
                end
            end
        end
    end

    if isa(coderConfig.DeepLearningConfig,'coder.MklDNNConfig')


        VisualStudioProjList={'VS2015','VS2017','VS2019','VS2022'};
        libHeaderPath=fullfile(getenv('INTEL_MKLDNN'),'include');
        importLibPath=fullfile(getenv('INTEL_MKLDNN'),'lib');
        importLibName='dnnl.lib';


        if isempty(dir(fullfile(weightFolder,'*.bin')))
            warning(message('audio:plugin:UsingMKLDNNConfigForNonDLPlugin'));
        end

        if ispc
            for i=1:length(VisualStudioProjList)
                x=jucerFile.getElementsByTagName(VisualStudioProjList{i});
                if x.Length>0
                    x.item(0).setAttribute('externalLibraries',importLibName);

                    mkldnnDefines=['MW_RUNTIME_DL_DATA_PATH=',...
                    weightFolderName,newline,...
                    'MW_USE_AUDIO_PLUGIN_RUNTIME_LOCATION_WIN'];
                    x.item(0).setAttribute('extraDefs',mkldnnDefines);

                    relPathToWeightsFolder=['$(SolutionDir)..\..\Source\',weightFolderName];
                    VSBinaryPath=['$(OutputPath)',weightFolderName];
                    xcopyCmd=sprintf('Xcopy "%s" "%s" /i /y',relPathToWeightsFolder,VSBinaryPath);
                    y=x.item(0).getElementsByTagName('CONFIGURATION');
                    for j=0:y.getLength-1
                        y.item(j).setAttribute('headerPath',libHeaderPath);
                        y.item(j).setAttribute('libraryPath',importLibPath);
                        y.item(j).setAttribute('postbuildCommand',xcopyCmd);
                    end
                end
            end
        elseif ismac
            x=jucerFile.getElementsByTagName('XCODE_MAC');
            if x.Length>0
                x.item(0).setAttribute('extraLinkerFlags','-ldnnl');

                mkldnnDefines=['MW_RUNTIME_DL_DATA_PATH=',...
                fullfile('Resources',weightFolderName),newline,...
                'MW_USE_AUDIO_PLUGIN_RUNTIME_LOCATION_MAC'];
                x.item(0).setAttribute('extraDefs',mkldnnDefines);

                validArch='x86_64';
                x.item(0).setAttribute('xcodeValidArchs',validArch);

                resourceFolders=[fullfile('Source',weightFolderName),...
                newline,fullfile('Source','mkl-dnn_lib')];
                x.item(0).setAttribute('customXcodeResourceFolders',resourceFolders);

                y=x.item(0).getElementsByTagName('CONFIGURATION');
                for i=0:y.getLength-1
                    y.item(i).setAttribute('headerPath',libHeaderPath);
                    y.item(i).setAttribute('libraryPath',importLibPath);

                    rpathVal=['LD_RUNPATH_SEARCH_PATHS=',...
                    '"$(LD_RUNPATH_SEARCH_PATHS) @loader_path/../Resources/mkl-dnn_lib"'];
                    y.item(i).setAttribute('customXcodeFlags',rpathVal);
                end
            end
        else
            x=jucerFile.getElementsByTagName('LINUX_MAKE');
            if x.Length>0
                x.item(0).setAttribute('extraLinkerFlags','-ldnnl');

                linuxPluginDataFolder=fullfile('.MWPluginData',weightFolderName);
                mkldnnDefines=['MW_RUNTIME_DL_DATA_PATH=',...
                linuxPluginDataFolder,newline,...
                'MW_USE_AUDIO_PLUGIN_RUNTIME_LOCATION_LINUX'];
                x.item(0).setAttribute('extraDefs',mkldnnDefines);






                pluginDataDstFolder=fullfile(getenv('HOME'),'.MWPluginData',weightFolderName);
                if~exist(pluginDataDstFolder,'dir')
                    makeWorkFolder(pluginDataDstFolder);
                end
                [ok,~]=copyfile(weightFolder,pluginDataDstFolder);
                if~ok
                    error(message('audio:plugin:IntermediateFileMoveFailed'));
                end
                y=x.item(0).getElementsByTagName('CONFIGURATION');
                for i=0:y.getLength-1
                    y.item(i).setAttribute('headerPath',libHeaderPath);
                    y.item(i).setAttribute('libraryPath',importLibPath);
                end
            end
        end
    end

    if strcmp(coderConfig.CodeReplacementLibrary,'DSP Intel AVX2-FMA (Linux)')
        x=jucerFile.getElementsByTagName('LINUX_MAKE');
        if x.Length>0
            x.item(0).setAttribute('extraCompilerFlags','-mavx2 -mfma');
        end
    end

    if strcmp(coderConfig.CodeReplacementLibrary,'DSP Intel AVX2-FMA (Mac)')
        x=jucerFile.getElementsByTagName('XCODE_MAC');
        if x.Length>0
            y=x.item(0).getElementsByTagName('CONFIGURATION');

            validArch='x86_64';
            x.item(0).setAttribute('xcodeValidArchs',validArch);

            for j=0:y.getLength-1
                xcodeFlags=[y.item(j).getAttribute('customXcodeFlags'),',',...
                'CLANG_X86_VECTOR_INSTRUCTIONS=avx2',',','OTHER_CFLAGS=-mfma'];
                y.item(j).setAttribute('customXcodeFlags',xcodeFlags);
            end
        end
    end

    if win32&&~strcmp(format,'-juceproject')

        ef=jucerFile.getElementsByTagName('EXPORTFORMATS');
        cn=getChildNodes(ef.item(0));
        for k=0:cn.getLength-1
            elem=item(cn,k);
            if~isprop(elem,'TagName')
                continue;
            end
            tag=elem.TagName;
            if~strncmpi(tag,'VS20',4)
                continue;
            end
            x=jucerFile.getElementsByTagName(tag);
            for i=0:x.getLength-1
                y=x.item(i).getElementsByTagName('CONFIGURATION');
                for j=0:y.getLength-1
                    y.item(j).setAttribute('winArchitecture','Win32');
                end
            end
        end
    end
    writeToFile(DOMWriter,jucerFile,jucerFileDst);
end


function id=createAlphaNumericUID
    chars='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    id(1)=chars(randi([1,52]));
    id(2:6)=chars(randi([1,62],[1,5]));
end




function sprev=seedRngForRepeatableAlphaNumericUIDs(outName)
    sprev=rng(rem(polyval(double(char(outName)),2),2^32));
end















function exportJuceProject(workFolder,outName,cFiles,jucerFileDst,pluginDstFullFile,weightFolderName)
    zipFolder=fullfile(workFolder,'zip',outName);
    zipSource=fullfile(workFolder,'zip',outName,'Source');

    jucerFileExport=fullfile(zipFolder,[outName,'.jucer']);
    makeWorkFolder(zipSource);

    if~isempty(weightFolderName)
        weightZipFolder=fullfile(zipSource,weightFolderName);
        makeWorkFolder(weightZipFolder);
    end

    if ismac&&~isempty(weightFolderName)
        mkldnnLibFolderName='mkl-dnn_lib';
        mkldnnZipFolder=fullfile(zipSource,mkldnnLibFolderName);
        makeWorkFolder(mkldnnZipFolder);
    end

    zipFiles=strrep(cFiles,workFolder,zipFolder);
    [ok,~]=cellfun(@(x,y)copyfile(x,y,'f'),cFiles,zipFiles,'UniformOutput',false);


    for i=1:numel(ok)
        if~ok{i}
            error(message('audio:plugin:IntermediateFileMoveFailed'));
        end
    end



    if ismac&&~isempty(weightFolderName)
        copyCmd=sprintf('cp -Rf "%s" "%s"',fullfile(workFolder,'Source','mkl-dnn_lib'),zipSource);
        [ok,~]=system(copyCmd);
        if ok~=0
            error(message('audio:plugin:IntermediateFileMoveFailed'));
        end
    end

    tokens="useGlobalPath=""0""";
    replacements="useGlobalPath=""1""";

    jucer=fileread(jucerFileDst);
    text=replace(jucer,tokens,replacements);
    writeOutputFile(jucerFileExport,text);

    zip(pluginDstFullFile,zipFolder);
    rmdir(fullfile(workFolder,'zip'),'s');
end

function generateProjectFiles(juceLocation,jucerFileDst)
    switch computer('arch')
    case 'win64'
        jucerExe=fullfile(juceLocation,'genprj.exe');
    case 'maci64'
        jucerExe=fullfile(juceLocation,'genprj.maci64');
    case 'maca64'
        jucerExe=fullfile(juceLocation,'genprj.maca64');
    otherwise
        assert(false,'unexpected architecture');
    end
    cmd=sprintf('"%s" --resave "%s"',jucerExe,jucerFileDst);
    timedSystemCommand(cmd,'Generating project files','audio:plugins:jucerfailed','project file generation failed:\n%s');
end

function generatePluginProcessor(...
    pluginProcessorTemplate,pluginProcessorFileDst,pluginEditorFileDst,...
    outName,codeInfoMatFile,...
    editor,processorClass,editorClass,params,nin,nout)

    [sdType,pdType,initFcn,termFcn,termHasArg]=mineCodeInfo(codeInfoMatFile);

    if termHasArg
        termFcn=[termFcn,'(&mStackData)'];
    else
        termFcn=[termFcn,'()'];
    end
    privateMembers=getPrivateMembers(params);
    juceInitParams=genInitParameter(outName,params);
    juceAddListeners=genAddListener(params);
    paramListeners=genParamListeners(params);
    juceParams=genCreateAndAddParameter(params);
    processCImpl=genCForProcess(nin,nout);

    switch editor
    case "generic"
        hasEditor="true";
        includeEditorClassH="";
        newEditorClass="new GenericAudioProcessorEditor(this)";
    case "custom"
        hasEditor="true";
        [~,n,x]=fileparts(pluginEditorFileDst);
        includeEditorClassH=sprintf("\n#include ""%s""\n",[n,x]);
        newEditorClass=sprintf("new %s(*this, parameters)",editorClass);




    otherwise
        assert(false);
    end

    tokens=[
    "|<OUTNAME>|",string(outName)
    "|<STACKDATA>|",string(sdType)
    "|<PERSISTENTDATA>|",string(pdType)
    "|<INITFCN>|",string(initFcn)
    "|<TERMFCN>|",string(termFcn)
    "|<PROCESSORCLASS>|",string(processorClass)
    "|<PARAMCHANGED>|",string(paramListeners)
    "|<PRIVATEMEMBERS>|",string(privateMembers)
    "|<INITPARAMETERS>|",string(juceInitParams)
    "|<ADDPARAMLISTENERS>|",string(juceAddListeners)
    "|<CREATEANDADDPARAMETER>|",string(juceParams)
    "|<PROCESSCIMPL>|",string(processCImpl)
    "|<HASEDITOR>|",hasEditor
    "|<INCLUDEEDITORCLASSH>|",includeEditorClassH
    "|<NEWEDITORCLASS>|",newEditorClass
    ];
    text=replace(pluginProcessorTemplate,tokens(:,1),tokens(:,2));
    writeOutputFile(pluginProcessorFileDst,text);
end

function paramListeners=genParamListeners(params)
    format=[
'        if (parameterID == "%s") {\n'...
    ,'            return %d;\n'...
    ,'        }\n'];
    s={''};
    for i=1:numel(params)
        s{end+1}=sprintf(format,params(i).Property,i-1);
    end
    paramListeners=[s{:}];
end


function s=pf(x)
    s=num2str(x,'%g');
    if~contains(s,[".","e","E"])

        s=[s,'.f'];
    else
        s=[s,'f'];
    end
end

function juceInitParams=genInitParameter(outName,params)


    s={''};
    np=numel(params);
    for ii=1:np
        p=params(ii);
        if any(strcmpi(p.Law,{'enum','enumclass','logical'}))
            enu=cellfun(@(x)sprintf('"%s"',x),cellstr(p.Enums),'UniformOutput',false);
            s{end+1}=sprintf('m_choices%d({ %s }),\n          ',ii,strjoin(enu,', '));
        end
    end


    s{end+1}=sprintf('parameters(*this, nullptr, "%s", {\n',outName);
    lineterm=',';
    for ii=1:np
        if ii==np
            lineterm=' })';
        end
        p=params(ii);

        switch p.Law
        case 'lin'
            s{end+1}=sprintf(['                '...
            ,'std::make_unique<Parameter>("%s", "%s", "%s",\n                    '...
            ,'NormalisableRange<float>(%s,%s), %s, [](float val) {return String(val, 3);}, nullptr)%s\n',...
            ],p.Property,p.DisplayName,p.Label,pf(p.Min),pf(p.Max),pf(p.DefaultValue),lineterm);

        case{'pow','fader'}
            s{end+1}=sprintf(['                '...
            ,'std::make_unique<Parameter>("%s", "%s", "%s",\n                    '...
            ,'NormalisableRange<float>(%s,%s,0.f,%s), %s, [](float val) {return String(val, 3);}, nullptr)%s\n',...
            ],p.Property,p.DisplayName,p.Label,pf(p.Min),pf(p.Max),pf(1/p.Shape),pf(p.DefaultValue),lineterm);

        case 'int'
            s{end+1}=sprintf(['                '...
            ,'std::make_unique<Parameter>("%s", "%s", "%s",\n                    '...
            ,'NormalisableRange<float>(%s,%s,1.f), %s, [](float val) {return String(val, 3);}, nullptr)%s\n',...
            ],p.Property,p.DisplayName,p.Label,pf(p.Min),pf(p.Max),pf(p.DefaultValue),lineterm);

        case 'log'
            s{end+1}=sprintf(['                '...
            ,'std::make_unique<Parameter>("%s", "%s", "%s",\n                    '...
            ,'NormalisableRange<float>(%s,%s,'...
            ,'[](float min, float max, float norm) {return min*powf(max/min,norm);}, '...
            ,'[](float min, float max, float val) {return logf(val/min)/logf(max/min);}), %s, '...
            ,'[](float val) {return String(val, 3);}, nullptr)%s\n',...
            ],p.Property,p.DisplayName,p.Label,pf(p.Min),pf(p.Max),pf(p.DefaultValue),lineterm);

        case{'enum','enumclass','logical'}


            if isequal(p.Law,'enum')
                defaultIndex=find(strcmp(p.DefaultValue,cellstr(p.Enums)))-1;
            elseif isequal(p.Law,'enumclass')
                defaultIndex=find(p.DefaultValue==enumeration(p.DefaultValue))-1;
            else
                assert(isequal(p.Law,'logical'),'unexpected law');
                defaultIndex=p.DefaultValue;
            end

            strConstName=sprintf('m_choices%d',ii);
            s{end+1}=sprintf(['                '...
            ,'std::make_unique<Parameter>("%s", "%s", "%s",\n                    '...
            ,'NormalisableRange<float>(0.f, %s.size()-1.f, 1.f), %d.f,\n                    '...
            ,'[=](float value) { return %s[(int) (value + 0.5)]; },\n                    '...
            ,'[=](const String& text) { return (float) %s.indexOf(text); }, false, true, true)%s\n',...
            ],p.Property,p.DisplayName,p.Label,strConstName,defaultIndex,strConstName,strConstName,lineterm);

        otherwise
            assert(false,'unexpected law ''%s''',p.Law);
        end
    end


    if np==0
        s{end+1}='          })';
    end

    juceInitParams=[s{:}];

end

function juceAddListeners=genAddListener(params)
    if numel(params)>0
        format='        parameters.addParameterListener("%s", &paramListener);\n';
        juceAddListeners=sprintf(format,params(:).Property);
    else
        juceAddListeners='';
    end
end

function privateMembers=getPrivateMembers(params)
    s={''};
    for ii=1:numel(params)
        p=params(ii);
        if any(strcmpi(p.Law,{'enum','enumclass','logical'}))
            s{end+1}=sprintf('    const StringArray m_choices%d;\n',ii);
        end
    end
    privateMembers=[s{:}];
end

function juceParams=genCreateAndAddParameter(params)
    s={''};
    for i=1:numel(params)
        p=params(i);

        format='\n        //\n        // Parameter property %s\n        //\n';
        s{end+1}=sprintf(format,p.Property);

        switch p.Law
        case 'lin'
            s{end+1}=sprintf([...
'        parameters.createAndAddParameter ("%s", "%s", "%s",\n'...
            ,'            NormalisableRange<float>(%s, %s), %s,\n'...
            ,'            [](float val) {return String(val, 3);},\n'...
            ,'            nullptr);\n',...
            ],p.Property,p.DisplayName,p.Label,pf(p.Min),pf(p.Max),pf(p.DefaultValue));

        case{'pow','fader'}
            s{end+1}=sprintf([...
'        parameters.createAndAddParameter ("%s", "%s", "%s",\n'...
            ,'            NormalisableRange<float>(%s, %s, 0.f, %s), %s,\n'...
            ,'            [](float val) {return String(val, 3);},\n'...
            ,'            nullptr);\n',...
            ],p.Property,p.DisplayName,p.Label,pf(p.Min),pf(p.Max),pf(1/p.Shape),pf(p.DefaultValue));

        case 'int'
            s{end+1}=sprintf([...
'        parameters.createAndAddParameter ("%s", "%s", "%s",\n'...
            ,'            NormalisableRange<float>(%s, %s, 1.f), %s,\n'...
            ,'            [](float val) {return String(val, 3);},\n'...
            ,'            nullptr);\n'...
            ],p.Property,p.DisplayName,p.Label,pf(p.Min),pf(p.Max),pf(p.DefaultValue));

        case 'log'
            s{end+1}=sprintf([...
'        parameters.createAndAddParameter ("%s", "%s", "%s",\n'...
            ,'            NormalisableRange<float>(%s, %s, \n'...
            ,'                [](float min, float max, float norm) {return min * powf(max/min, norm);},\n'...
            ,'                [](float min, float max, float val) {return logf(val/min)/logf(max/min);} ),\n'...
            ,'            %s,\n'...
            ,'            [](float val) {return String(val, 3);},\n'...
            ,'            nullptr);\n',...
            ],p.Property,p.DisplayName,p.Label,pf(p.Min),pf(p.Max),pf(p.DefaultValue));

        case{'enum','enumclass','logical'}


            enums=cellstr(p.Enums);
            strConstName="choices"+i;
            x=cellfun(@(x)sprintf('"%s"',x),enums,'UniformOutput',false);
            s{end+1}=sprintf('        const StringArray %s({ %s });\n',strConstName,strjoin(x,', '));


            if isequal(p.Law,'enum')
                defaultIndex=find(strcmp(p.DefaultValue,enums))-1;
            elseif isequal(p.Law,'enumclass')
                defaultIndex=find(p.DefaultValue==enumeration(p.DefaultValue))-1;
            else
                assert(isequal(p.Law,'logical'),'unexpected law');
                defaultIndex=p.DefaultValue;
            end

            s{end+1}=sprintf([...
'        parameters.createAndAddParameter ("%s", "%s", "%s",\n'...
            ,'            NormalisableRange<float>(0.f, %s.size()-1.f, 1.f), %d.f,\n'...
            ,'            [=](float value) { return %s[(int) (value + 0.5)]; },\n'...
            ,'            [=](const String& text) { return (float) %s.indexOf(text); },\n'...
            ,'            false, true, true);\n',...
            ],p.Property,p.DisplayName,p.Label,strConstName,defaultIndex,strConstName,strConstName);
        otherwise
            assert(false,'unexpected law ''%s''',p.Law);
        end

        s{end+1}=sprintf('        parameters.addParameterListener("%s", &paramListener);\n',p.Property);
    end

    juceParams=[s{:}];

end

function code=genCForProcess(nin,nout)
    maxinout=max(nin,nout);

    codeCS={newline};



    if nin>0
        codeCS{end+1}=sprintf(...
        '        const double* pinputs[%d]{};\n',nin);
    end
    codeCS{end+1}=sprintf(...
    '        double* poutputs[%d]{};\n\n',nout);
    codeCS{end+1}=sprintf(...
    ['        if (nChannels < %d) {\n'...
    ,'            tempBuffer.setSize(%d-nChannels, nSamples);\n'],maxinout,maxinout);
    if nin>0
        codeCS{end+1}=sprintf(...
        ['        if (nChannels < %d) {\n'...
        ,'                tempBuffer.clear(0, nSamples);\n'...
        ,'                inputs = pinputs;\n'...
        ,'                for (i_ = 0; i_ < nChannels; i_++) {\n'...
        ,'                    inputs[i_] = pin[i_];\n                }\n'...
        ,'                const double** p = tempBuffer.getArrayOfReadPointers();\n'...
        ,'                for (i_ = nChannels; i_ < %d; i_++) {\n'...
        ,'                    inputs[i_] = p[i_-nChannels];\n'...
        ,'                }\n            }\n'],nin,nin);
    end
    codeCS{end+1}=sprintf(...
    ['            if (nChannels < %d) {\n'...
    ,'                outputs = poutputs;\n'...
    ,'                for (i_ = 0; i_ < nChannels; i_++) {\n'...
    ,'                    outputs[i_] = pout[i_];\n                }\n'...
    ,'                double** p = tempBuffer.getArrayOfWritePointers();\n'...
    ,'                for (i_ = nChannels; i_ < %d; i_++) {\n'...
    ,'                    outputs[i_] = p[i_-nChannels];\n'...
    ,'                }\n            }\n'...
    ,'        }\n\n'],nout,nout);


    if nout
        codeCS{end+1}=sprintf('        int osz%d_;\n',0:nout-1);
    else
        codeCS{end+1}=sprintf('        (void)outputs;\n');
    end


    codeCS{end+1}=sprintf(...
    ['        if (nSamples <= MAX_SAMPLES_PER_FRAME) {\n'...
    ,'            /* Fast path for common frame sizes. */\n']);


    if nin
        codeCS{end+1}=sprintf('            int isz%d_ = nSamples;\n',0:nin-1);
    else
        codeCS{end+1}=sprintf('            (void)inputs;\n');
    end

    codeCS{end+1}=sprintf('            processEntryPoint(SD, (double)nSamples');


    for i=0:(nin-1)
        codeCS{end+1}=sprintf(',\n                    inputs[%d], &isz%d_',i,i);
    end


    for i=0:(nout-1)
        codeCS{end+1}=sprintf(',\n                    outputs[%d], &osz%d_',i,i);
    end

    codeCS{end+1}=sprintf(');\n');


    codeCS{end+1}=sprintf('        } else {\n');
    codeCS{end+1}=sprintf('            /* Fallback for unusually large frames. */\n');


    for i=0:(nin-1)
        codeCS{end+1}=sprintf('            int isz%d_ = MAX_SAMPLES_PER_FRAME;\n',i);%#ok<*AGROW>
    end

    codeCS{end+1}=sprintf('            int n = MAX_SAMPLES_PER_FRAME;\n');

    codeCS{end+1}=sprintf([
'            for (i_ = 0; i_ < nSamples; i_ += MAX_SAMPLES_PER_FRAME) {\n'...
    ,'                if (i_ + MAX_SAMPLES_PER_FRAME > nSamples) {\n'...
    ,'                    n = nSamples - i_;\n']);


    for i=0:(nin-1)
        codeCS{end+1}=sprintf('                    isz%d_ = nSamples - i_;\n',i);
    end

    codeCS{end+1}=sprintf('                }\n');

    codeCS{end+1}=sprintf('                processEntryPoint(SD, (double)n');


    for i=0:(nin-1)
        codeCS{end+1}=sprintf(',\n                        inputs[%d]+i_, &isz%d_',i,i);
    end


    for i=0:(nout-1)
        codeCS{end+1}=sprintf(',\n                        outputs[%d]+i_, &osz%d_',i,i);
    end

    codeCS{end+1}=sprintf(');\n');

    codeCS{end+1}=sprintf([
'            }\n'...
    ,'        }\n'...
    ]);

    code=[codeCS{:}];

end

function generatePluginEditor(...
    pluginEditorTemplate,pluginEditorFileDst,...
    pluginRezTemplate,pluginRezFileDst,...
    images,processorClass,editorClass,api,params)

    everything=collectBinaryResources(params,api,images);

    [declBgImage,loadBgImage,drawBgImage]=...
    generateBackgroundImage(api.BackgroundImage,everything.background);

    [declBinRez,defnBinRez]=generateBinaryResources(everything.binRezMap,editorClass);

    declBinRez=declBgImage+declBinRez;

    [declLnFs,defnLnFs,setLnFFonts]=...
    generateLookAndFeels(everything.filmMap);

    widgets=generateWidgets(api,params,everything.paramBinRezMap);

    bg=api.BackgroundColor;
    backgroundColor=sprintf('%s, %s, %s',pf(bg(1)),pf(bg(2)),pf(bg(3)));

    [~,n,x]=fileparts(pluginRezFileDst);
    includeBinRezH=sprintf('#include "%s"\n',[n,x]);

    editorTokens=[
    "|<PROCESSORCLASS>|",string(processorClass)
    "|<EDITORCLASS>|",string(editorClass)
    "|<BACKGROUNDCOLOR>|",string(backgroundColor)
    "|<DECLBINARYRESOURCES>|",string(declBinRez)
    "|<DECLLOOKANDFEELS>|",string(declLnFs)
    "|<DEFNLOOKANDFEELS>|",string(defnLnFs)
    "|<SETLNFFONT>|",string(setLnFFonts)
    "|<LOADBACKGROUNDIMAGE>|",string(loadBgImage)
    "|<DRAWBACKGROUNDIMAGE>|",string(drawBgImage)
    "|<WIDGETS>|",string(widgets)
    "|<INCLUDEBINREZH>|",string(includeBinRezH)
    ];
    text=replace(pluginEditorTemplate,editorTokens(:,1),editorTokens(:,2));
    writeOutputFile(pluginEditorFileDst,text);

    rezTokens=[
    "|<EDITORCLASS>|",string(editorClass)
    "|<DEFNBINARYRESOURCES>|",string(defnBinRez)
    ];
    text=replace(pluginRezTemplate,rezTokens(:,1),rezTokens(:,2));
    writeOutputFile(pluginRezFileDst,text);

    function h=textHeight
        h=20;
    end

    function h=editBoxHeight
        h=textHeight;
    end

    function w=editBoxWidth
        w=75;
    end

    function brName=addBinaryResource(path,bytes,binRezMap)
        [~,brName]=fileparts(path);
        brName=matlab.lang.makeValidName(brName);
        brName=matlab.lang.makeUniqueStrings(brName,keys(binRezMap));
        assert(~isKey(binRezMap,brName));
        binRezMap(brName)=bytes;%#ok<NASGU>
    end

    function everything=collectBinaryResources(params,api,images)
        grid=api.GridLayout;

        binRezMap=containers.Map;
        filmMap=containers.Map;
        paramBinRezMap=containers.Map;
        extFilms=containers.Map;
        intFilms=containers.Map;


        everything.font=addBinaryResource("notoSans",[],binRezMap);

        bkg=api.BackgroundImage;
        if strlength(bkg)>0
            brName=addBinaryResource(bkg,readBytes(bkg),binRezMap);
        else
            brName="";
        end
        everything.background=brName;

        for i=1:numel(params)
            p=params(i);
            prop=p.Property;
            if strlength(p.Filmstrip)>0
                if isKey(extFilms,p.Filmstrip)
                    brName=extFilms(p.Filmstrip);
                else
                    brName=addBinaryResource(p.Filmstrip,readBytes(p.Filmstrip),binRezMap);
                    extFilms(p.Filmstrip)=brName;
                    filmMap(brName)=p.FilmstripFrameSize;
                end
                paramBinRezMap(prop)=brName;
            else
                switch p.Style
                case "rotaryknob"
                    pos=getPosition(grid,p.Layout);
                    space=pos(3:4);
                    switch p.EditBoxLocation
                    case{"above","below"}
                        space(2)=space(2)-editBoxHeight;
                    case{"left","right"}
                        space(1)=space(1)-editBoxWidth;
                    case "none"

                    otherwise
                        assert(false);
                    end
                    sizes=vertcat(images.knobs.framesize);
                    choice=find(all(sizes<=space,2),1,'last');
                    if isempty(choice)
                        choice=1;
                    end
                    fn=images.knobs(choice).name;
                    if isKey(intFilms,fn)
                        brName=intFilms(fn);
                    else
                        brName=addBinaryResource(fn,images.knobs(choice).bytes,binRezMap);
                        intFilms(fn)=brName;
                        filmMap(brName)=images.knobs(choice).framesize;
                    end
                    paramBinRezMap(prop)=brName;

                case "vrocker"
                    pos=getPosition(grid,p.Layout);
                    space=[pos(3),pos(4)-2*textHeight];
                    sizes=vertcat(images.rockers.framesize);
                    choice=find(all(sizes<=space,2),1,'last');
                    if isempty(choice)
                        choice=1;
                    end
                    fn=images.rockers(choice).name;
                    if isKey(intFilms,fn)
                        brName=intFilms(fn);
                    else
                        brName=addBinaryResource(fn,images.rockers(choice).bytes,binRezMap);
                        intFilms(fn)=brName;
                        filmMap(brName)=images.rockers(choice).framesize;
                    end
                    paramBinRezMap(prop)=brName;

                case "vtoggle"
                    pos=getPosition(grid,p.Layout);
                    space=[pos(3),pos(4)-2*textHeight];
                    sizes=vertcat(images.toggles.framesize);
                    choice=find(all(sizes<=space,2),1,'last');
                    if isempty(choice)
                        choice=1;
                    end
                    fn=images.toggles(choice).name;
                    if isKey(intFilms,fn)
                        brName=intFilms(fn);
                    else
                        brName=addBinaryResource(fn,images.toggles(choice).bytes,binRezMap);
                        intFilms(fn)=brName;
                        filmMap(brName)=images.toggles(choice).framesize;
                    end
                    paramBinRezMap(prop)=brName;
                otherwise
                end
            end
        end

        everything.binRezMap=binRezMap;
        everything.filmMap=filmMap;
        everything.paramBinRezMap=paramBinRezMap;

        function bytes=readBytes(path)
            [fid,msg]=fopen(path,'r');
            if fid<0
                error(message('audio:plugin:FopenFailed',path,msg));
            end
            bytes=fread(fid,"*uint8");
            fclose(fid);
        end

    end

    function[declBgImage,loadBgImage,drawBgImage]=...
        generateBackgroundImage(background,brName)
        if~isempty(background)
            info=imfinfo(background);
            loadBgImage=newline+"        backgroundImage = ImageCache::getFromMemory("+brName+"File, "+brName+"FileSize);"+newline;
            declBgImage="	Image backgroundImage;"+newline;

            format="        g.drawImage(backgroundImage, 0, 0, %d, %d, 0, 0, %d, %d);";
            drawBgImage=sprintf(format,info.Width,info.Height,info.Width,info.Height);
        else
            loadBgImage="";
            declBgImage="";
            drawBgImage="";
        end
    end

    function[decls,defns]=generateBinaryResources(binRezMap,editorClass)
        decls=strings(0);
        defns=strings(0);
        for k=keys(binRezMap)
            brName=k{1};
            bytes=binRezMap(brName);
            if~isempty(bytes)
                decls(end+1)="    static const unsigned char "+brName+"File[];";
                decls(end+1)="    static const int "+brName+"FileSize;";

                defns(end+1)="const int "+editorClass+"::"+brName+"FileSize = "+numel(bytes)+";";
                defns(end+1)="const unsigned char "+editorClass+"::"+brName+"File[] = {";
                defns(end+1)="    "+stringifyBytes(bytes);
                defns(end+1)="};";
            end
        end
        decls=strjoin(decls,'\n');
        defns=strjoin(defns,'\n');

        function t=stringifyBytes(bytes)
            n=30;
            t=strings(0);
            for j=1:n:numel(bytes)
                t(end+1)=strjoin(string(bytes(j:min(j+n-1,end))),",");
            end
            t=strjoin(t,',\n    ');
        end
    end

    function[decls,defns,fonts]=...
        generateLookAndFeels(filmMap)

        decls=strings(0);
        defns=strings(0);
        fonts=strings(0);

        for k=keys(filmMap)
            brName=k{1};
            frameSize=filmMap(brName);
            lnf=brName+"LnF";
            file=brName+"File";
            fileSize=brName+"FileSize";
            decls(end+1)="    FilmstripLookAndFeel "+lnf+";";
            defns(end+1)=sprintf(",\n        %s(%s, %s, %d, %d)",...
            lnf,file,fileSize,frameSize(1),frameSize(2));
            fonts(end+1)="        "+lnf+".setDefaultSansSerifTypeface(noto);"+newline;
        end
        decls=strjoin(decls,'\n');
        defns=strjoin(defns,"");
        fonts=strjoin(fonts,"");
    end

    function widgets=generateWidgets(api,params,paramBinRezMap)
        grid=api.GridLayout;

        s={newline};
        for i=1:numel(params)
            p=params(i);
            prop=p.Property;

            if isKey(paramBinRezMap,prop)
                lnf=", &"+paramBinRezMap(prop)+"LnF";
            else
                lnf=", &appdeslnf";
            end

            switch p.Style
            case{'hslider','vslider','rotaryknob'}

                b=getPosition(grid,p.Layout);
                dnb=getPosition(grid,p.DisplayNameLayout);
                doLog=strcmp(p.Law,'log');
                format='        widgets.add (new SliderKnob(*this, vts, "%s", "%s", "%s", "edit%s", %d, {%d, %d, %d, %d}, {%d, %d, %d, %d}%s));\n';
                s{end+1}=sprintf(format,prop,p.DisplayNameJustification,p.Style,p.EditBoxLocation,doLog,...
                dnb(1),dnb(2),dnb(3),dnb(4),b(1),b(2),b(3),b(4),lnf);

            case{'dropdown','vrocker','vtoggle'}



                if strcmp(p.Style,'dropdown')
                    widget="DropDown";
                else
                    widget="ToggleRocker";
                end

                enums=cellstr(p.Enums);
                x=cellfun(@(x)sprintf('"%s"',x),enums,'UniformOutput',false);
                enumStrings=strjoin(x,', ');


                b=getPosition(grid,p.Layout);
                dnb=getPosition(grid,p.DisplayNameLayout);
                format='        widgets.add (new %s(*this, vts, "%s", "%s", { %s }, {%d, %d, %d, %d}, {%d, %d, %d, %d}%s));\n';
                s{end+1}=sprintf(format,widget,prop,p.DisplayNameJustification,enumStrings,...
                dnb(1),dnb(2),dnb(3),dnb(4),b(1),b(2),b(3),b(4),lnf);

            case 'checkbox'

                b=getPosition(grid,p.Layout);
                dnb=getPosition(grid,p.DisplayNameLayout);
                format='        widgets.add (new CheckBox(*this, vts, "%s", "%s", {%d, %d, %d, %d}, {%d, %d, %d, %d}%s));\n';
                s{end+1}=sprintf(format,prop,p.DisplayNameJustification,...
                dnb(1),dnb(2),dnb(3),dnb(4),b(1),b(2),b(3),b(4),lnf);
            otherwise
                assert(false);
            end
        end

        gridSize=getSize(grid);
        format='\n        setSize(%d, %d);';
        s{end+1}=sprintf(format,gridSize(1),gridSize(2));

        widgets=[s{:}];

    end

end



