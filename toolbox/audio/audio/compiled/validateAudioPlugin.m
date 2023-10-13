function validateAudioPlugin(varargin)

%#ok<*AGROW>

    if nargin>0
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    if~any(strcmp(computer('arch'),{'win64','maci64','glnxa64'}))
        error(message('audio:plugin:UnsupportedPlatform',computer('arch')));
    end

    [className,verbose,domex,deletetestbench,coderless,coderconfig]=processCommandLine(varargin{:});

    oc=onCleanup(@()verbose_fprintf(verbose,'\n'));

    testbenchName=['testbench_',outNameFromClassName(className)];
    isWarningIssued=false;


    verbose_fprintf(verbose,'\nChecking plugin class ''%s''... ',className);
    [api,params]=checkPluginClass(className);
    hasSamplesPerFrame(className);
    hasParams(params);

    verbose_fprintf(verbose,'passed.\n');

    verbose_fprintf(verbose,'Generating testbench file ''%s''... ',[testbenchName,'.m']);
    generateTestbench(testbenchName,className,api,params);
    verbose_fprintf(verbose,'done.\n');

    verbose_fprintf(verbose,'Running testbench... ');
    feval(testbenchName);
    verbose_fprintf(verbose,'passed.\n');

    if domex
        verbose_fprintf(verbose,'Generating mex file ''%s''... ',[testbenchName,'_mex.',mexext]);

        if coderless
            workFolder=tempname;
            makeWorkFolder(workFolder);
            workFolderDeleter=onCleanup(@()rmdir(workFolder,'s'));
            if isempty(coderconfig.DeepLearningConfig)

                coder.internal.generateAudioPlugin(testbenchName,'tp835d9653_bad8_4437_bfd0_dc3f1d27bb78');
            else
                cfg=coder.config('mex');
                cfg.EnableImplicitExpansion=false;
                cfg.TargetLang='C++';
                cfg.PostCodeGenCommand=sprintf('generateAudioPlugin(''-PostCodeGenCommand'', modelName, projectName, buildInfo, ''%s'')',...
                fullfile(workFolder));
                cfg.DeepLearningConfig=coderconfig.DeepLearningConfig;

                coder.internal.generateAudioPlugin(testbenchName,'-config',cfg,...
                '-audioplugindumpdir',workFolder,...
                'tp835d9653_bad8_4437_bfd0_dc3f1d27bb78');

                if isa(coderconfig.DeepLearningConfig,'coder.MklDNNConfig')
                    networkWeightsFullFileLoc=fullfile(workFolder,'*.bin');
                    if~isempty(dir(networkWeightsFullFileLoc))
                        [ok,~]=copyfile(networkWeightsFullFileLoc,pwd);
                        if~ok
                            error(message('audio:plugin:DeepNeuralNetworkFileMoveFailed',pwd));
                        end
                        if deletetestbench
                            binFileList={dir(networkWeightsFullFileLoc).name};
                            if~isempty(binFileList)
                                networkFilesDeleter=onCleanup(@()cellfun(@delete,binFileList));
                            end
                        end
                    else
                        verbose_fprintf(verbose,'\n');
                        warning(message('audio:plugin:UsingMKLDNNConfigForNonDLPlugin'));
                        isWarningIssued=true;
                    end
                end
            end
        else



            if isempty(coderconfig.DeepLearningConfig)
                codegen(testbenchName);
            else
                cfg=coder.config('mex');
                cfg.EnableImplicitExpansion=false;
                cfg.TargetLang='C++';
                cfg.DeepLearningConfig=coderconfig.DeepLearningConfig;
                codegen(testbenchName,'-config',cfg);
            end
        end

        if isWarningIssued
            verbose_fprintf(verbose,'Mex file generated with warnings.\n');
        else
            verbose_fprintf(verbose,'done.\n');
        end

        verbose_fprintf(verbose,'Running mex testbench... ');
        feval([testbenchName,'_mex']);
        verbose_fprintf(verbose,'passed.\n');
    else
        verbose_fprintf(verbose,'Skipping mex.\n');
    end

    if deletetestbench
        verbose_fprintf(verbose,'Deleting testbench.\n');
        delete([testbenchName,'.m']);
        if domex
            delete([testbenchName,'_mex.',mexext]);
        end
    else
        verbose_fprintf(verbose,'Keeping testbench.\n');
        if domex
            clear([testbenchName,'_mex.',mexext]);
        end
    end


    if domex
        if isWarningIssued
            verbose_fprintf(verbose,'Plugin validation successful with warnings.\n');
        else
            verbose_fprintf(verbose,'Ready to generate audio plugin.\n');
        end
    end
