function customCodeMakefile(ccChecksum,customCodeSettings,extraSettings)


    targetDir=pwd;

    origUserSources=customCodeSettings.userSources;
    if~isempty(extraSettings)
        customCodeSettings.userIncludeDirs=[customCodeSettings.userIncludeDirs,extraSettings.userIncludeDirs];
        customCodeSettings.userSources=[customCodeSettings.userSources,extraSettings.userSources];
        if isfield(extraSettings,'defFunctions')
            defFunctions=extraSettings.defFunctions;
        end
    else
        defFunctions={};
    end
    compilerInfo=cgxeprivate('compilerman','get_compiler_info',customCodeSettings.isCpp);
    genCCMakeFile(customCodeSettings,targetDir,ccChecksum,compilerInfo,defFunctions,origUserSources);


    function genCCMakeFile(customCodeSettings,targetDir,ccChecksum,compilerInfo,defFunctions,origUserSources)
        objExt='.obj';
        compiler=compilerInfo.compilerName;
        makefileName=[ccChecksum,'_cclib.mak'];
        outName=[ccChecksum,'_cclib'];
        defFile=[outName,'.def'];
        useGCC=false;

        checkCurrentDir(compiler);
        if ismember(compiler,cgxeprivate('supportedPCCompilers','microsoft'))
            generateDefFile(targetDir,defFunctions,outName,defFile);
            generateBatFileForMSVC(targetDir,compilerInfo,outName);
        elseif ismember(compiler,cgxeprivate('supportedPCCompilers','mingw'))
            generateBatFileForMINGW(targetDir,compilerInfo,outName);
        elseif strcmp(compiler,'lcc')
            generateDefFile(targetDir,defFunctions,outName,defFile);
            generateBatFileForLCC(targetDir,compilerInfo,outName);
        end

        [file,closeFileOnCleanup]=openFile(targetDir,makefileName);

        includePaths={...
        fullfile(matlabroot,'extern','include'),...
        fullfile(matlabroot,'simulink','include'),...
        targetDir,...
        };



        if~isempty(customCodeSettings.userIncludeDirs)
            includePaths=[includePaths,customCodeSettings.userIncludeDirs];
        end

        additionalSrcFiles={};

        isDebugBuild=true;

        DOLLAR='$';
        fprintf(file,'#------------------------ Tool Specifications & Options ----------------------\n');
        fprintf(file,'\n');
        switch(compiler)
        case 'lcc'
            includePaths{end+1}=fullfile(matlabroot,'sys','lcc64','lcc64','include64');
            additionalSrcFiles{end+1}=fullfile(matlabroot,'sys','lcc64','lcc64','mex','lccstub.c');
            [cmdInfo,flagInfo,output,include]=getLCCCompilerInfo(defFile);

        case['g++','gcc','clang','clang++',cgxeprivate('supportedPCCompilers','mingw')]
            useGCC=true;
            objExt='.o';
            [cmdInfo,flagInfo,output,include]=getUnixAndMingwCompilerInfo(outName,customCodeSettings.isCpp,ccChecksum);
            if isDebugBuild
                flagInfo.cflags=[flagInfo.cflags,' -g'];
            end

        case cgxeprivate('supportedPCCompilers','microsoft')
            [cmdInfo,flagInfo,output,include]=getMSVCCompilerInfo(outName);
            if isDebugBuild
                flagInfo.cflags=[flagInfo.cflags,' /Zi'];
                flagInfo.ldflags=[flagInfo.ldflags,' /DEBUG'];
            end

        otherwise
            error('SLCC Exception: Unhandled compiler "%s".',compiler);
        end

        if~isempty(customCodeSettings.customCompilerFlags)
            flagInfo.cflags=sprintf('%s %s',flagInfo.cflags,customCodeSettings.customCompilerFlags);
        end

        if~isempty(customCodeSettings.customLinkerFlags)
            flagInfo.ldflags=sprintf('%s %s',flagInfo.ldflags,customCodeSettings.customLinkerFlags);
        end

        fprintf(file,'COMPILER  =  %s\n',compiler);
        fprintf(file,'\n');
        fprintf(file,'CC        =  "%s"\n',cmdInfo.cc);
        fprintf(file,'LD        =  "%s"\n',cmdInfo.ld);
        fprintf(file,'LIBCMD    =  "%s"\n',cmdInfo.libcmd);
        fprintf(file,'CFLAGS    =  %s\n',flagInfo.cflags);
        fprintf(file,'LDFLAGS   =  %s\n',flagInfo.ldflags);
        fprintf(file,'\n');


        customCodeSettings.userSources=[customCodeSettings.userSources,additionalSrcFiles];

        numSrcs=numel(customCodeSettings.userSources);
        srcFiles=cell(1,numSrcs);
        objFiles=cell(1,numSrcs);
        fprintf(file,'OBJECTS = \\\n');
        for i=1:numSrcs
            srcFiles{i}=strtrim(customCodeSettings.userSources{i});
            [srcPath,srcFile,ext]=fileparts(srcFiles{i});
            if~isempty(srcPath)
                includePaths{end+1}=srcPath;%#ok<AGROW>
            end
            objFiles{i}=change_file_ext([srcFile,ext],objExt);
            fprintf(file,'	   %s \\\n',objFiles{i});
        end
        fprintf(file,'\n');
        numLibs=numel(customCodeSettings.userLibraries);
        fprintf(file,'STATICLIBS = \\\n');
        for i=1:numLibs
            libFiles{i}=strtrim(customCodeSettings.userLibraries{i});
            fprintf(file,'	   "%s" \\\n',escapePaths(libFiles{i}));
        end
        fprintf(file,'\n');
        fprintf(file,'#------------------------------ Include/Lib Path ------------------------------\n');
        fprintf(file,'\n');
        includePaths=CGXE.Utils.orderedUniquePaths(includePaths);
        fprintf(file,'INCLUDE_PATH = \\\n');
        for i=1:numel(includePaths)
            fprintf(file,'     %s"%s" \\\n',include,escapePaths(includePaths{i}));
        end
        fprintf(file,'\n');
        outExt=cgxeprivate('getLibraryExtension','dynamic');
        fprintf(file,'#--------------------------------- Rules --------------------------------------\n');
        fprintf(file,'\n');
        outputFile=[outName,outExt];
        fprintf(file,'%s : %s(MAKEFILE) %s(OBJECTS)\n',outputFile,DOLLAR,DOLLAR);
        fprintf(file,'	%s(LD) %s(LDFLAGS) %s%s %s(OBJECTS) %s %s(STATICLIBS) %s\n',DOLLAR,DOLLAR,output,outputFile,DOLLAR,flagInfo.preStaticLib,DOLLAR,flagInfo.postStaticLib);

        for i=1:numSrcs
            fprintf(file,'%s :	%s\n',objFiles{i},escapePaths(cgxeprivate('cgxeAltPathName',srcFiles{i})));
            if useGCC&&~isempty(origUserSources)&&any(strcmp(origUserSources,srcFiles{i}))
                fprintf(file,'	%s(CC) %s(CFLAGS) -fvisibility=hidden %s(INCLUDE_PATH) "%s"\n',DOLLAR,DOLLAR,DOLLAR,srcFiles{i});
            else
                fprintf(file,'	%s(CC) %s(CFLAGS) %s(INCLUDE_PATH) "%s"\n',DOLLAR,DOLLAR,DOLLAR,srcFiles{i});
            end
        end


        function newFileName=change_file_ext(fileName,extension)
            [pathstr,name]=fileparts(fileName);
            newFileName=fullfile(pathstr,[name,extension]);


            function generateDefFile(targetDir,defFunctions,outName,defFile)
                [file,closeFileOnCleanup]=openFile(targetDir,defFile);%#ok<*ASGLU>
                fprintf(file,'LIBRARY %s.dll\n',outName);
                fprintf(file,'EXPORTS\n');
                for i=1:numel(defFunctions)
                    fprintf(file,'    %s\n',defFunctions{i});
                end


                function generateBatFileForMSVC(targetDir,compilerInfo,outName)
                    [file,closeFileOnCleanup]=openFile(targetDir,[outName,'.bat']);
                    if~isempty(compilerInfo.mexSetEnv)
                        fprintf(file,'%s\n',compilerInfo.mexSetEnv);
                    end
                    fprintf(file,'nmake -f %s.mak\n',outName);


                    function generateBatFileForMINGW(targetDir,compilerInfo,outName)%#ok<INUSL>
                        [file,closeFileOnCleanup]=openFile(targetDir,[outName,'.bat']);
                        if~isempty(compilerInfo.mexSetEnv)
                            fprintf(file,'%s\n',compilerInfo.mexSetEnv);
                        end
                        fprintf(file,'gmake SHELL="cmd" -f %s.mak\n',outName);


                        function generateBatFileForLCC(targetDir,compilerInfo,outName)%#ok<INUSL>
                            [file,closeFileOnCleanup]=openFile(targetDir,[outName,'.bat']);
                            lccMake=fullfile(matlabroot,'sys','lcc64','lcc64','bin','lccmake.exe');
                            fprintf(file,'"%s" -f %s.mak\n',lccMake,outName);


                            function[file,closeFileOnCleanup]=openFile(targetDir,fileName)
                                fileName=fullfile(targetDir,fileName);
                                file=fopen(fileName,'Wt');
                                if file<3
                                    construct_coder_error([],sprintf('Failed to create file: %s.',fileName),1);
                                end
                                closeFileOnCleanup=onCleanup(@()fclose(file));


                                function[cmdInfo,flagInfo,output,include]=getLCCCompilerInfo(defFile)

                                    libMexPath=fullfile(matlabroot,'extern','lib',computer('arch'),'microsoft','libmex.lib');
                                    libMxPath=fullfile(matlabroot,'extern','lib',computer('arch'),'microsoft','libmx.lib');
                                    lccRoot=fullfile(matlabroot,'sys','lcc64','lcc64');
                                    flagInfo.cflags='-dll -noregistrylookup  -c -Zp8 -DLCC_WIN64 -DMATLAB_MEX_FILE -nodeclspec';
                                    flagInfo.ldflags=['-s -dll -entry LibMain ',defFile,' -L"',lccRoot,'\lib64"'];
                                    output='/OUT:';
                                    include='-I';
                                    cmdInfo.cc=fullfile(lccRoot,'bin','lcc64.exe');
                                    cmdInfo.ld=fullfile(lccRoot,'bin','lcclnk64.exe');
                                    cmdInfo.libcmd=fullfile(lccRoot,'bin','lcclib64.exe');
                                    flagInfo.preStaticLib='';

                                    flagInfo.postStaticLib=['"',libMexPath,'" "',libMxPath,'"'];


                                    function[cmdInfo,flagInfo,output,include]=getUnixAndMingwCompilerInfo(outName,isCpp,ccChecksum)

                                        libPathDir=fullfile(matlabroot,'bin',computer('arch'));
                                        output='-o ';
                                        flagInfo.ldflags=['-shared -L"',libPathDir,'" -lmex -lmx'];
                                        compileCmd='gcc';
                                        if isCpp
                                            compileCmd='g++';
                                        end
                                        include='-I';
                                        cmdInfo.cc=compileCmd;
                                        cmdInfo.ld=compileCmd;
                                        cmdInfo.libcmd=compileCmd;
                                        flagInfo.cflags='-c -DMATLAB_MEX_FILE';
                                        if ismac
                                            flagInfo.preStaticLib='-Wl,-all_load';
                                            flagInfo.postStaticLib='';
                                        else
                                            flagInfo.preStaticLib='-Wl,--whole-archive';
                                            flagInfo.postStaticLib='-Wl,-no-whole-archive';
                                        end
                                        if ispc
                                            flagInfo.ldflags=[flagInfo.ldflags,' -Wl,--output-def,',outName,'.def,--out-implib,',outName,'.lib'];
                                        else
                                            flagInfo.cflags=[flagInfo.cflags,' -fPIC'];
                                        end


                                        if isCpp
                                            flagInfo.cflags=[flagInfo.cflags,' -std=c++11'];
                                        end

                                        if ismac
                                            flagInfo.ldflags=[flagInfo.ldflags,' -install_name ','@loader_path/slprj/_slcc/',ccChecksum,'/',outName,'.dylib'];
                                        end


                                        function[cmdInfo,flagInfo,output,include]=getMSVCCompilerInfo(outName)
                                            libPathDir=fullfile(matlabroot,'extern','lib',computer('arch'),'microsoft');
                                            flagInfo.cflags='/c /Zp8 /GR /W3 /EHs /D_CRT_SECURE_NO_DEPRECATE /D_SCL_SECURE_NO_DEPRECATE /DMATLAB_MEX_FILE /D_SECURE_SCL=0 /nologo /MD';
                                            flagInfo.ldflags=['/nologo /DLL /MANIFEST /OPT:NOREF /IMPLIB:',outName,'.lib /DEF:',outName,'.def /LIBPATH:"',libPathDir,'" libmex.lib libmx.lib'];
                                            output='/OUT:';
                                            include='/I';
                                            cmdInfo.cc='cl.exe';
                                            cmdInfo.ld='link.exe';
                                            cmdInfo.libcmd='link.exe';
                                            [flagInfo.preStaticLib,flagInfo.postStaticLib]=deal('');


                                            function pathStr=escapePaths(pathStr)


                                                pathStr=regexprep(pathStr,'#','\\#');


                                                function checkCurrentDir(compiler)
                                                    currentDir=lower(pwd);
                                                    acceptHash=ismember(compiler,cgxeprivate('supportedPCCompilers','mingw'))||...
                                                    isequal(compiler,'lcc');
                                                    if contains(currentDir,'#')&&~acceptHash
                                                        throw(MException(message('Simulink:cgxe:DirContainsPound')));
                                                    end
