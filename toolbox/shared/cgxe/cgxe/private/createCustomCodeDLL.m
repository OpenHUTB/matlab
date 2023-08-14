function createCustomCodeDLL(ccChecksum,customCodeSettings,extraSettings,variadicFcns)




    if~isempty(extraSettings)
        customCodeSettings.userIncludeDirs=[customCodeSettings.userIncludeDirs,extraSettings.userIncludeDirs];
        customCodeSettings.userSources=[customCodeSettings.userSources,extraSettings.userSources];
    end
    compilerInfo=cgxeprivate('compilerman','get_compiler_info',customCodeSettings.isCpp);
    compiler=compilerInfo.compilerName;
    checkCurrentDir(compiler);

    outName=[ccChecksum,'_cclib'];

    [includePaths,srcFiles,libFiles]=collectDependencies(customCodeSettings);
    [flagInfo,mexVarNames]=collectFlags(customCodeSettings,compiler,outName,variadicFcns);

    mexIncludePathString=strcat('-I',includePaths);

    dllExt=cgxeprivate('getLibraryExtension','dynamic');
    mexVariables={['LDEXT="',dllExt,'"'],'LINKEXPORT=','LINKEXPORTVER='};
    if ismac
        mexVariables{end+1}='LDBUNDLE=-dynamiclib';
        if compilerInfo.isCpp
            mexVariables{end+1}='LINKEXPORTCPP=';
        end
    end
    mexVariables=[mexVarNames.CompilerVars,mexVariables];
    mexCompileFlags=overwriteMexCompileFlags(mexVarNames,compiler,compilerInfo,flagInfo);

    mexLinkFlags=[mexVarNames.link,'=$',mexVarNames.link,' ',flagInfo.ldflags];

    callMexCommand(compilerInfo,srcFiles,...
    mexCompileFlags,mexLinkFlags,mexVariables,...
    mexIncludePathString,outName,libFiles);
end

function mexCompileFlags=overwriteMexCompileFlags(mexVarNames,compiler,compilerInfo,flagInfo)
    mexCompileFlags=compilerInfo.Details.CompilerFlags;
    switch(compiler)
    case['g++','gcc','clang','clang++',cgxeprivate('supportedPCCompilers','mingw')]
        mexCompileFlags=[mexCompileFlags,' -w'];
    case cgxeprivate('supportedPCCompilers','microsoft')
        mexCompileFlags=regexprep(mexCompileFlags,'(^|\s+)/W3(\s+|$)',' ');
        mexCompileFlags=[mexCompileFlags,' /w'];
    otherwise
        warning('SLCC Exception: Unhandled compiler "%s".',compiler);
    end

    mexCompileFlags=[mexVarNames.compile,'=',mexCompileFlags,' ',flagInfo.cflags];
end


function callMexCommand(compilerInfo,srcFiles,mexCompileFlags,mexLinkFlags,mexVariables,mexIncludePathString,outName,libFiles)
    mexVars={'-g',...
    '-silent','-R2018a',...
    '-f',compilerInfo.MexOpt,...
    mexVariables{:},...
    mexIncludePathString{:},...
mexCompileFlags...
    };%#ok<CCAT>

    objFiles=getObjFilesFromSrc(srcFiles);

    mexVarsCompile=[{'-c'},srcFiles,mexVars];
    if~isempty(libFiles)
        libFiles=cellfun(@(x)sprintf('"%s"',x),libFiles,'UniformOutput',false);
    end
    mexVarsLink=[objFiles,mexVars,libFiles,{mexLinkFlags},{'-output'},{outName}];
    if cgxe('Feature','DebugInfo')>0
        createMexDebugCmd(mexVarsCompile,mexVarsLink)
    end
    mex(mexVarsCompile{:});
    try
        mex(mexVarsLink{:});
    catch ME

        if isempty(strfind(ME.message,DAStudio.message('MATLAB:mex:ENOEVER_action')))
            rethrow(ME);
        end
    end

end


function objFiles=getObjFilesFromSrc(srcFiles)
    objFiles=cell(size(srcFiles));
    if isunix
        objExt='.o';
    else
        objExt='.obj';
    end
    for i=1:numel(srcFiles)
        [~,n,~]=fileparts(srcFiles{i});
        objFiles{i}=[n,objExt];
    end
end

function[includePaths,srcFiles,libFiles]=collectDependencies(customCodeSettings)

    targetDir=pwd;

    includePaths={...
    fullfile(matlabroot,'extern','include'),...
    fullfile(matlabroot,'simulink','include'),...
    targetDir,...
    };


    if~isempty(customCodeSettings.userIncludeDirs)
        includePaths=[includePaths,customCodeSettings.userIncludeDirs];
    end

    numSrcs=numel(customCodeSettings.userSources);
    srcFiles=cell(1,numSrcs);
    for i=1:numSrcs
        srcFiles{i}=strtrim(customCodeSettings.userSources{i});
        srcPath=fileparts(srcFiles{i});
        if~isempty(srcPath)
            includePaths{end+1}=srcPath;%#ok<AGROW>
        end
    end
    includePaths=CGXE.Utils.orderedUniquePaths(includePaths);


    numLibs=numel(customCodeSettings.userLibraries);
    libFiles={};
    for i=1:numLibs
        libFiles{i}=strtrim(customCodeSettings.userLibraries{i});%#ok<AGROW>
    end