end

function[className,verbose,domex,deletetestbench,coderless,coderconfig]=processCommandLine(varargin)






    coderless=true;
    verbose=true;
    domex=true;
    deletetestbench=true;

    i=1;
    while i<=nargin&&isOption(varargin{i})
        switch varargin{i}
        case '-quiet'
            verbose=false;
            i=i+1;
        case '-usecodegen'
            coderless=false;
            i=i+1;
        case '-nomex'
            domex=false;
            i=i+1;
        case '-keeptestbench'
            deletetestbench=false;
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
        otherwise
            error(message('audio:plugin:BadOption',varargin{i}));
        end
    end

    if i>nargin
        error(message('audio:plugin:TooFewArgs'));
    elseif i<nargin
        error(message('audio:plugin:TooManyArgs'));
    end

    className=varargin{i};

    if~isString(className)
        error(message('audio:plugin:NotAClass'));
    end
    className=audio.internal.classFromClassOrFileName(className);


    coderconfig=coderConfigDefaults;
    if exist('cmdLineCoderConfig','var')
        dlcfg=cmdLineCoderConfig.DeepLearningConfig;
        if~isempty(dlcfg)
            coderconfig.DeepLearningConfig=dlcfg;
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


            dlcfg=propCoderConfig.DeepLearningConfig;
            if~isempty(dlcfg)
                coderconfig.DeepLearningConfig=dlcfg;
            end
        end
    end
end

function cfg=coderConfigDefaults
    cfg.DeepLearningConfig='';
end

function verbose_fprintf(verbose,varargin)
    if verbose
        fprintf(varargin{:});
    end
end

