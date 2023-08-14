



function[cgelOut,translationLog]=sourceAnalysis(sourceDir,options,sourceFiles,posConverter,varargin)

    if nargin<4
        posConverter=sldv.code.internal.PosConverter();
    end

    persistent psBin il2cgel il2vvir arch

    if isempty(psBin)
        arch=computer('arch');
        psBin=fullfile(matlabroot,'bin',arch,'ps_pckg');
        il2cgel=fullfile(matlabroot,'bin',arch,'ps_il2cgel');
        il2vvir=fullfile(matlabroot,'bin',arch,'ps_il_vs_vvir');
        if ispc
            psBin=[psBin,'.exe'];
            il2cgel=[il2cgel,'.exe'];
            il2vvir=[il2vvir,'.exe'];
        end
    end

    persistent argParser;
    if isempty(argParser)
        argParser=inputParser;
        addOptional(argParser,'functionLinkErrorId','functionLinkError');
        addOptional(argParser,'unexpectedAnalysisErrorId','unexpectedAnalysisError');
        addOptional(argParser,'forXIL',false);
    end

    parse(argParser,varargin{:});

    cgelOut=uint8('');
    translationLog=sldv.code.internal.TranslationLog();

    if isfield(options,'language')
        language=options.language;
        if strcmpi(language,'c++')
            language='cpp';
        end
    else
        language='c';
    end

    stdVersion='';
    if isfield(options,'stdVersion')
        stdVersion=options.stdVersion;
    end

    debugMode=sldv.code.internal.feature('debug');
    verboseMode=sldv.code.internal.feature('verbose');

    if isfield(options,'tmpDir')
        tmpDir=options.tmpDir;
    else
        tmpDir=tempname;
    end
    if~isfolder(tmpDir)
        mkdir(tmpDir);
        if~debugMode
            clrObj=onCleanup(@()sldv.code.internal.removeDir(tmpDir));
        end
    end

    if debugMode
        fprintf(1,'### Debug: performing analysis in directory %s\n',tmpDir);
    end


    if isfield(options,'DrsFile')
        drsFile=options.DrsFile;
    else
        drsFile='';
    end


    target='x86_64';
    if strcmp(arch,'win32')
        target='i386';
    end

    if isfield(options,'Dialect')
        dialect=options.Dialect;
    else
        if ispc
            dialect='visual11.0';
        else
            dialect='gnu4.7';
        end
    end

    if isfield(options,'defaultArraySize')
        defaultArraySize=options.defaultArraySize;
    else
        defaultArraySize=512;
    end

    inVars={};
    outVars={};
    protectedVars={};
    codeProcs={};
    removeProcs={};
    inlineProcs={};


    if isfield(options,'InVars')
        inVars=options.InVars;
    end

    if isfield(options,'OutVars')
        outVars=options.OutVars;
    end


    if isfield(options,'ProtectedVars')
        protectedVars=options.ProtectedVars;
    end


    if isfield(options,'SFcnProcs')
        codeProcs=options.SFcnProcs;
    end
    if isfield(options,'CodeProcs')
        codeProcs=[codeProcs(:);options.CodeProcs(:)];
    end

    if isfield(options,'RemoveProcs')
        removeProcs=options.RemoveProcs;
    end

    if isfield(options,'InlineProcs')
        inlineProcs=options.InlineProcs;
    end

    if isfield(options,'PreInclude')
        preInclude=options.PreInclude;
    else
        preInclude='';
    end

    if isfield(options,'Includes')
        includes=options.Includes;
    else
        includes={'.'};
    end


    optionFile=fullfile(tmpDir,'option_file.txt');
    fid=fopen(optionFile,'w');

    if isfield(options,'PsTimestamp')

        timestamp=options.PsTimestamp;
    else





        polyspace_obfuscation=polyspace.internal.polyspaceObfuscation(strjoin({'e','%','*','f','0','{',':','f','3','v','s','d','$','@','d','Q'},''));

        timestamp=polyspace_obfuscation.encrypt(datestr(now,'ddd mmm dd HH:MM:SS yyyy','en_US'));
    end


    addPolyspaceOption(fid,'-enum-type-definition','defined-by-compiler');
    addPolyspaceOption(fid,'-dos');
    addPolyspaceOption(fid,'-scalar-overflows-behavior','wrap-around');
    addPolyspaceOption(fid,'-from-m-launch',timestamp);

    if~isempty(inVars)||~isempty(outVars)||~isempty(protectedVars)
        vars=[inVars;outVars;protectedVars];
        vars=strjoin(vars,',');
        addPolyspaceOption(fid,'-protect-global-variables',vars);
    end

    if numel(codeProcs)>0
        codeProcs=strjoin(codeProcs,',');
        addPolyspaceOption(fid,'-protect-procedures',codeProcs);
    end

    if~isempty(removeProcs)
        removeProcOpt=strjoin(removeProcs,',');
        addPolyspaceOption(fid,'-procedures-to-remove',removeProcOpt);
    end

    if isfield(options,'MainFcn')
        addPolyspaceOption(fid,'-main-generator');
        addPolyspaceOption(fid,'-main-generator-writes-variables','none');
        addPolyspaceOption(fid,'-main-generator-calls',sprintf('custom=%s',options.MainFcn));
    end

    if isfield(options,'Defines')
        defines=options.Defines(:);
    else
        defines={};
    end

    if isfield(options,'RenameMainTo')
        defines=[defines;{sprintf('main=%s',options.RenameMainTo)}];
    end

    if strcmp(language,'cpp')
        if isempty(stdVersion)

            visualPrefix='visual';
            if~strncmp(dialect,visualPrefix,numel(visualPrefix))
                if argParser.Results.forXIL
                    cppVersion='cpp03';
                else
                    cppVersion='cpp11';
                end
                addPolyspaceOption(fid,'-cpp-version',cppVersion);
            end
        else
            addPolyspaceOption(fid,'-cpp-version',stdVersion);
        end

        addPolyspaceOption(fid,'-no-default-system-includes');
        defines=[defines;{'POLYSPACE_NO_STANDARD_STUBS'}];
    else
        if~isempty(stdVersion)
            addPolyspaceOption(fid,'-c-version',stdVersion);
        end
    end
    defines=[defines;{'__MW_INTERNAL_SLDV_PS_ANALYSIS__'}];

    if isfield(options,'ignoreVolatile')&&options.ignoreVolatile
        addPolyspaceOption(fid,'-sldv-code-ignore-volatile');
    end

    addPolyspaceOption(fid,'-to','pass0');
    addPolyspaceOption(fid,'-disable-initialization-checks');

    inlinedFunctions={...
    'mdlOutputs',...
    'mdlInitializeConditions',...
    'mdlUpdate',...
    'mdlStart',...
    'mdlTerminate',...
    'ssGetRealDiscStates',...
    'ssGetNumInputPorts',...
    'ssGetNumOutputPorts',...
    'ssGetNumRunTimeParams',...
    'ssGetInputPortWidth',...
    'ssGetOutputPortWidth',...
    'ssGetRunTimeParamsInfo',...
    };

    if~isempty(inlineProcs)
        inlinedFunctions=[inlinedFunctions,inlineProcs(:)'];
    end

    if~isempty(preInclude)
        addPolyspaceOption(fid,'-include',preInclude);
    end

    addPolyspaceOption(fid,'-prog','fake');
    addPolyspaceOption(fid,'-lang',language);
    addPolyspaceOption(fid,'-target',target);
    addPolyspaceOption(fid,'-compiler',dialect);
    addPolyspaceOption(fid,'-results-dir',tmpDir);
    addPolyspaceOption(fid,'-inline',strjoin(inlinedFunctions,','));

    for i=1:numel(defines)
        addPolyspaceOption(fid,'-D',defines{i});
    end

    for i=1:numel(includes)
        addPolyspaceOption(fid,'-I',includes{i});
    end


    addPolyspaceOption(fid,'-cfe-extra-flags','--sldv_code_analysis');
    addPolyspaceOption(fid,'-cfe-extra-flags','--sldv_code_macro=__MW_INTERNAL_SLDV_PS_ANALYSIS__');




    if ismac
        addPolyspaceOption(fid,'-cfe-extra-flags','--ignore_macro_definition=memccpy');
        addPolyspaceOption(fid,'-cfe-extra-flags','--ignore_macro_definition=memcpy');
        addPolyspaceOption(fid,'-cfe-extra-flags','--ignore_macro_definition=memmove');
        addPolyspaceOption(fid,'-cfe-extra-flags','--ignore_macro_definition=memset');
        addPolyspaceOption(fid,'-cfe-extra-flags','--ignore_macro_definition=strcpy');
        addPolyspaceOption(fid,'-D','__builtin___memccpy_chk(x,y,z,t,u)=memccpy(x,y,z,t)');
        addPolyspaceOption(fid,'-D','__builtin___memcpy_chk(x,y,z,t)=memcpy(x,y,z)');
        addPolyspaceOption(fid,'-D','__builtin___memmove_chk(x,y,z,t)=memmove(x,y,z)');
        addPolyspaceOption(fid,'-D','__builtin___memset_chk(x,y,z,t)=memset(x,y,z)');
        addPolyspaceOption(fid,'-D','__builtin___strcpy_chk(x,y)=strcpy(x,y)');
    end

    addPolyspaceOption(fid,'-sources',strjoin(sourceFiles,','));

    if~isempty(drsFile)
        addPolyspaceOption(fid,'-data-range-specifications',drsFile);
    end


    if debugMode
        addPolyspaceOption(fid,'-debug');
    end

    addPolyspaceOption(fid,'-sources-encoding','UTF-8');

    fclose(fid);

    polyspaceOptions={'polyspace-sldv-code','-options-file',optionFile};

    processOptions={'-working-directory',sourceDir};

    polyspaceEnv=getPolyspaceEnvironment();

    if strcmp(computer('arch'),'glnxa64')&&~isfile(psBin)&&isfile([psBin,'.x86-linux'])
        effPsBin=fullfile(matlabroot,'sml','bin','sml');
        polyspaceOptions=[{['@SMLload=',psBin]},polyspaceOptions];
    else
        effPsBin=psBin;
    end

    [status,polyspaceOutput]=runPolyspaceProcess(effPsBin,processOptions,...
    polyspaceOptions,debugMode,...
    polyspaceEnv);

    if status~=0

        if~isempty(regexp(polyspaceOutput,'Error:\s+calling\s+function\s+[''`][a-zA-Z_0-9]+[''`]\s+with\s+incompatible\s+type','once'))
            translationLog.add(sldv.code.internal.TranslationMessage(sldv.code.internal.TranslationMessage.InternalErrorType,...
            ['sldv_sfcn:sldv_sfcn:',argParser.Results.functionLinkErrorId]))
        else
            translationLog.add(sldv.code.internal.TranslationMessage(sldv.code.internal.TranslationMessage.InternalErrorType,...
            ['sldv_sfcn:sldv_sfcn:',argParser.Results.unexpectedAnalysisErrorId]));
        end

        if debugMode||verboseMode
            disp(polyspaceOutput);
        end
        return
    end

    fleFile=fullfile(tmpDir,'fake.fle');
    ilFile=fullfile(tmpDir,'fake_translate.il');



    originalFile=fullfile(tmpDir,'_original.txt');
    ilInfoFile=fullfile(tmpDir,'fake_c_all.il');
    arfFile=fullfile(tmpDir,'fake.arf');

    if~(isfile(ilFile)&&...
        isfile(ilInfoFile)&&...
        isfile(arfFile)&&...
        isfile(originalFile)&&...
        isfile(fleFile))
        return;
    end





    vvirFile=fullfile(tmpDir,'input.vvir');
    lowerOpts=internal.vvir2cgir.LoweringOptions;
    lowerOpts.DefaultArraySize=defaultArraySize;

    ilvvOptions={'il_to_vvir','-il',ilFile,'-fle',fleFile,'-a',arfFile,'-o',vvirFile};
    [statusil2vvir,~]=runPolyspaceProcess(il2vvir,processOptions,ilvvOptions,debugMode,polyspaceEnv);
    if(statusil2vvir~=0)
        translationLog.add(sldv.code.internal.TranslationMessage(sldv.code.internal.TranslationMessage.InternalErrorType,...
        'sldv_sfcn:vvir_vs_cgir:errorDuringILtoVVIRConversion'));
    else
        if debugMode
            fprintf(1,'Generated vvir file %s \n',vvirFile);
        end

        psChecksFile=fullfile(tmpDir,'ps_checks.db');
        if~isfile(psChecksFile)
            psChecksFile='';
        end

        loweredVvir=fullfile(tmpDir,'lowered.vvir');
        vvirLoweringInfo=internal.vvir2cgir.lowerVVIR(vvirFile,loweredVvir,lowerOpts,originalFile,removeProcs,psChecksFile);
        if vvirLoweringInfo.getStatus()~=1
            translationLog.add(sldv.code.internal.TranslationMessage(sldv.code.internal.TranslationMessage.InternalErrorType,...
            'sldv_sfcn:vvir_vs_cgir:errorDuringVVIRLowering'));
        end

        translationLog.setTranslationStatus(0);

        translationLog.IlFormat=translationLog.VvirFormat;
        translationLog.initFromVvirLoweringInfo(vvirLoweringInfo,posConverter);

        assert(isfile(loweredVvir),'sldv_sfcn:vvir_vs_cgir:errorDuringVVIRLowering');


        fid=fopen(loweredVvir,'rb');
        vvirData=fread(fid,'*uint8');
        fclose(fid);

        cgelOut=vvirData;
    end




    function envVars=setEnvVar(var,value,envVars)
        newValue=sprintf('%s=%s',var,value);
        searched=[var,'='];
        indexes=strncmp(searched,envVars,numel(searched));
        if any(indexes)
            envVars{indexes}=newValue;
        else
            envVars{end+1}=newValue;
        end


        function envVars=getPolyspaceEnvironment()

            envVars=polyspace.internal.Process.getEnvironment();


            MATLAB_ARCH=computer('arch');
            POLYSPACE_BIN=fullfile(matlabroot,'polyspace','bin');
            POLYSPACE_ROOT=fullfile(matlabroot,'polyspace');
            MATLAB_ROOT=matlabroot;
            if ispc
                windir=getenv('WINDIR');

                PATH=sprintf('%s\\System32;%s;%s\\System32\\Wbmem',...
                windir,windir,windir);
            else
                PATH='/bin:/usr/bin:/usr/ucb:/usr/local/bin';
            end

            if ismac
                DYLD_PREFIX='$MATLAB_ROOT/sys/os/$ARCH:$MATLAB_ROOT/bin/$ARCH/../../Contents/MacOS:$MATLAB_ROOT/bin/$ARCH:$MATLAB_ROOT/extern/lib/$ARCH:$MATLAB_ROOT/runtime/$ARCH';
                DYLD_PREFIX=strrep(DYLD_PREFIX,'$MATLAB_ROOT',matlabroot);
                DYLD_PREFIX=strrep(DYLD_PREFIX,'$ARCH',computer('arch'));
            else
                DYLD_PREFIX='';
            end



            mlPID=num2str(feature('getpid'));

            envVars=setEnvVar('PS_ML_PID',mlPID,envVars);


            userVar=getenv('USER');
            if isempty(userVar)

                userVar=getenv('USERNAME');
                if isempty(userVar)

                    userVar='MATLAB';
                end
            end
            envVars=setEnvVar('USER',userVar,envVars);


            originalPath=getenv('PATH');
            envVars=setEnvVar('PST_ORIGINAL_PATH',originalPath,envVars);
            envVars=setEnvVar('PATH',PATH,envVars);


            envVars=setEnvVar('MATLAB_ARCH',MATLAB_ARCH,envVars);
            envVars=setEnvVar('POLYSPACE_ROOT',POLYSPACE_ROOT,envVars);
            envVars=setEnvVar('RTE_BASE',POLYSPACE_ROOT,envVars);
            envVars=setEnvVar('POLYSPACE_BIN',POLYSPACE_BIN,envVars);
            envVars=setEnvVar('MATLAB_ROOT',MATLAB_ROOT,envVars);

            if~ispc
                envVars=setEnvVar('CDPATH','',envVars);

                if ismac
                    envVars=setEnvVar('MATLAB_MEM_MGR','',envVars);
                    DYLD_LIBRARY_PATH=sprintf('%s:%s',DYLD_PREFIX,getenv('DYLD_LIBRARY_PATH'));
                    envVars=setEnvVar('DYLD_LIBRARY_PATH',DYLD_LIBRARY_PATH,envVars);
                end
            end


            function[status,output]=runPolyspaceProcess(process,processArgs,...
                arguments,debugMode,envVars)








                processArgs{end+1}='-capture-stdout';

                if~debugMode||ispc
                    processArgs{end+1}='-discard-stderr';
                end

                cmdArgs={};
                if isfile(process)
                    cmdArgs=[process,arguments];
                end

                if~isempty(cmdArgs)
                    polyspaceProcess=polyspace.internal.Process(processArgs{:},cmdArgs{:},envVars);
                    [status,output]=polyspaceProcess.getExitStatus();
                else
                    status=-1;
                    output=process;
                end


                function addPolyspaceOption(fid,optionName,optionValue)



                    if nargin==3
                        line=[optionName,' ',optionValue];
                    elseif nargin==2
                        line=optionName;
                    else
                        line='#';
                    end
                    fprintf(fid,'%s\n',line);








