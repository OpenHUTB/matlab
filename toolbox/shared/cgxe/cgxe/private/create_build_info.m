function[buildInfo,auxInfo]=create_build_info(fileNameInfo,modelname,targetInfo,auxInfo)









    buildInfo=RTW.BuildInfo(get_param(modelname,'Handle'));
    linkFlags='';
    compilerName='.';
    compileFlags='';
    compilerSpecificSrc={};
    includePaths={};
    includePathsGroup={};

    libFiles={};
    libPaths={};
    libGroup={};

    targetName='cgxe';

    codingOpenMP=false;
    if isfield(auxInfo,'codingOpenMP')
        codingOpenMP=auxInfo.codingOpenMP;
    end

    simdFlag='';
    if isfield(auxInfo,'codingSIMD')
        if strcmpi(auxInfo.codingSIMD,'AVX2')
            simdFlag='AVX2';
        elseif strcmpi(auxInfo.codingSIMD,'AVX512')
            simdFlag='AVX512';
            if isunix||targetInfo.codingMinGWMakefile
                simdFlag=[simdFlag,'f'];
            end
        end
    end

    codingDebugBuild=cgxe('Feature','debugBuilds');
    codingFasterRun=CGXE.Utils.isSimOptimizationsOn(modelname);
    if isunix
        compileFlags=[compileFlags,' -w'];
        if codingDebugBuild
            compileFlags=[compileFlags,' -g'];
        end
        if codingOpenMP&&~ismac
            compileFlags=[compileFlags,' -fopenmp -fPIC'];
        end

        if~isempty(simdFlag)
            compileFlags=[compileFlags,' -m',lower(simdFlag)];
        end

        if ismac
            linkFlags='-Wl,-rpath,@loader_path ';
        end
        if codingFasterRun
            compileFlags=[compileFlags,' -O2'];
        end
        if ismac
            linkFlags='-Wl,-rpath,@loader_path ';
        end
    elseif targetInfo.codingMSVCMakefile
        compileFlags='/c /Zp8 /GR /w /EHs /D_CRT_SECURE_NO_DEPRECATE /D_SCL_SECURE_NO_DEPRECATE /D_SECURE_SCL=0 /DMX_COMPAT_64 /DMATLAB_MEXCMD_RELEASE=R2018a /DMATLAB_MEX_FILE /nologo /MD';
        if codingDebugBuild
            compileFlags=['/Zi ',compileFlags];
        end
        if codingFasterRun
            compileFlags=['/O2 ',compileFlags];
        end
        if~isempty(simdFlag)
            compileFlags=[compileFlags,' -arch:',simdFlag];
        end
        linkFlags='/nologo /dll /MANIFEST /OPT:NOREF /export:mexFunction /export:mexfilerequiredapiversion ';
        if codingOpenMP
            compileFlags=[compileFlags,' /openmp'];
            linkFlags=[linkFlags,' /nodefaultlib:vcomp'];
        end
        if codingDebugBuild
            linkFlags=[linkFlags,' /DEBUG'];
        end
        compilerName='microsoft';
    elseif targetInfo.codingMinGWMakefile
        compilerName='mingw64';
        compileFlags=[compileFlags,' -w'];
        if codingFasterRun
            compileFlags=[compileFlags,' -O2'];
        end

        if codingOpenMP
            compileFlags=[compileFlags,' -fopenmp'];
            linkFlags=[linkFlags,' -fopenmp'];
        end

        if~isempty(simdFlag)
            compileFlags=[compileFlags,' -m',lower(simdFlag)];
        end

    elseif targetInfo.codingLccMakefile
        if(strcmp(computer,'PCWIN64'))
            lccRoot=fullfile(matlabroot,'sys','lcc64','lcc64');
            compilerName='microsoft';

            compileFlags='-w -dll -noregistrylookup  -c -Zp8 -DLCC_WIN64 -DMATLAB_MEX_FILE -nodeclspec';
            if~CGXE.Utils.isInterleavedComplex
                compileFlags=[compileFlags,' -DMX_COMPAT_32'];
            end
            linkFlags=['-s -dll',' -L"',lccRoot,'\lib64" -entry LibMain -map sfun.map'];

            defFileName=[modelname,'_',targetName,'.def'];
            mexFileName=[modelname,'_',targetName,'.',mexext];

            str=['LIBRARY ',mexFileName,10,...
            'EXPORTS',10,...
            'mexFunction',10,...
            'mexfilerequiredapiversion'];
            sfprivate('str2file',str,fullfile(fileNameInfo.targetDirName,defFileName));
            includePaths{end+1}=fullfile(lccRoot,'include64');
        else
            lccRoot=fullfile(matlabroot,'sys','lcc');
            compilerName='lcc';

            compileFlags='-w -c -Zp8 -DMATLAB_MEX_FILE -noregistrylookup';
            linkFlags=['-s -dll',' -L"',lccRoot,'\lib"'];

            defFileName=[lccRoot,'\mex\lccdef.def'];
            includePaths{end+1}=fullfile(lccRoot,'include');

        end

        includePathsGroup{end+1}='LCC';
        compilerSpecificSrc=[lccRoot,'\mex\lccstub.c'];
        [libPaths{end+1},libFiles{end+1},extLib]=fileparts(defFileName);
        libFiles{end}=[libFiles{end},extLib];
        libGroup{end+1}='LCC_DEF';
    end



    compileFlags=[compileFlags,' ',fileNameInfo.customCompilerFlags,' ',getFixedCustomDefines(fileNameInfo.customUserDefines,targetInfo.codingMSVCMakefile)];
    linkFlags=[linkFlags,' ',fileNameInfo.customLinkerFlags];


    buildInfo.addCompileFlags(compileFlags,'OPTS')

    buildInfo.addLinkFlags(linkFlags,'LDFLAGS_CGXE');

    MLROOT=buildInfo.Settings.Matlabroot;







    includeInfo=[...
    {fullfile(MLROOT,'extern','include');'ML_INCLUDES'},...
    {fullfile(MLROOT,'simulink','include');'SL_INCLUDES'},...
    {fullfile(MLROOT,'rtw','c','src');'SL_INCLUDES'},...
    {fileNameInfo.targetDirName;'CGXE_INCLUDES'},...
    [fileNameInfo.userIncludeDirs;repmat({'USER_INCLUDES'},size(fileNameInfo.userIncludeDirs))]...
    ];

    includePathsGroup=[includePathsGroup,includeInfo(2,:)];
    includePaths=[includePaths,includeInfo(1,:)];

    includePathsGroup(cellfun(@isempty,includePaths))=[];
    includePaths(cellfun(@isempty,includePaths))=[];

    if~isempty(includePaths)
        buildInfo.addIncludePaths(includePaths,includePathsGroup);
    end

    if strcmp(get_param(bdroot,'HasImageDataType'),'on')
        imageIncludePath=fullfile(MLROOT,'extern','include','images');
        buildInfo.addIncludePaths(imageIncludePath,'ML_INCLUDES');
    end


    modelCCInfo={};

    mainModelHandle=get_param(modelname,'Handle');
    checksumSet={};

    libraryCCDeps=slcc('getCachedCustomCodeDependencies',mainModelHandle);

    for i=1:numel(libraryCCDeps)
        checkSum=libraryCCDeps(i).SettingsChecksum;
        assert(~isempty(checkSum),'Empty custom code checksum in cached custom code dependencies!');
        ccInfo=slcc('getCachedCustomCodeInfo',checkSum);
        modelCCInfo{end+1}=struct('checkSum',checkSum,...
        'ccInfo',ccInfo,...
        'isOOP',libraryCCDeps(i).IsOutOfProcessExecution);%#ok<AGROW>
        checksumSet{end+1}=checkSum;%#ok<AGROW>
    end

    [libIncludePaths,ccFileGroup,libHeaderFiles]=addCustomCodeUserIncludeDirsAndHeaders(modelCCInfo);


    buildInfo.addIncludePaths(libIncludePaths,ccFileGroup);




    auxInfo=addIncludesToAuxInfo(auxInfo,libHeaderFiles);



    srcFiles=cell(1,fileNameInfo.numModules+1);
    srcFilesGroup=cell(size(srcFiles));
    srcFiles(1)={fileNameInfo.modelSourceFile};
    srcFilesGroup(1)={'MODEL_SRC'};
    srcFiles(2:end)=fileNameInfo.moduleSourceFiles;
    srcFilesGroup(2:end)={'MODULE_SRCS'};

    srcFiles{end+1}=fileNameInfo.modelRegistryFile;
    srcFilesGroup{end+1}='MODEL_REG';

    if strcmp(get_param(bdroot,'HasImageDataType'),'on')
        srcFiles{end+1}='image_type.cpp';
        srcFilesGroup{end+1}='MODEL_SRC';
    end

    srcDirs=repmat({fileNameInfo.targetDirName},size(srcFiles));
    if~isempty(compilerSpecificSrc)
        [pathStr,nameStr,ext]=fileparts(compilerSpecificSrc);
        srcDirs=[{pathStr},srcDirs];
        srcFiles=[{[nameStr,ext]},srcFiles];
        srcFilesGroup=[{'COMPILER_SRC'},srcFilesGroup];
    end

    if targetInfo.codingMSVCMakefile||targetInfo.codingLccMakefile


        pathStr=fullfile(matlabroot,'extern','version');
        mexVersionFile='c_mexapi_version.c';
        srcDirs=[{pathStr},srcDirs];
        srcFiles=[{mexVersionFile},srcFiles];
        srcFilesGroup=[{'COMPILER_SRC'},srcFilesGroup];
    end

    buildInfo.addSourceFiles(srcFiles,srcDirs,srcFilesGroup);

    if~fileNameInfo.hasSLCCCustomCode

        for i=1:length(fileNameInfo.userSources)
            [~,~,extStr]=fileparts(fileNameInfo.userSources{i});
            extStr=lower(extStr);
            if~(strcmp(extStr,'.c')||strcmp(extStr,'.cpp'))
                error('CGXE:UnexpectedError',['Unrecognized file extension: ',extStr]);
            end
        end
        buildInfo.addSourceFiles(fileNameInfo.userSources,'','USER_SRCS');
    end

    buildInfo.addSourcePaths(fileNameInfo.targetDirName);


    priority=100;
    precompiled=false;
    linkonly=false;

    for i=1:numel(fileNameInfo.customCodeDLL)
        [ccDLLPath,ccDLLFile,ccDLLExt]=fileparts(fileNameInfo.customCodeDLL{i});
        libFiles{end+1}=[ccDLLFile,ccDLLExt];
        libPaths{end+1}=ccDLLPath;
        libGroup(end+1)={'CCLIB'};
    end

    if~fileNameInfo.hasSLCCCustomCode&&~isempty(fileNameInfo.userLibraries)

        for i=1:length(fileNameInfo.userLibraries)
            [libPaths{end+1},libFiles{end+1},extLib]=fileparts(fileNameInfo.userLibraries{i});%#ok<AGROW>
            libFiles{end}=[libFiles{end},extLib];
            libGroup{end+1}='USER_LIBS';%#ok<AGROW>
        end
    end

    if ispc

        libMexDir=fullfile(matlabroot,'extern','lib',computer('arch'),compilerName);
        libMATLABDir=fullfile(fileNameInfo.matlabRoot,'lib',computer('arch'));
        binMATLABDir=fullfile(matlabroot,'bin',computer('arch'));

        numExtLibs=12;
        libFiles(end+1:end+numExtLibs)={'libmx.lib','libmex.lib','libmat.lib','libfixedpoint.lib',...
        'libut.lib','libmwmathutil.lib','libemlrt.lib','libmwcgxert.lib',...
        'libmwcgxeooprt.lib','libmwslexec_simbridge.lib','libmwslccrt.lib','libmwstringutil.lib'};
        libPaths(end+1:end+numExtLibs)={libMexDir};
        libGroup(end+1:end+numExtLibs)={'TMWLIB'};

        if targetInfo.codingMinGWMakefile
            libFiles{end+1}='libmwipp';
            libPaths{end+1}=fullfile(matlabroot,'bin',computer('arch'));
            libGroup{end+1}='TMWLIB';
        else
            libFiles{end+1}='libmwipp.lib';
            libPaths{end+1}=libMATLABDir;
            libGroup(end+1)={'TMWLIB'};
        end

        if slfeature('CGXECoverageEnabled')
            libFiles{end+1}='libcovrt.lib';
            libPaths{end+1}=libMexDir;
            libGroup{end+1}='TMWLIB';
        end


        libFiles{end+1}='libmwsl_sfcn_cov_bridge.lib';
        libPaths{end+1}=libMexDir;
        libGroup{end+1}='TMWLIB';

        if strcmp(get_param(bdroot,'HasImageDataType'),'on')
            libFiles{end+1}='imagesdatatypesimage.lib';
            libPaths{end+1}=libMexDir;
            libGroup{end+1}='TMWLIB';
        end

        if targetInfo.codingMSVCMakefile&&codingOpenMP

            libFiles{end+1}='libiomp5md.lib';
            libPaths{end+1}=binMATLABDir;
            libGroup{end+1}='TMWLIB';
        end

        dspHalideLibName='libmwdsp_halidesim.dll';
        if exist(fullfile(binMATLABDir,dspHalideLibName),'file')
            libFiles{end+1}='libmwdsp_halidesim.lib';
            libPaths{end+1}=libMexDir;
            libGroup(end+1)={'TMWLIB'};
        end
        dspHalideLibName='dspcgsim.dll';
        if exist(fullfile(binMATLABDir,dspHalideLibName),'file')
            libFiles{end+1}='dspcgsim.lib';
            libPaths{end+1}=libMexDir;
            libGroup(end+1)={'TMWLIB'};
        end
        buildInfo.addLinkObjects(libFiles,libPaths,priority,precompiled,linkonly,libGroup);

    elseif isunix
        MLSysLibPath=fullfile(matlabroot,'bin',computer('arch'));
        arch=lower(computer);


        libFiles(end+1:end+9)={'fixedpoint','ut','emlrt','mwslexec_simbridge','mwcgxert',...
        'mwcgxeooprt','mwmathutil','mwslccrt','mwstringutil'};
        libPaths(end+1:end+9)={MLSysLibPath};
        libGroup(end+1:end+9)={'TMWLIB'};


        libFiles{end+1}='mwipp';
        libPaths{end+1}=fullfile(matlabroot,'bin',arch);
        libGroup{end+1}='TMWLIB';

        if slfeature('CGXECoverageEnabled')
            libFiles{end+1}='covrt';
            libPaths{end+1}=MLSysLibPath;
            libGroup{end+1}='TMWLIB';
        end


        libFiles{end+1}='mwsl_sfcn_cov_bridge';
        libPaths{end+1}=MLSysLibPath;
        libGroup{end+1}='TMWLIB';

        if strcmp(get_param(bdroot,'HasImageDataType'),'on')
            libFiles{end+1}='mwimagesdatatypesimage';
            libPaths{end+1}=MLSysLibPath;
            libGroup{end+1}='TMWLIB';
        end

        if codingOpenMP&&~ismac

            libFiles{end+1}='iomp5';
            libPaths{end+1}=fullfile(matlabroot,'sys','os',arch);
            libGroup{end+1}='PARLIB';
        end

        if ismac
            dspHalideLibName='libmwdsp_halidesim.dylib';
        else
            dspHalideLibName='libmwdsp_halidesim.so';
        end
        if exist(fullfile(MLSysLibPath,dspHalideLibName),"file")
            libFiles{end+1}='mwdsp_halidesim';
            libPaths{end+1}=MLSysLibPath;
            libGroup{end+1}='TMWLIB';
        end

        if ismac
            dspHalideLibName='libmwdspcgsim.dylib';
        else
            dspHalideLibName='libmwdspcgsim.so';
        end
        if exist(fullfile(MLSysLibPath,dspHalideLibName),"file")
            libFiles{end+1}='mwdspcgsim';
            libPaths{end+1}=MLSysLibPath;
            libGroup{end+1}='TMWLIB';
        end
        buildInfo.addLinkObjects(libFiles,libPaths,priority,precompiled,linkonly,libGroup);
    end
    addAuxInfoToBuildInfo(buildInfo,auxInfo);


    function addAuxInfoToBuildInfo(buildInfo,auxInfo)
        if isempty(auxInfo)
            return;
        end

        if isfield(auxInfo,'sourceFiles')

            fileNames={auxInfo.sourceFiles.FileName};
            filePaths={auxInfo.sourceFiles.FilePath};
            fileGroups={auxInfo.sourceFiles.Group};
            buildInfo.addSourceFiles(fileNames,filePaths,fileGroups);
        end
        if isfield(auxInfo,'includeFiles')
            fileNames={auxInfo.includeFiles.FileName};
            filePaths={auxInfo.includeFiles.FilePath};
            fileGroups={auxInfo.includeFiles.Group};
            buildInfo.addIncludeFiles(fileNames,filePaths,fileGroups);
        end
        if isfield(auxInfo,'includePaths')
            filePaths={auxInfo.includePaths.FilePath};
            fileGroups={auxInfo.includePaths.Group};
            buildInfo.addIncludePaths(filePaths,fileGroups);
        end
        if isfield(auxInfo,'linkObjects')











            [fileNames,uniqueidx]=unique({auxInfo.linkObjects.FileName},'stable');
            Paths={auxInfo.linkObjects.FilePath};
            filePaths=Paths(uniqueidx);
            Groups={auxInfo.linkObjects.Group};
            fileGroups=Groups(uniqueidx);


            priority=repmat(1000,1,numel(fileNames));
            precompiled=true(1,numel(fileNames));
            linkonly=true(1,numel(fileNames));
            buildInfo.addLinkObjects(fileNames,filePaths,priority,precompiled,...
            linkonly,fileGroups);
        end
        if isfield(auxInfo,'linkFlags')
            for i=1:numel(auxInfo.linkFlags)
                lf=auxInfo.linkFlags(i);
                oldLinkFlags=buildInfo.getLinkFlags(lf.Group);
                indices=strfind(oldLinkFlags,lf.Flags);
                if~any([indices{:}])
                    buildInfo.addLinkFlags(lf.Flags,lf.Group);
                end
            end
        end

        function customDefines=getFixedCustomDefines(customDefines,isMSVC)
            customDefines=strtrim(customDefines);
            if isempty(customDefines)
                return;
            end
            if isMSVC
                defineToken='/D';
            else
                defineToken='-D';
            end

            defineList=CGXE.CustomCode.extractUserDefines(customDefines);
            customDefines=strjoin(strcat(defineToken,defineList),' ');

            function[libIncludePaths,ccFileGroup,libHeaderFiles]=addCustomCodeUserIncludeDirsAndHeaders(modelCCInfoStructs)
                libHeaderFiles={};
                libIncludePaths={};
                proj_root_dir=get_cgxe_proj_root();

                libIncludePaths{end+1}=proj_root_dir;
                for i=1:length(modelCCInfoStructs)
                    modelCCInfo=modelCCInfoStructs{i};
                    checkSum=modelCCInfo.checkSum;
                    if~isempty(modelCCInfo.ccInfo.customCodeSettings.prebuiltCCDependency)
                        assert(isfile(modelCCInfo.ccInfo.customCodeSettings.prebuiltCCDependency.interfaceHeader),...
                        'Custom code interface header must exist.');

                        ccLibPath='';
                        interfaceHeaderFile=modelCCInfo.ccInfo.customCodeSettings.prebuiltCCDependency.interfaceHeader;
                    elseif modelCCInfo.isOOP
                        ccLibPath={proj_root_dir,'slprj','_sloop',checkSum};
                        interfaceHeaderFile=[checkSum,'_interface.h'];
                    else
                        ccLibPath={proj_root_dir,'slprj','_slcc',checkSum};
                        interfaceHeaderFile=['slcc_interface_',checkSum,'.h'];
                    end

                    if~isempty(ccLibPath)
                        libIncludePath=fullfile(ccLibPath{:});
                        libIncludePaths{end+1}=libIncludePath;%#ok<AGROW>
                    end


                    libHeaderFiles{end+1}=interfaceHeaderFile;%#ok<AGROW>


                    userSpecifiedIncludePaths=modelCCInfo.ccInfo.customCodeSettings.userIncludeDirs;
                    for pathIdx=1:length(userSpecifiedIncludePaths)
                        libIncludePaths{end+1}=userSpecifiedIncludePaths{pathIdx};%#ok<AGROW>
                    end
                end
                libIncludePaths=unique(libIncludePaths);
                ccFileGroup=repmat({'CCLIB_INCLUDES'},length(libIncludePaths),1);











