

function[status,res]=analyze(varargin)

    isCharCompatible=@(x)ischar(x)||(isstring(x)&&isscalar(x));
    isCellStrCompatible=@(x)iscellstr(x)||isstring(x);
    isCellOrCharCompatible=@(x)isCellStrCompatible(x)||isCharCompatible(x);
    persistent argParser;
    if isempty(argParser)
        argParser=inputParser;
        addParameter(argParser,'SourceFiles',{},@(x)isCellOrCharCompatible(x));
        addParameter(argParser,'IncludeDirs',{},@(x)isCellOrCharCompatible(x));
        addParameter(argParser,'Defines',{},@(x)isCellOrCharCompatible(x));
        addParameter(argParser,'ExtraOptions',{},@(x)isCellOrCharCompatible(x));
        addParameter(argParser,'ParsingOptions',internal.cxxfe.FrontEndOptions.empty,@(x)isa(x,'internal.cxxfe.FrontEndOptions'));
        addParameter(argParser,'ResultsDir','',@(x)isCharCompatible(x));
        addParameter(argParser,'JSONGlobalIOFile','',@(x)isCharCompatible(x));
        addParameter(argParser,'Debug',false,@(x)isa(x,'logical'));
        addParameter(argParser,'MacroInvocation',false,@(x)isa(x,'logical'));
        addParameter(argParser,'UseCodeInsight',true,@(x)isa(x,'logical'));
        addParameter(argParser,'KeepAllFiles',false,@(x)isa(x,'logical'));
    end
    argParser.parse(varargin{:});

    status=1;
    res=[];

    if polyspace.internal.codeinsight.analyzer.globalVariableParserAnalysis
        parseRes=polyspace.internal.codeinsight.parser.parse(...
        'SourceFiles',argParser.Results.SourceFiles,...
        'IncludeDirs',argParser.Results.IncludeDirs,...
        'Defines',argParser.Results.Defines,...
        'ParsingOptions',argParser.Results.ParsingOptions,...
        'Debug',argParser.Results.Debug);
        res=polyspace.internal.codeinsight.parser.extractGlobalSymbolInfo(parseRes.Info);

        if~ismember('JSONGlobalIOFile',argParser.UsingDefaults)
            globalIOData=polyspace.internal.codeinsight.analyzer.getGlobalIOData(res);
            fid=fopen(argParser.Results.JSONGlobalIOFile,'w');
            fprintf(fid,"%s",jsonencode(globalIOData));
            fclose(fid);
        end
        return;
    end


    sourceFiles=cellstr(convertStringsToChars(argParser.Results.SourceFiles));
    if isempty(sourceFiles)
        return
    end


    parsingOptions=argParser.Results.ParsingOptions;
    if isempty(parsingOptions)
        if polyspace.internal.codeinsight.utils.hasCxxSources(argParser.Results.SourceFiles)
            lang='cxx';
        else
            lang='c';
        end
        parsingOptions=internal.cxxfe.util.getMexFrontEndOptions('lang',lang,'addMWInc',true);
    end
    isCxx=startsWith(parsingOptions.Language.LanguageMode,'cxx');


    includeDirs=cellstr(convertStringsToChars(argParser.Results.IncludeDirs));
    defines=cellstr(convertStringsToChars(argParser.Results.Defines));
    parsingOptions.Preprocessor.IncludeDirs=[parsingOptions.Preprocessor.IncludeDirs(:);includeDirs(:)];
    parsingOptions.Preprocessor.Defines=[parsingOptions.Preprocessor.Defines(:);defines(:)];



    tmpDir=tempname(fullfile(tempdir,'CodeInsight'));
    if~isfolder(tmpDir)
        mkdir(tmpDir);
        if argParser.Results.Debug
            fprintf(1,'### Debug: use temporary folder: %s\n',tmpDir);
        else
            clrObj=onCleanup(@()rmdir(tmpDir,'s'));
        end
    end


    optionFile=fullfile(tmpDir,'option_file.txt');
    [fid,msg]=fopen(optionFile,'w');
    if fid<0
        fprintf(1,'%s\n',msg);
        return
    end


    progName='code_insight';

    polyspace_obfuscation=polyspace.internal.polyspaceObfuscation(strjoin({'e','%','*','f','0','{',':','f','3','v','s','d','$','@','d','Q'},''));
    timestamp=polyspace_obfuscation.encrypt(datestr(now,'ddd mmm dd HH:MM:SS yyyy','en_US'));
    addPolyspaceOption(fid,'-from-m-launch',timestamp);

    addPolyspaceOption(fid,'-prog',progName);
    addPolyspaceOption(fid,'-main-generator');
    addPolyspaceOption(fid,'-main-generator-calls','unused');
    addPolyspaceOption(fid,'-main-generator-writes-variables','public');
    if argParser.Results.UseCodeInsight
        addPolyspaceOption(fid,'-for-code-insight');
    else
        addPolyspaceOption(fid,'-to pass0');
    end
    if isCxx
        addPolyspaceOption(fid,'-lang','c++');
    else
        addPolyspaceOption(fid,'-lang','c');
    end
    addPolyspaceOption(fid,'-fail-if-error');
    addPolyspaceOption(fid,'-stop-if-compile-error');

    compilerInfo=sldv.code.internal.getCompilerInfo(parsingOptions);
    addPolyspaceOption(fid,'-target','x86_64');
    addPolyspaceOption(fid,'-compiler',compilerInfo.dialect);

    extraOptions=cellstr(convertStringsToChars(argParser.Results.ExtraOptions));
    cellfun(@(x)addPolyspaceOption(fid,x),extraOptions);

    cellfun(@(x)addPolyspaceOption(fid,'-I',x),parsingOptions.Preprocessor.SystemIncludeDirs);
    cellfun(@(x)addPolyspaceOption(fid,'-I',x),parsingOptions.Preprocessor.IncludeDirs);
    cellfun(@(x)addPolyspaceOption(fid,'-D',x),parsingOptions.Preprocessor.Defines);

    addPolyspaceOption(fid,'-sources ',strjoin(sourceFiles,','));
    addPolyspaceOption(fid,'-results-dir',tmpDir);

    if argParser.Results.Debug
        addPolyspaceOption(fid,'-debug');
    end

    if argParser.Results.KeepAllFiles
        addPolyspaceOption(fid,'-keep-all-files');
    end

    if argParser.Results.MacroInvocation
        if~argParser.Results.KeepAllFiles
            addPolyspaceOption(fid,'-keep-all-files');
        end
        addPolyspaceOption(fid,'-misra3 all-rules');

        addPolyspaceOption(fid,'-cfe-extra-flags --expansion_line_info');
    end

    fclose(fid);


    [envVars,instInfo]=setPolyspaceEnvironment();
    cmdArgs={instInfo.PS_PCKG,'polyspace-code-prover','-options-file',optionFile};
    processArgs={};
    if~argParser.Results.Debug
        processArgs={'-capture-stdout'};
    end
    if~argParser.Results.Debug||ispc
        processArgs{end+1}='-discard-stderr';
    end

    polyspaceProcess=polyspace.internal.Process(processArgs{:},cmdArgs{:},envVars);%#ok<NASGU>
    [processOutputText,polyspaceStatus]=evalc('polyspaceProcess.getExitStatus(false,true);');
    if argParser.Results.Debug
        fprintf(1,'### Debug: use temporary folder: %s\n',tmpDir);
    end




    if polyspaceStatus~=0
        disp(processOutputText);
        status=0;
        return;
    end

    resFile=fullfile(tmpDir,'ps_results.pscp');


    if~isfile(resFile)
        status=0;
        return;
    end


    if~ismember('ResultsDir',argParser.UsingDefaults)

        if~isempty(argParser.Results.ResultsDir)&&~isfolder(argParser.Results.ResultsDir)
            mkdir(argParser.Results.ResultsDir);
        end
        if argParser.Results.KeepAllFiles||argParser.Results.MacroInvocation
            resFEFile=fullfile(tmpDir,'C-ALL','ps_internal_fe.db');
            if isfile(resFEFile)
                dbFERes=fullfile(argParser.Results.ResultsDir,'ps_internal_fe.db');
                copyfile(resFEFile,dbFERes,'f');
            end
            resFEDirs=dir([tmpDir,'/C-ALL/*/*.db']);
            for idx=1:numel(resFEDirs)
                current=string(fullfile(resFEDirs(idx).folder,resFEDirs(idx).name));
                unitDir=fullfile(argParser.Results.ResultsDir,"/C-ALL/"+idx);
                if~isfolder(unitDir)
                    mkdir(unitDir);
                end
                copyfile(current,fullfile(unitDir,resFEDirs(idx).name))
            end
        end
        if~isfile(resFile)
            return
        end
        dbRes=fullfile(argParser.Results.ResultsDir,'ps_results.pscp');
        copyfile(resFile,dbRes,'f');
    end

    res=polyspace.internal.codeinsight.analyzer.extractGlobalSymbolInfo(resFile);

    if~ismember('JSONGlobalIOFile',argParser.UsingDefaults)
        globalIOData=polyspace.internal.codeinsight.analyzer.getGlobalIOData(res);
        fid=fopen(argParser.Results.JSONGlobalIOFile,'w');
        fprintf(fid,"%s",jsonencode(globalIOData));
        fclose(fid);
    end