function generateTestbench(testbenchName,className,api,params)
    inputChannels=api.InputChannels;
    outputChannels=api.OutputChannels;

    s={};
    s{end+1}=sprintf('function out = %s\n',testbenchName);
    s{end+1}=testbenchComment(testbenchName);
    s{end+1}=sprintf('\n%% Set basic test parameters\n');
    s{end+1}=sprintf('sampleRates = [44100, 48000, 96000, 192000, 32000];\n');
    s{end+1}=sprintf('frameSizes = [ 2.^(1:13) 2.^(2:13)-1 2.^(1:13)+1];\n');
    s{end+1}=sprintf('totalFrameSize = sum(frameSizes);\n');

    s{end+1}=sprintf('\n%% Create output buffer if requested\n');
    s{end+1}=sprintf('if nargout > 0\n');
    s{end+1}=sprintf('    nout = %d;\n',sum(outputChannels));
    s{end+1}=sprintf('    obuf = zeros(totalFrameSize*numel(sampleRates), nout);\n');
    s{end+1}=sprintf('    optr = 1;\n');
    s{end+1}=sprintf('end\n');

    s{end+1}=sprintf('\n%% Instantiate the plugin\n');
    s{end+1}=sprintf('plugin = %s;\n',className);
    s{end+1}=emitSetupIfSystemObject(className,inputChannels);

    s{end+1}=emitStringEnumParamInit(params);

    s{end+1}=sprintf('\n%% Test at each sample rate\n');
    s{end+1}=sprintf('for sampleRate = sampleRates\n');

    if hasSamplesPerFrame
        s{end+1}=sprintf('samplesPerFrame = getSamplesPerFrame(plugin);\n');
    end

    if hasParams
        s{end+1}=sprintf('paramState = initParamState(plugin);\n');
    end

    s{end+1}=sprintf('\n%% Tell plugin the current sample rate\n');
    s{end+1}=sprintf('setSampleRate(plugin, sampleRate);\n');
    if hasMethodNamed(className,'reset')
        s{end+1}=sprintf('reset(plugin);\n');
        s{end+1}=emitTamperingChecks('''Resetting plugin''');

    elseif hasMethodNamed(className,'init')
        s{end+1}=sprintf('init(plugin);\n');
        s{end+1}=emitTamperingChecks('''Resetting plugin''');

    else
        s{end+1}=sprintf('\n%% Plugin has no reset method to call after setting sample rate\n');
    end

    n=sum(inputChannels);
    if n==1
        s{end+1}=sprintf('\n%% Create input data: logarithmically swept sine wave\n');
        s{end+1}=sprintf('ibuf = logchirp(20, 20e3, sampleRate, totalFrameSize, 0);\n');
        s{end+1}=sprintf('iptr = 1;\n');
    elseif n>1
        s{end+1}=sprintf('\n%% Create input data: logarithmically swept sine waves, with a\n');
        s{end+1}=sprintf('%% different initial phase for each channel\n');
        s{end+1}=sprintf('phaseOffsets = (0:%d)/%d * 0.5 * pi;\n',n-1,n-1);
        s{end+1}=sprintf('ibuf = logchirp(20, 20e3, sampleRate, totalFrameSize, phaseOffsets);\n');
        s{end+1}=sprintf('iptr = 1;\n');
    end

    s{end+1}=sprintf('\n%% Process data using different frame sizes\n');
    s{end+1}=sprintf('for i = 1:numel(frameSizes)\n');
    s{end+1}=sprintf('samplesPerFrame = frameSizes(i);\n');
    if hasSamplesPerFrame
        s{end+1}=sprintf('setSamplesPerFrame(plugin, samplesPerFrame);\n');
    end

    if hasParams
        s{end+1}=emitParamSweep(params);
    end

    s{end+1}=emitProcess(className,inputChannels,outputChannels);

    s{end+1}=emitOutputChecks(outputChannels);
    s{end+1}=emitTamperingChecks('''Running plugin''');

    s{end+1}=sprintf('end\n');
    s{end+1}=sprintf('end\n');

    s{end+1}=sprintf('\n%% Return output data if requested\n');
    s{end+1}=sprintf('if nargout > 0\n');
    s{end+1}=sprintf('    out = obuf;\n');
    s{end+1}=sprintf('end\n');

    s{end+1}=sprintf('end\n');

    s{end+1}=emitCheckForTamperingFcn(params);
    if~hasSamplesPerFrame
        s{end+1}=emitChirpFcn;
    end
    if hasParams
        s{end+1}=emitInitParamStateFcn(params);
        s{end+1}=emitFromNormalizedFcns(params);
    end

    fid=openOutputFile([testbenchName,'.m']);
    fprintf(fid,'%s',indentcode([s{:}]));
    fclose(fid);

end

function s=testbenchComment(testbenchName)
    fmt=[
'%% %s Exercise audio plugin class\n'...
    ,'%% to check for violations of plugin constraints and other errors.\n'...
    ,'%%\n'...
    ,'%% OUT = %s Return the output data from the\n'...
    ,'%% plugin. This is useful to verify that plugin numeric behavior has not\n'...
    ,'%% changed, when you are changing your plugin in ways that should not\n'...
    ,'%% affect that behavior (eg, refactoring code).\n'...
    ,'%%\n'...
    ,'%% You can test whether your MATLAB plugin code is ready for code\n'...
    ,'%% generation by creating and running a mex function from this testbench:\n'...
    ,'%%\n'...
    ,'%%   codegen %s    %% Create the mex function\n'...
    ,'%%   %s_mex        %% Run the mex function\n'...
    ,'%%\n'...
    ,'%% You can use this testbench as a template and edit it to meet your\n'...
    ,'%% testing needs. Rename the file to ensure your work is not\n'...
    ,'%% accidentally overwritten and lost by another run of\n'...
    ,'%% validateAudioPlugin.\n'...
    ,'%%\n'...
    ,'%% Automatically generated by validateAudioPlugin %s\n'...
    ];
    t=datetime('now','TimeZone','local','Format','dd-MMM-yyyy HH:mm:ss ZZZZ');
    s=sprintf(fmt,upper(testbenchName),upper(testbenchName),...
    testbenchName,testbenchName,char(t));
