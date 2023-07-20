function[toolchainObjectHandle]=fmu_reg_x86_toolchain(compilerVersion)





















    compilationPlatform='win64';

    switch compilationPlatform

    case 'win64'
        versions={'9.0','10.0','11.0','12.0','14.0','15.0',...
        '16.0','17.0'};
        qualifiers=...
        {...
        'Visual C++ 2008',...
        'Visual C++ 2010',...
'Visual C++ 2012'...
        ,'Visual C++ 2013'...
        ,'Visual C++ 2015'...
        ,'Visual C++ 2017'...
        ,'Visual C++ 2019'...
        ,'Visual C++ 2022'...
        };

    otherwise
        error('This approach is only designed to run on 64-bit Windows.');
    end

    name=['MSVC 32 Bit Toolchain for FMU Export'];
    compilerOptionString=' amd64_x86';


    toolchainObjectHandle=coder.make.ToolchainInfo(...
    'Name',name,...
    'BuildArtifact','nmake makefile',...
    'Platform',compilationPlatform,...
    'SupportedVersion',compilerVersion,...
    'Revision','1.0');

    switch(compilerVersion)
    case '8.0'
        compilerPathOperatingSystemEnvironmentVariable='%VS80COMNTOOLS%';
        compilerSetUpOperatingSystemCommandRelativeName='..\..\VC\vcvarsall.bat';
        mexOptsFile='$(MATLAB_ROOT)\bin\$(ARCH)\mexopts\msvc80opts.bat';
        compilerThreadingFlag='/MD';
        matlabSetupCommand=[];
        matlabCleanupCommand=[];
        inlinedCommands='!include <ntwin32.mak>';
        compilerOptionString=' x86';

    case '9.0'
        compilerPathOperatingSystemEnvironmentVariable='%VS90COMNTOOLS%';
        compilerSetUpOperatingSystemCommandRelativeName='..\..\VC\vcvarsall.bat';
        mexOptsFile='$(MATLAB_ROOT)\bin\$(ARCH)\mexopts\msvc90opts.bat';
        compilerThreadingFlag='/MD';
        matlabSetupCommand=[];
        matlabCleanupCommand=[];
        inlinedCommands='!include <ntwin32.mak>';
        compilerOptionString=' x86';

    case '10.0'
        compilerPathOperatingSystemEnvironmentVariable='%VS100COMNTOOLS%';
        compilerSetUpOperatingSystemCommandRelativeName='..\..\VC\vcvarsall.bat';
        mexOptsFile='$(MATLAB_ROOT)\bin\$(ARCH)\mexopts\msvc100opts.bat';
        compilerThreadingFlag='';
        matlabSetupCommand=[];
        matlabCleanupCommand=[];
        inlinedCommands='!include <ntwin32.mak>';
        compilerOptionString=' x86';

    case '11.0'
        compilerPathOperatingSystemEnvironmentVariable='%VS110COMNTOOLS%';
        compilerSetUpOperatingSystemCommandRelativeName='..\..\VC\vcvarsall.bat';
        mexOptsFile='$(MATLAB_ROOT)\bin\$(ARCH)\mexopts\msvc110opts.bat';
        compilerThreadingFlag='';
        matlabSetupCommand=[];
        matlabCleanupCommand=[];
        inlinedCommands='!include $(MATLAB_ROOT)\rtw\c\tools\vcdefs.mak';
        compilerOptionString=' x86';

    case '12.0'
        compilerPathOperatingSystemEnvironmentVariable='%VS120COMNTOOLS%';
        compilerSetUpOperatingSystemCommandRelativeName='..\..\VC\vcvarsall.bat';
        mexOptsFile='$(MATLAB_ROOT)\bin\$(ARCH)\mexopts\msvc2013.xml';
        compilerThreadingFlag='';
        matlabSetupCommand=[];
        matlabCleanupCommand=[];
        inlinedCommands='!include $(MATLAB_ROOT)\rtw\c\tools\vcdefs.mak';


    case '14.0'
        compilerPathOperatingSystemEnvironmentVariable='%VS140COMNTOOLS%';
        compilerSetUpOperatingSystemCommandRelativeName='..\..\VC\vcvarsall.bat';
        mexOptsFile='$(MATLAB_ROOT)\bin\$(ARCH)\mexopts\msvc2015.xml';
        compilerThreadingFlag='';
        matlabSetupCommand=[];
        matlabCleanupCommand=[];
        inlinedCommands='!include $(MATLAB_ROOT)\rtw\c\tools\vcdefs.mak';

    case '15.0'
        compilers=mex.getCompilerConfigurations('C','Installed');
        mscv2017=compilers(ismember({compilers(:).Name}','Microsoft Visual C++ 2017 (C)'));
        if isempty(mscv2017)
            error('An installation of Microsoft Visual C++ 2017 cannot be detected');
        end
        setenv('VS15ROOTDIR',fullfile(mscv2017.Location));
        compilerPathOperatingSystemEnvironmentVariable='%VS15ROOTDIR%';
        compilerSetUpOperatingSystemCommandRelativeName='\VC\Auxiliary\Build\vcvarsall.bat';
        mexOptsFile='$(MATLAB_ROOT)\bin\$(ARCH)\mexopts\msvc2017.xml';
        compilerThreadingFlag='';
        matlabSetupCommand=[];
        matlabCleanupCommand=[];
        inlinedCommands='!include $(MATLAB_ROOT)\rtw\c\tools\vcdefs.mak';
        toolchainObjectHandle.ShellSetup{1}='set "VSCMD_START_DIR=%CD%"';

    case '16.0'
        compilers=mex.getCompilerConfigurations('C','Installed');
        mscv2019=compilers(ismember({compilers(:).Name}','Microsoft Visual C++ 2019 (C)'));
        if isempty(mscv2019)
            error('An installation of Microsoft Visual C++ 2019 cannot be detected');
        end
        setenv('VS16ROOTDIR',fullfile(mscv2019.Location));
        compilerPathOperatingSystemEnvironmentVariable='%VS16ROOTDIR%';
        compilerSetUpOperatingSystemCommandRelativeName='\VC\Auxiliary\Build\vcvarsall.bat';
        mexOptsFile='$(MATLAB_ROOT)\bin\$(ARCH)\mexopts\msvc2019.xml';
        compilerThreadingFlag='';
        matlabSetupCommand=[];
        matlabCleanupCommand=[];
        inlinedCommands='!include $(MATLAB_ROOT)\rtw\c\tools\vcdefs.mak';
        toolchainObjectHandle.ShellSetup{1}='set "VSCMD_START_DIR=%CD%"';

    case '17.0'
        compilers=mex.getCompilerConfigurations('C','Installed');
        mscv2022=compilers(ismember({compilers(:).Name}','Microsoft Visual C++ 2022 (C)'));
        if isempty(mscv2022)
            error('An installation of Microsoft Visual C++ 2022 cannot be detected');
        end
        setenv('VS17ROOTDIR',fullfile(mscv2022.Location));
        compilerPathOperatingSystemEnvironmentVariable='%VS17ROOTDIR%';
        compilerSetUpOperatingSystemCommandRelativeName='\VC\Auxiliary\Build\vcvarsall.bat';
        mexOptsFile='$(MATLAB_ROOT)\bin\$(ARCH)\mexopts\msvc2022.xml';
        compilerThreadingFlag='';
        matlabSetupCommand=[];
        matlabCleanupCommand=[];
        inlinedCommands='!include $(MATLAB_ROOT)\rtw\c\tools\vcdefs.mak';
        toolchainObjectHandle.ShellSetup{1}='set "VSCMD_START_DIR=%CD%"';

    otherwise
        errorMessage=...
        ['Version ',compilerVersion,' is not supported.'];
        error(errorMessage);
    end









    compilerShellSetupOSCommandString=...
    [...
    'call "',...
    compilerPathOperatingSystemEnvironmentVariable,...
    compilerSetUpOperatingSystemCommandRelativeName,...
    '"',...
    compilerOptionString,...
    ];

    toolchainObjectHandle.InlinedCommands=inlinedCommands;
    toolchainObjectHandle.addAttribute('TransformPathsWithSpaces');
    toolchainObjectHandle.addAttribute('RequiresCommandFile');
    toolchainObjectHandle.addAttribute('RequiresBatchFile');


    toolchainObjectHandle.SupportsBuildingMEXFuncs=true;

    toolchainObjectHandle.ShellSetup{end+1}=compilerShellSetupOSCommandString;

    if(true==isempty(matlabSetupCommand))

    else
        toolchainObjectHandle.MATLABSetup{1}=matlabSetupCommand;
    end

    if(true==isempty(matlabCleanupCommand))

    else
        toolchainObjectHandle.MATLABCleanup{1}=matlabCleanupCommand;
    end






    toolchainObjectHandle.addMacro('MEX_OPTS_FILE',mexOptsFile);
    toolchainObjectHandle.addMacro('MDFLAG',compilerThreadingFlag);
    toolchainObjectHandle.addMacro('MW_EXTERNLIB_DIR',['$(MATLAB_ROOT)\extern\lib\',compilationPlatform,'\microsoft']);
    toolchainObjectHandle.addMacro('MW_LIB_DIR',['$(MATLAB_ROOT)\lib\',compilationPlatform]);

    toolchainObjectHandle.addIntrinsicMacros({'NODEBUG','cvarsdll','cvarsmt',...
    'conlibsmt','ldebug','conflags','cflags'});





    cBuildToolHandle=toolchainObjectHandle.getBuildTool('C Compiler');

    cBuildToolHandle.setName('Microsoft Visual C Compiler');
    cBuildToolHandle.setCommand('cl');
    cBuildToolHandle.setPath('');

    cBuildToolHandle.setDirective('IncludeSearchPath','-I');
    cBuildToolHandle.setDirective('PreprocessorDefine','-D');
    cBuildToolHandle.setDirective('OutputFlag','-Fo');
    cBuildToolHandle.setDirective('Debug','-Zi');

    cBuildToolHandle.setFileExtension('Source','.c');
    cBuildToolHandle.setFileExtension('Header','.h');
    cBuildToolHandle.setFileExtension('Object','.obj');

    cBuildToolHandle.setCommandPattern('|>TOOL<| |>TOOL_OPTIONS<| |>OUTPUT_FLAG<||>OUTPUT<|');





    cppBuildToolHandle=toolchainObjectHandle.getBuildTool('C++ Compiler');

    cppBuildToolHandle.setName('Microsoft Visual C++ Compiler');
    cppBuildToolHandle.setCommand('cl');
    cppBuildToolHandle.setPath('');

    cppBuildToolHandle.setDirective('IncludeSearchPath','-I');
    cppBuildToolHandle.setDirective('PreprocessorDefine','-D');
    cppBuildToolHandle.setDirective('OutputFlag','-Fo');
    cppBuildToolHandle.setDirective('Debug','-Zi');

    cppBuildToolHandle.setFileExtension('Source','.cpp');
    cppBuildToolHandle.setFileExtension('Header','.hpp');
    cppBuildToolHandle.setFileExtension('Object','.obj');

    cppBuildToolHandle.setCommandPattern('|>TOOL<| |>TOOL_OPTIONS<| |>OUTPUT_FLAG<||>OUTPUT<|');





    cLinkToolHandle=toolchainObjectHandle.getBuildTool('Linker');

    cLinkToolHandle.setName('Microsoft Visual C Linker');
    cLinkToolHandle.setCommand('link');
    cLinkToolHandle.setPath('');

    cLinkToolHandle.setDirective('Library','-L');
    cLinkToolHandle.setDirective('LibrarySearchPath','-I');
    cLinkToolHandle.setDirective('OutputFlag','-out:');
    cLinkToolHandle.setDirective('Debug','/DEBUG');

    cLinkToolHandle.setFileExtension('Executable','.exe');
    cLinkToolHandle.setFileExtension('Shared Library','.dll');

    cLinkToolHandle.setCommandPattern('|>TOOL<| |>TOOL_OPTIONS<| |>OUTPUT_FLAG<||>OUTPUT<|');





    cppLinkToolHandle=toolchainObjectHandle.getBuildTool('C++ Linker');

    cppLinkToolHandle.setName('Microsoft Visual C++ Linker');
    cppLinkToolHandle.setCommand('link');
    cppLinkToolHandle.setPath('');

    cppLinkToolHandle.setDirective('Library','-L');
    cppLinkToolHandle.setDirective('LibrarySearchPath','-I');
    cppLinkToolHandle.setDirective('OutputFlag','-out:');
    cppLinkToolHandle.setDirective('Debug','/DEBUG');

    cppLinkToolHandle.setFileExtension('Executable','.exe');
    cppLinkToolHandle.setFileExtension('Shared Library','.dll');

    cppLinkToolHandle.setCommandPattern('|>TOOL<| |>TOOL_OPTIONS<| |>OUTPUT_FLAG<||>OUTPUT<|');





    archiverToolHandle=toolchainObjectHandle.getBuildTool('Archiver');

    archiverToolHandle.setName('Microsoft Visual C/C++ Archiver');
    archiverToolHandle.setCommand('lib');
    archiverToolHandle.setPath('');

    archiverToolHandle.setDirective('OutputFlag','-out:');

    archiverToolHandle.setFileExtension('Static Library','.lib');

    archiverToolHandle.setCommandPattern('|>TOOL<| |>TOOL_OPTIONS<| |>OUTPUT_FLAG<||>OUTPUT<|');





    toolchainObjectHandle.setBuilderApplication(compilationPlatform);











    optimsOffOpts={'/Od /Oy-'};






    optimsOnOpts={'/O2 /Oy-'};




    toolchainObjectHandle.addMacro('CPU','X86');




    cvarsflag='$(cvarsmt)';
    toolchainObjectHandle.addMacro('CVARSFLAG',cvarsflag);

    CFLAGS_ADDITIONAL='-D_CRT_SECURE_NO_WARNINGS';
    CPPFLAGS_ADDITIONAL='-EHs -D_CRT_SECURE_NO_WARNINGS';
    LIBS_TOOLCHAIN='$(conlibs)';
    toolchainObjectHandle.addMacro('CFLAGS_ADDITIONAL',CFLAGS_ADDITIONAL);
    toolchainObjectHandle.addMacro('CPPFLAGS_ADDITIONAL',CPPFLAGS_ADDITIONAL);
    toolchainObjectHandle.addMacro('LIBS_TOOLCHAIN',LIBS_TOOLCHAIN);

    cCompilerOpts='$(cflags) $(CVARSFLAG) $(CFLAGS_ADDITIONAL)';
    cppCompilerOpts='/TP $(cflags) $(CVARSFLAG) $(CPPFLAGS_ADDITIONAL)';
    linkerOpts={'/MACHINE:X86 $(ldebug) $(conflags) $(LIBS_TOOLCHAIN)'};
    sharedLinkerOpts=horzcat(linkerOpts,'-dll -def:$(DEF_FILE)');
    archiverOpts={'/nologo'};


    debugFlag.CCompiler=getDebugFlag('C Compiler');
    debugFlag.CppCompiler=getDebugFlag('C++ Compiler');
    debugFlag.Linker=getDebugFlag('Linker');
    debugFlag.Archiver=getDebugFlag('Archiver');

    buildConfigurationObject=toolchainObjectHandle.getBuildConfiguration('Faster Builds');
    buildConfigurationObject.setOption('C Compiler',horzcat(cCompilerOpts,optimsOffOpts));
    buildConfigurationObject.setOption('C++ Compiler',horzcat(cppCompilerOpts,optimsOffOpts));
    buildConfigurationObject.setOption('Linker',linkerOpts);
    buildConfigurationObject.setOption('C++ Linker',linkerOpts);
    buildConfigurationObject.setOption('Shared Library Linker',sharedLinkerOpts);
    buildConfigurationObject.setOption('C++ Shared Library Linker',sharedLinkerOpts);
    buildConfigurationObject.setOption('Archiver',archiverOpts);

    buildConfigurationObject=toolchainObjectHandle.getBuildConfiguration('Faster Runs');
    buildConfigurationObject.setOption('C Compiler',horzcat(cCompilerOpts,optimsOnOpts));
    buildConfigurationObject.setOption('C++ Compiler',horzcat(cppCompilerOpts,optimsOnOpts));
    buildConfigurationObject.setOption('Linker',linkerOpts);
    buildConfigurationObject.setOption('C++ Linker',linkerOpts);
    buildConfigurationObject.setOption('Shared Library Linker',sharedLinkerOpts);
    buildConfigurationObject.setOption('C++ Shared Library Linker',sharedLinkerOpts);
    buildConfigurationObject.setOption('Archiver',archiverOpts);

    buildConfigurationObject=toolchainObjectHandle.getBuildConfiguration('Debug');
    buildConfigurationObject.setOption('C Compiler',horzcat(cCompilerOpts,optimsOffOpts,debugFlag.CCompiler));
    buildConfigurationObject.setOption('C++ Compiler',horzcat(cppCompilerOpts,optimsOffOpts,debugFlag.CppCompiler));
    buildConfigurationObject.setOption('Linker',horzcat(linkerOpts,debugFlag.Linker));
    buildConfigurationObject.setOption('C++ Linker',horzcat(linkerOpts,debugFlag.Linker));
    buildConfigurationObject.setOption('Shared Library Linker',horzcat(sharedLinkerOpts,debugFlag.Linker));
    buildConfigurationObject.setOption('C++ Shared Library Linker',horzcat(sharedLinkerOpts,debugFlag.Linker));
    buildConfigurationObject.setOption('Archiver',horzcat(archiverOpts,debugFlag.Archiver));

    toolchainObjectHandle.setBuildConfigurationOption('all','Download','');
    toolchainObjectHandle.setBuildConfigurationOption('all','Execute','');
    toolchainObjectHandle.setBuildConfigurationOption('all','Make Tool','-f $(MAKEFILE)');





    function[flag]=getDebugFlag(toolkey)
        flag=toolchainObjectHandle.getBuildTool(toolkey).Directives.getValue('Debug').getRef();
        return;
    end

    return;

end