end


function out=getPolyspaceInstallInfo()
    persistent info;
    if isempty(info)
        info.MATLAB_ARCH=computer('arch');
        info.POLYSPACE_BIN=fullfile(matlabroot,'polyspace','bin');
        info.POLYSPACE_ROOT=fullfile(matlabroot,'polyspace');
        info.MATLAB_ROOT=matlabroot;
        info.PS_PCKG=fullfile(matlabroot,'bin',info.MATLAB_ARCH,'ps_pckg');

        if ispc
            info.PS_PCKG=[info.PS_PCKG,'.exe'];

            windir=getenv('WINDIR');

            info.PATH=sprintf('%s\\System32;%s;%s\\System32\\Wbmem',...
            windir,windir,windir);
        else
            info.PATH='/bin:/usr/bin:/usr/ucb:/usr/local/bin';
        end

        if ismac
            DYLD_PREFIX='$MATLAB_ROOT/sys/os/$ARCH:$MATLAB_ROOT/bin/$ARCH/../../Contents/MacOS:$MATLAB_ROOT/bin/$ARCH:$MATLAB_ROOT/extern/lib/$ARCH:$MATLAB_ROOT/runtime/$ARCH';
            DYLD_PREFIX=strrep(DYLD_PREFIX,'$MATLAB_ROOT',matlabroot);
            info.DYLD_PREFIX=strrep(DYLD_PREFIX,'$ARCH',computer('arch'));
        else
            info.DYLD_PREFIX='';
        end

        info.userVar=getenv('USER');
        if isempty(info.userVar)

            info.userVar=getenv('USERNAME');
            if isempty(info.userVar)

                info.userVar='MATLAB';
            end
        end
    end

    out=info;
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
end