end

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

function s=emitProcess(className,inputChannels,outputChannels)
    s={};

    if sum(inputChannels)>0
        s{end+1}=sprintf('\n%% Get a frame of input data\n');
        s{end+1}=sprintf('in = ibuf(iptr:iptr+samplesPerFrame-1, :);\n');
        s{end+1}=sprintf('iptr = iptr + samplesPerFrame;\n');
    end

    s{end+1}=sprintf('\n%% Run the plugin\n');



    inNames={'plugin'};
    last=cumsum(inputChannels);
    first=[0,last(1:end-1)]+1;
    if sum(inputChannels)>0
        for i=1:numel(inputChannels)
            if first(i)==last(i)
                inNames{end+1}=sprintf('in(1:samplesPerFrame,%d)',first(i));
            else
                inNames{end+1}=sprintf('in(1:samplesPerFrame,%d:%d)',first(i),last(i));
            end
        end
    end
    outNames=arrayfun(@(x)sprintf('o%d',x),1:numel(outputChannels),'UniformOutput',false);
    if matlab.system.isSystemObjectName(className)
        run='step';
    else
        run='process';
    end
    s{end+1}=sprintf('%s;\n',makeMPrototype(run,inNames,outNames));

    s{end+1}=sprintf('\n%% Save the output data if requested\n');
    s{end+1}=sprintf('if nargout > 0\n');
    s{end+1}=sprintf('obuf(optr:optr+samplesPerFrame-1, :) = ');
    assert(numel(outNames)>0,'plugins with no outputs are not supported');
    if numel(outNames)==1
        s{end+1}=sprintf('%s;\n',outNames{1});
    else
        s{end+1}=sprintf('[%s];\n',strjoin(outNames,', '));
    end
    s{end+1}=sprintf('optr = optr + samplesPerFrame;\n');
    s{end+1}=sprintf('end\n');

    s=[s{:}];
end

function s=emitStringEnumParamInit(params)
    s={};
    if~isempty(params)
        enumParams=params(strcmp({params.Law},'enum'));
        if~isempty(enumParams)
            s{end+1}=sprintf('%% Initialize enumeration to enable code generation\n');
            for p=enumParams(:)'
                prop=p.Property;
                defval=p.DefaultValue;
                enums=cellstr(p.Enums);
                enums=[setdiff(enums,defval);defval];
                for q=enums(:)'
                    s{end+1}=sprintf('plugin.%s = ''%s'';\n',prop,q{1});
                end
            end
        end
    end
    s=[s{:}];
end

