function[tc,results]=Simulator_Toolchains



    funcHandle=str2func('getToolchainInfoFor');

    toolchain.Platforms={'glnxa64'};
    toolchain.Versions={'1.0'};
    toolchain.Artifacts={'gmake'};
    toolchain.FuncHandle=funcHandle;
    tc_linux=cell(1,2);
    results_linux=cell(1,2);
    tcname_cnt=1;
    for tcnameIdx={'Mentor Graphics QuestaSim/Modelsim (64-bit Linux)','Cadence Xcelium (64-bit Linux)'}
        toolchain.ExtraFuncArgs=tcnameIdx;
        [tc_linux{tcname_cnt},results_linux{tcname_cnt}]=coder.make.internal.generateToolchainInfoObjects(mfilename,toolchain,nargout);
        tcname_cnt=tcname_cnt+1;
    end

    toolchain.Platforms={'win32'};
    toolchain.Versions={'1.0'};
    toolchain.Artifacts={'nmake'};
    toolchain.FuncHandle=funcHandle;
    toolchain.ExtraFuncArgs={'Mentor Graphics QuestaSim/Modelsim (32-bit Windows)'};
    [tc_win32,results_win32]=coder.make.internal.generateToolchainInfoObjects(mfilename,toolchain);

    toolchain.Platforms={'win64'};
    toolchain.Versions={'1.0'};
    toolchain.Artifacts={'nmake'};
    toolchain.FuncHandle=funcHandle;
    toolchain.ExtraFuncArgs={'Mentor Graphics QuestaSim/Modelsim (64-bit Windows)'};
    [tc_win64,results_win64]=coder.make.internal.generateToolchainInfoObjects(mfilename,toolchain);

    tc=horzcat(tc_win64,tc_win32,tc_linux{1},tc_linux{2});
    results=horzcat(results_win64,results_win32,results_linux{1},results_linux{2});
end




function tc=getToolchainInfoFor(platform,version,artifact,varargin)

    if nargin==4

        ToolchainName=varargin{1};
    end

    switch platform
    case 'win32'
        tc=coder.make.ToolchainInfo(...
        'Name',ToolchainName,...
        'BuildArtifact','nmake makefile',...
        'Platform',platform,...
        'SupportedVersion',version,...
        'Revision','1.0');
    case 'win64'
        tc=coder.make.ToolchainInfo(...
        'Name',ToolchainName,...
        'BuildArtifact','nmake makefile',...
        'Platform',platform,...
        'SupportedVersion',version,...
        'Revision','1.0');
    case 'glnxa64'
        tc=coder.make.ToolchainInfo(...
        'Name',ToolchainName,...
        'BuildArtifact','gmake makefile',...
        'Platform',platform,...
        'SupportedVersion',version,...
        'Revision','1.0');
    end











    tc.addAttribute('TransformPathsWithSpaces');
    tc.BuilderApplication.setCommand('echo "### Successfully generated all binary outputs."');
    tc.BuilderApplication.setPath('');
    tc.BuilderApplication.setFileExtension('Makefile','.do')
    tc.BuilderApplication.CustomValidation='HDL_Simulators_Toolchain_Validator';
    tc.BuilderApplication.setName(ToolchainName);

    tc.BuilderApplication.setDirective('IncludeFile','');
    tc.BuilderApplication.setDirective('LineContinuation','');
    tc.BuilderApplication.setDirective('FileSeparator','');
    tc.BuilderApplication.setDirective('Comment','#');
    tc.BuilderApplication.setDirective('DeleteCommand','');
    tc.BuilderApplication.setDirective('DisplayCommand','');
    tc.BuilderApplication.setDirective('MoveCommand','');
    tc.BuilderApplication.setDirective('RunScriptCommand','');
    tc.BuilderApplication.setDirective('ReferencePattern','');

    tc.setBuildConfigurationOption('all','Make Tool','$(MAKEFILE)')




    tool=tc.getBuildTool('C Compiler');

    tool.setName([ToolchainName,' C Compiler']);
    tool.setCommand('gcc');
    tool.setPath('');

    tool.setDirective('IncludeSearchPath','-ccflags');
    tool.setDirective('PreprocessorDefine','');
    tool.setDirective('OutputFlag','');
    tool.setDirective('Debug','');

    tool.setFileExtension('Source','.c');
    tool.setFileExtension('Header','.h');
    tool.setFileExtension('Object','.o');
    tool.CustomValidation='HDL_Simulators_Toolchain_Validator';





    tool=tc.getBuildTool('C++ Compiler');

    tool.setName([ToolchainName,' GNU C++ Compiler']);
    tool.setCommand('g++');
    tool.setPath('');

    tool.setDirective('IncludeSearchPath','-I');
    tool.setDirective('PreprocessorDefine','-D');
    tool.setDirective('OutputFlag','-o');
    tool.setDirective('Debug','-g');

    tool.setFileExtension('Source','.cpp');
    tool.setFileExtension('Header','.hpp');
    tool.setFileExtension('Object','.o');
    tool.CustomValidation='HDL_Simulators_Toolchain_Validator';




    tool=tc.getBuildTool('Archiver');

    tool.setName([ToolchainName,' GNU Archiver']);
    tool.setCommand('ar');
    tool.setPath('');

    tool.setDirective('OutputFlag','');

    tool.setFileExtension('Static Library','.a');
    tool.CustomValidation='HDL_Simulators_Toolchain_Validator';




    tool=tc.getBuildTool('Linker');

    tool.setName([ToolchainName,' Linker']);
    tool.setCommand('gcc');
    tool.setPath('');

    tool.setDirective('Library','');
    tool.setDirective('LibrarySearchPath','');
    tool.setDirective('OutputFlag','');
    tool.setDirective('Debug','');
    tool.addDirective('StartLibraryGroup',{'-Wl,--start-group'});
    tool.addDirective('EndLibraryGroup',{'-Wl,--end-group'});

    tool.setFileExtension('Shared Library','.so');
    tool.CustomValidation='HDL_Simulators_Toolchain_Validator';




    tool=tc.getBuildTool('C++ Linker');

    tool.setName([ToolchainName,' GNU C++ Linker']);
    tool.setCommand('g++');
    tool.setPath('');

    tool.setDirective('Library','-l');
    tool.setDirective('LibrarySearchPath','-L');
    tool.setDirective('OutputFlag','-o');
    tool.setDirective('Debug','-g');
    tool.addDirective('StartLibraryGroup',{'-Wl,--start-group'});
    tool.addDirective('EndLibraryGroup',{'-Wl,--end-group'});


    tool.setFileExtension('Shared Library','.so');

    tool.CustomValidation='HDL_Simulators_Toolchain_Validator';

























































































    tc.setBuildConfigurationOption('all','Download','');
    tc.setBuildConfigurationOption('all','Execute','');
    tc.setBuildConfigurationOption('all','Make Tool',' $(MAKEFILE)');









end