function[envVars,instInfo]=setPolyspaceEnvironment()

    envVars=polyspace.internal.Process.getEnvironment();


    instInfo=getPolyspaceInstallInfo();


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
    envVars=setEnvVar('PATH',instInfo.PATH,envVars);


    envVars=setEnvVar('MATLAB_ARCH',instInfo.MATLAB_ARCH,envVars);
    envVars=setEnvVar('POLYSPACE_ROOT',instInfo.POLYSPACE_ROOT,envVars);
    envVars=setEnvVar('RTE_BASE',instInfo.POLYSPACE_ROOT,envVars);
    envVars=setEnvVar('POLYSPACE_BIN',instInfo.POLYSPACE_BIN,envVars);
    envVars=setEnvVar('MATLAB_ROOT',instInfo.MATLAB_ROOT,envVars);

    if~ispc
        envVars=setEnvVar('CDPATH','',envVars);

        if ismac
            envVars=setEnvVar('MATLAB_MEM_MGR','',envVars);
            DYLD_LIBRARY_PATH=sprintf('%s:%s',instInfo.DYLD_PREFIX,getenv('DYLD_LIBRARY_PATH'));
            envVars=setEnvVar('DYLD_LIBRARY_PATH',DYLD_LIBRARY_PATH,envVars);
        end
    end
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
end