function s=emitParamSweep(params)
    s={};
    names={params.Property};
    b=3;
    for n=1:numel(names)
        s{end+1}=sprintf('\nval = fromNormalized%s(mod(floor((i-1)./%d),%d)/%d);\n',names{n},b.^(n-1),b,b-1);
        s{end+1}=sprintf('plugin.%s = val;\n',names{n});
        s{end+1}=sprintf('paramState.%s = val;\n',names{n});
        cause=sprintf('...\n''Setting parameter ''''%s''''''',names{n});
        s{end+1}=emitTamperingChecks(cause);
    end
    s=[s{:}];
end

function s=emitOutputChecks(outputChannels)
    s={};
    s{end+1}=sprintf('\n%% Verify class and size of outputs\n');
    for i=1:numel(outputChannels)
        s{end+1}=sprintf('if ~isa(o%d, ''double'')\n',i);
        s{end+1}=sprintf('error(''ValidateAudioPlugin:OutputNotDouble'', ...\n[''Output %d is of class %%s, '' ...\n''but should have been double.''], ...\nclass(o%d));\n',i,i);
        s{end+1}=sprintf('end\n');

        s{end+1}=sprintf('if size(o%d,1) ~= samplesPerFrame\n',i);
        s{end+1}=sprintf('error(''ValidateAudioPlugin:BadOutputFrameSize'', ...\n[''Output %d produced a frame size of %%d, '' ...\n''but should have matched the input frame size of %%d.''], ...\nsize(o%d,1), samplesPerFrame);\n',i,i);
        s{end+1}=sprintf('end\n');

        s{end+1}=sprintf('if size(o%d,2) ~= %d\n',i,outputChannels(i));
        s{end+1}=sprintf('error(''ValidateAudioPlugin:BadOutputWidth'', ...\n[''Width of output %d was %%d, '' ...\n''but should have been %d (OutputChannels(%d)).''], ...\nsize(o%d,2));\n',i,outputChannels(i),i,i);
        s{end+1}=sprintf('end\n');
    end
    s=[s{:}];
end

function s=emitInitParamStateFcn(params)
    s={};
    s{end+1}=sprintf('\nfunction paramState = initParamState(plugin)\n');
    names={params.Property};
    for i=1:numel(names)
        s{end+1}=sprintf('paramState.%s = plugin.%s;\n',names{i},names{i});
    end
    s{end+1}=sprintf('end\n');
    s=[s{:}];
end

function sig=checkForTamperingSignature(cause)
    s={};
    s{end+1}=sprintf('checkForTampering(plugin');
    if hasParams
        s{end+1}=', paramState';
    end
    s{end+1}=', sampleRate';
    if hasSamplesPerFrame
        s{end+1}=', samplesPerFrame';
    end
    s{end+1}=sprintf(', %s)',cause);
    sig=[s{:}];
end

function s=emitTamperingChecks(cause)
    s=sprintf('%s;\n',checkForTamperingSignature(cause));
end

function s=emitCheckForTamperingFcn(params)
    s={};
    s{end+1}=sprintf('\nfunction %s\n',checkForTamperingSignature('cause'));

    if hasParams
        s{end+1}=sprintf('%% Verify parameters were not tampered with\n');
        names={params.Property};
        for i=1:numel(names)
            s{end+1}=sprintf('if ~isequal(paramState.%s, plugin.%s)\n',names{i},names{i});
            s{end+1}=sprintf(...
            'error(''ValidateAudioPlugin:ParamChanged'', ...\n''%%s changed parameter ''''%s''''',...
            names{i});
            switch params(i).Law
            case 'enum'
                s{end+1}=sprintf(...
                ' from ''''%%s'''' to ''''%%s''.'''', ...\ncause, paramState.%s, plugin.%s',...
                names{i},names{i});
            case 'enumclass'

                s{end+1}=sprintf('.'', cause');
            otherwise
                s{end+1}=sprintf(...
                ' from %%g to %%g.'', ...\ncause, paramState.%s, plugin.%s',...
                names{i},names{i});
            end
            s{end+1}=sprintf(');\n');
            s{end+1}=sprintf('end\n');
        end
    end

    s{end+1}=sprintf('%% Verify sample rate was not tampered with\n');
    s{end+1}=sprintf('if ~isequal(getSampleRate(plugin), sampleRate)\n');
    s{end+1}=sprintf('error(''ValidateAudioPlugin:SampleRateChanged'', ...\n');
    s{end+1}=sprintf('''%%s changed sample rate from %%g to %%g.''');
    s{end+1}=sprintf(', ...\ncause, sampleRate, getSampleRate(plugin));\n');
    s{end+1}=sprintf('end\n');

    if hasSamplesPerFrame
        s{end+1}=sprintf('%% Verify Samples Per Frame was not tampered with\n');
        s{end+1}=sprintf('if ~isequal(getSamplesPerFrame(plugin), samplesPerFrame)\n');
        s{end+1}=sprintf('error(''ValidateAudioPlugin:SamplesPerFrameChanged'', ...\n');
        s{end+1}=sprintf('''%%s changed samples per frame from %%g to %%g.''');
        s{end+1}=sprintf(', ...\ncause, samplesPerFrame, getSamplesPerFrame(plugin));\n');
        s{end+1}=sprintf('end\n');
    end

    s{end+1}=sprintf('end\n');
    s=[s{:}];
end

function s=emitFromNormalizedFcns(params)
    s={};
    for i=1:numel(params)
        param=params(i);
        s{end+1}=sprintf('\nfunction val = fromNormalized%s(normval)\n',param.Property);
        switch param.Law
        case 'lin'
            s{end+1}=sprintf('val = %g + (%g-%g)*normval;\n',...
            param.Min,param.Max,param.Min);
        case{'fader','pow'}
            s{end+1}=sprintf('val = %g + (%g-%g)*normval.^%g;\n',...
            param.Min,param.Max,param.Min,param.Shape);
        case 'log'
            s{end+1}=sprintf('val = %g * (%g/%g).^normval;\n',...
            param.Min,param.Max,param.Min);
        case 'int'
            s{end+1}=sprintf('val = floor(0.5 + %g + (%g-%g)*normval);\n',...
            param.Min,param.Max,param.Min);
        case 'enum'
            enums=cellstr(param.Enums);
            s{end+1}=sprintf('idx = floor( 0.5 + normval * %d);\n',numel(enums)-1);
            s{end+1}=sprintf('switch idx\n');
            for j=1:numel(enums)-1
                s{end+1}=sprintf('case %d\n',j-1);
                s{end+1}=sprintf('val = ''%s'';\n',enums{j});
            end
            s{end+1}=sprintf('otherwise\n');
            s{end+1}=sprintf('val = ''%s'';\n',enums{end});
            s{end+1}=sprintf('end\n');
        case 'enumclass'
            defval=param.DefaultValue;
            [~,enumNames]=enumeration(defval);
            enums=sprintf([class(defval),'.%s '],enumNames{:});
            s{end+1}=sprintf('enums = [ %s];\n',enums);
            s{end+1}=sprintf('val = enums(1 + floor( 0.5 + normval * (numel(enums)-1)));\n');
        case 'logical'
            s{end+1}=sprintf('val = logical(floor(0.5 + normval));\n');
        otherwise
            assert(false,'emitFromNormalizedFcns: unexpected law ''%s''',param.Law);
        end
        s{end+1}=sprintf('end\n');
    end
    s=[s{:}];