end


function[flagInfo,mexVarNames]=collectFlags(customCodeSettings,compiler,outName,variadicFcns)
    switch(compiler)
    case['g++','gcc','clang','clang++',cgxeprivate('supportedPCCompilers','mingw')]
        defineToken='-D';
        [flagInfo,mexVarNames]=getUnixAndMingwCompilerInfo(outName,variadicFcns);
        mexVarNames.CompilerVars={};
    case cgxeprivate('supportedPCCompilers','microsoft')
        defineToken='/D';
        [flagInfo,mexVarNames]=getMSVCCompilerInfo(outName,variadicFcns);
        mexVarNames.CompilerVars={'CMDLINE300='};
    otherwise
        error('SLCC Exception: Unhandled compiler "%s".',compiler);
    end

    customDefines=strtrim(customCodeSettings.customUserDefines);
    if~isempty(customDefines)

        defineList=CGXE.CustomCode.extractUserDefines(customDefines);
        customDefines=strjoin(strcat(defineToken,defineList),' ');
        flagInfo.cflags=[flagInfo.cflags,' ',customDefines];
    end

    if~isempty(customCodeSettings.customCompilerFlags)
        flagInfo.cflags=[flagInfo.cflags,' ',customCodeSettings.customCompilerFlags];
    end

    if~isempty(customCodeSettings.customLinkerFlags)
        flagInfo.ldflags=[flagInfo.ldflags,' ',customCodeSettings.customLinkerFlags];
    end

end


function[flagInfo,mexVarName]=getMSVCCompilerInfo(outName,variadicFcns)
    libPathDir=fullfile(matlabroot,'extern','lib',computer('arch'),'microsoft');
    mexVarName.compile='COMPFLAGS';
    mexVarName.link='LINKFLAGS';
    flagInfo.cflags='';
    targetDir=pwd;
    defFile=[outName,'.def'];
    generateDefFile(targetDir,variadicFcns,outName,defFile);
    flagInfo.ldflags=['/IMPLIB:',outName,'.lib /DEF:',defFile,' /LIBPATH:"',libPathDir,'" libmwsl_sfcn_cov_bridge.lib'];
    [flagInfo.preStaticLib,flagInfo.postStaticLib]=deal('');
end


function[flagInfo,mexVarName]=getUnixAndMingwCompilerInfo(outName,variadicFcns)%#ok<INUSD>

    if ispc
        libPathDir=fullfile(matlabroot,'extern','lib',computer('arch'),'mingw64');
        flagInfo.ldflags=['"',fullfile(libPathDir,'libmwsl_sfcn_cov_bridge.lib"')];
    else
        libPathDir=fullfile(matlabroot,'bin',computer('arch'));
        flagInfo.ldflags=['-L"',libPathDir,'" -lmwsl_sfcn_cov_bridge'];
    end
    mexVarName.compile='CFLAGS';
    mexVarName.link='LDFLAGS';

    flagInfo.cflags=' -fvisibility=hidden';

    if ispc
        flagInfo.ldflags=[flagInfo.ldflags,' -Wl,--output-def,',outName,'.def,--out-implib,',outName,'.lib'];
    end

    if ismac
        flagInfo.preStaticLib='-Wl,-all_load';
        flagInfo.postStaticLib='';
    else
        flagInfo.preStaticLib='-Wl,--whole-archive';
        flagInfo.postStaticLib='-Wl,-no-whole-archive';
    end











end

function checkCurrentDir(compiler)
    currentDir=lower(pwd);
    acceptHash=ismember(compiler,cgxeprivate('supportedPCCompilers','mingw'))||...
    isequal(compiler,'lcc');
    if contains(currentDir,'#')&&~acceptHash
        throw(MException(message('Simulink:cgxe:DirContainsPound')));
    end
end


function generateDefFile(targetDir,defFunctions,outName,defFile)
    [file,closeFileOnCleanup]=openFile(targetDir,defFile);%#ok<*ASGLU>
    fprintf(file,'LIBRARY %s.dll\n',outName);
    fprintf(file,'EXPORTS\n');
    for i=1:numel(defFunctions)
        fprintf(file,'    %s\n',defFunctions{i});
    end
end
























function[file,closeFileOnCleanup]=openFile(targetDir,fileName)
    fileName=fullfile(targetDir,fileName);
    file=fopen(fileName,'Wt');
    if file<3
        construct_coder_error([],sprintf('Failed to create file: %s.',fileName),1);
    end
    closeFileOnCleanup=onCleanup(@()fclose(file));
end

function createMexDebugCmd(mexVarsCompile,mexVarsLink)
    debugMATFile='slccMexDebugVars.mat';
    save(debugMATFile,'mexVarsCompile','mexVarsLink');
    debugStr=[...
    'function slccMexDebugCompile',newline,...
    'mxDebug = load(''',debugMATFile,''');',newline,...
    'mex(mxDebug.mexVarsCompile{:});',newline,...
    'mex(mxDebug.mexVarsLink{:});',newline...
    ,'end'];
    fileName='slccMexDebugCompile.m';
    fid=fopen(fileName,'w');

    if fid==-1
        fprintf(1,'Failed to open file ''%s'' for writing.',fileName);
        error('Failed to open file.');
    end
    fprintf(fid,'%s',debugStr);
    fclose(fid);

end