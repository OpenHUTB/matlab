function commands=getCompileCommandsForProject(model,buildInfo,config,varargin)












    buildDir=emlcprivate('emcGetBuildDirectory',buildInfo,coder.internal.BuildMode.Normal);

    parser=inputParser;
    addParameter(parser,'AltBuildDir',buildDir);
    parser.parse(varargin{:});
    altBuildDir=parser.Results.AltBuildDir;

    srcFiles=getSrcFilesForProject(buildInfo);
    srcFiles=replaceBaseDir(srcFiles,buildDir,altBuildDir);
    commands=generateCommandsForSrcFiles(model,srcFiles);

    workDir=getWorkDirForProject(buildInfo);
    populateWorkDir(commands,workDir);

    language=getLanguageForProject(config);
    populateLanguage(commands,language);

    includes=getIncludesForProject(buildInfo);
    includes=replaceBaseDir(includes,buildDir,altBuildDir);
    populateIncludes(commands,includes);

    defines=getDefinesForProject(buildInfo);
    populateDefines(commands,defines);
end

function srcFiles=getSrcFilesForProject(buildInfo)
    srcFiles=string(getSourceFiles(buildInfo,true,true));
    if~isempty(buildInfo.Tokens)
        idx=string({buildInfo.Tokens.Key})=="EXAMPLE_MAIN_SRC_FILE";
        for file=string({buildInfo.Tokens(idx).Value})
            srcFiles(end+1)=file;%#ok<AGROW>
        end
    end
end

function workDir=getWorkDirForProject(~)
    workDir=".";
end

function language=getLanguageForProject(config)
    import coder.internal.clang.*;
    if coder.internal.isGpuConfigEnabled(config)
        language=LanguageStandard.CUDA_CXX17;
    elseif~isempty(config)&&isprop(config,'TargetLang')&&strcmp(config.TargetLang,'C')
        language=LanguageStandard.C17;
    else
        language=LanguageStandard.CXX17;
    end
end

function defines=getDefinesForProject(buildInfo)
    [~,keys,values]=getDefines(buildInfo);
    defines=struct('Key',keys,'Value',values)';
end

function includes=getIncludesForProject(buildInfo)
    includes=string(getIncludePaths(buildInfo,true));
end

function commands=generateCommandsForSrcFiles(model,srcFiles)
    import coder.internal.clang.*;
    commands=repmat(CompileCommand(model),[0,0]);
    for srcFile=srcFiles
        command=CompileCommand(model);
        command.SrcFile=srcFile;
        commands(end+1)=command;%#ok<AGROW>
    end
end

function populateDefines(commands,defines)
    for command=commands
        for define=defines
            command.createIntoDefines(struct('Key',define.Key,'Value',define.Value));
        end
    end
end

function populateIncludes(commands,includeDirs)
    for command=commands
        for includeDir=includeDirs
            command.IncludeDirs.add(includeDir);
        end
    end
end

function populateWorkDir(commands,workDir)
    for command=commands
        command.WorkingDir=workDir;
    end
end

function populateLanguage(commands,language)
    for command=commands
        command.Language=language;
    end
end

function converted=replaceBaseDir(files,origBase,newBase)
    files=cellstr(files);
    converted=codergui.evalprivate('replaceBasePath',files,origBase,newBase);
    converted=string(converted)';
end