end

function s=emitChirpFcn
    s={};
    s{end+1}=sprintf('\nfunction y = logchirp(f0, f1, Fs, nsamples, initialPhase)\n');
    s{end+1}=sprintf('    %% logarithmically swept sine from f0 to f1 over nsamples, at Fs\n');
    s{end+1}=sprintf('    y = zeros(nsamples,numel(initialPhase));\n');
    s{end+1}=sprintf('    instPhi = logInstantaneousPhase(f0, f1, Fs, nsamples);\n');
    s{end+1}=sprintf('    for i = 1:numel(initialPhase)\n');
    s{end+1}=sprintf('        y(:,i) = sin(instPhi + initialPhase(i));\n');
    s{end+1}=sprintf('    end\n');
    s{end+1}=sprintf('end\n');
    s{end+1}=sprintf('\nfunction phi = logInstantaneousPhase(f0, f1, Fs, n)\n');
    s{end+1}=sprintf('    final = n-1;\n');
    s{end+1}=sprintf('    t = (0:final)/final;\n');
    s{end+1}=sprintf('    t1 = final/Fs;\n');
    s{end+1}=sprintf('    phi = 2*pi * t1/log(f1/f0) * (f0 * (f1/f0).^(t'') - f0);\n');
    s{end+1}=sprintf('end\n');
    s=[s{:}];
end

function yes=hasSamplesPerFrame(className)
    persistent x
    if nargin>0
        x=hasMethodNamed(className,'setSamplesPerFrame');
    end
    yes=x;
end

function yes=hasParams(params)
    persistent x
    if nargin>0
        x=~isempty(params);
    end
    yes=x;
end

function yes=hasMethodNamed(mc,methodName)
    if ischar(mc)
        mc=meta.class.fromName(mc);
    end
    allMethodNames={mc.MethodList(:).Name};
    yes=any(strcmp(methodName,allMethodNames));
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

function yes=isString(s)
    yes=ischar(s)&&isrow(s);
end

function yes=isOption(s)
    yes=isString(s)&&~isempty(s)&&s(1)=='-';
end

function fid=openOutputFile(path)
    [fid,msg]=fopen(path,'w');
    if fid<0
        error(message('audio:plugin:FopenFailed',path,msg));
    end
end

function makeWorkFolder(workFolder)
    if~exist(workFolder,'dir')
        [ok,msg]=mkdir(workFolder);
        if~ok
            error(message('audio:plugin:MkdirFailed',workFolder,msg));
        end
    end
end


