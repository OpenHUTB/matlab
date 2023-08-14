function addStandardInfo(buildInfo, MdlRefBuildArgs, ...
                         numst, ncstates, ...
                         solverMode, lCodeFormat, lSystemTargetFile, ...
                         mem_alloc, modelHasSFcnsWithNoSourceCode, ...
                         derivedShrlibTgt, isERTSfunction, ...
                         isHostBased, isLccCompiler, lRSIMWithSlSolver, ...
                         mexToolChainName, lBuildIsTMFBased, ...
                         relativePathToAnchor, hasDTBlks)
%ADDSTANDARDINFO - adds standard build info to the Build Info
    
%   Copyright 2002-2022 The MathWorks, Inc.
%     

standardGroup = coder.make.internal.BuildInfoGroup.BiStandardGroup;
legacyGroup   = coder.make.internal.BuildInfoGroup.BiLegacyGroup;

srcFiles      = {};
srcFilePaths  = {};
srcFileGroups = 'Legacy';

noMdlRefFiles      = {};
noMdlRefFilePaths  = {};
noMdlRefFileGroups = {};

targetType   = MdlRefBuildArgs.ModelReferenceTargetType;
lMLSysLibPath = coder.make.internal.getMLSysLibPath(mexToolChainName);
bdir         = buildInfo.getSourcePaths(false,{'BuildDir'});
buildDir     = bdir{1};
fullbdir     = buildInfo.getSourcePaths(true,{'BuildDir'});
fullBuildDir = fullbdir{1};


[incPaths, incGroups, srcPaths, srcGroups] = coder.internal.getMLRootIncludes();

% some additional defines will be added here when the Build Args are put in a
% separate list.
modelName = get_param(buildInfo.ModelHandle,'Name');
ppdef = {['MODEL=' modelName],...
         ['NUMST=' numst],...
         ['NCSTATES=' ncstates],...
         'HAVESTDIO',...
        };

% Defines added to the 'OPTS' group; for TMF builds, these defines are passed
% to the makefile via the OPTS variable on the make command line, g2067996
optDefines = {};

makeVars = {};
makeVals = {};
makeVarGroups = {};

% various syslibs/paths are needed depending on the target
sysLibPaths = {};
sysLibs = {};
sysLibGroups = {};

cs = getActiveConfigSet(buildInfo.ModelHandle);

rootCType = RTW.getRootConfigsetType(cs);
skipMain = locSkipMainCheck(buildInfo,cs, derivedShrlibTgt, isERTSfunction);

if ispc
    libsf = 'sf_runtime';
else
    libsf = 'mwsf_runtime';
end

isSimulation = strcmp(targetType,'SIM');
isGpuCodegen = strcmpi(cs.get_param('GenerateGPUCode'), 'CUDA') && ...
    strcmpi(cs.get_param('TargetLang'), 'C++') && ~isSimulation;

if strcmpi(cs.get_param('TargetLang'), 'c')
    ext = '.c';
else
    if isGpuCodegen
        ext = '.cu';
    else
        ext = '.cpp';
    end
end

if isGpuCodegen
    buildInfo.setCompilerRequirements('supportCuda', true);
    coder.gpu.updateRtwGpuBuildInfo(buildInfo, fullBuildDir);
end

if strcmp(rootCType, 'Raccel') || strcmp(targetType,'SIM')
    buildInfo.addDefines('IS_SIM_TARGET',coder.make.internal.BuildInfoGroup.DefinesOptsGroup);
end

% In case the model has DataTableReader or DataTableWriter blocks, add
% additional system library 'mwdbserviceRTW'.
if  strcmp(hasDTBlks, '1') && (strcmp(rootCType, 'Raccel') || strcmp(targetType,'SIM'))
    sysLibs = [sysLibs, 'mwdataserviceRTW'];
    sysLibPaths = [sysLibPaths lMLSysLibPath];
    sysLibGroups = [sysLibGroups standardGroup];
end

% add the target specific info
switch rootCType
  %========================================================================
  % ERT
  %========================================================================
  case 'ERT'
    incPaths  = [incPaths...
                 fullfile(matlabroot,'rtw','c','src','ext_mode','common')];
    incGroups = [incGroups standardGroup];
    incPaths  = [incPaths [matlabroot '/rtw/c/ert']];
    incGroups = [incGroups standardGroup];

    if ~skipMain
        %add the main file.  in the case of a generated sample main, the
        %extension must match the TargetLang.
        if strcmp(cs.get_param('GenerateSampleERTMain'),'on')
            noMdlRefFiles      = {['ert_main' ext]};
            % since this will be generated into the builddir, use the value
            % in the BuildInfo.
            noMdlRefFilePaths  = buildDir;
            noMdlRefFileGroups = {'BuildDir'};
        else
            if strcmp(cs.get_param('MultiInstanceERTCode'),'off')
                mainFile = ['rt_main' ext];
            else
                if strcmpi(cs.get_param('CodeInterfacePackaging'),'C++ class')
                  mainFile = 'rt_cppclass_main.cpp';
                else
                  mainFile = ['rt_malloc_main' ext];
                end
            end
            if exist(fullfile(fullBuildDir,mainFile),'file')
                mainPath = buildDir;
            else
                mainPath = fullfile(matlabroot,'rtw','c','src','common');
            end
            noMdlRefFiles      = {mainFile};            

            noMdlRefFilePaths  = {mainPath};    
            noMdlRefFileGroups = {legacyGroup};
        end
    end
    
    % If ConcurrentTasks is turned on, we are generating threaded main for ert.tlc
    % and grt.tlc, which requires to link with pthread library on Linux and Mac
    cppThread = slfeature('RTWCGMultiThread') == 4 && strcmpi(cs.get_param('TargetLang'), 'c++') && ...
            strcmpi(cs.get_param('MultiThreadedLoops'), 'on');
    if DeploymentDiagram.isConcurrentTasks(modelName) || cppThread
        [sysLibs, sysLibPaths, sysLibGroups] = addMulticoreFlags(...
            sysLibs, sysLibPaths, sysLibGroups, standardGroup, buildInfo, modelName);
    end

    if Simulink.CodeMapping.isAutosarAdaptiveSTF(modelName)
        buildInfo.setCompilerRequirements('supportAutosarAdaptive', true);
    end
    
    % Need fixedpoint for the legacy ert SFunction
    if strcmp(get_param(cs, 'CreateSILPILBlock'), 'SIL') && ...
            strcmp(silblocktype, 'legacy')
        sysLibs = [sysLibs 'fixedpoint'];
        sysLibPaths = [sysLibPaths {lMLSysLibPath}];
        sysLibGroups = [sysLibGroups standardGroup];
    end

    if strcmp(targetType,'SIM')

        simTargetLibs = {'fixedpoint'...
                         'mwmathutil'...
                         'mwipp'...
                         'mwsl_AsyncioQueue'...
                         libsf...
			 'mwslexec_simlog'...
                         'mwcoder_ToAsyncQueueTgtAppSvc'...
                         'mwsl_simtarget_instrumentation'...
                         'mwsl_simtarget_core'};

        if modelHasSFcnsWithNoSourceCode
            simTargetLibs = [simTargetLibs 'mwsl_sfcn_loader'];
        end

        simTargetLibs = [simTargetLibs 'mwstringutil'];

        if (slfeature('SLDynamicArrays') > 0)
            simTargetLibs = [simTargetLibs 'emlrt'];
        end
        
        if SlCov.CoverageAPI.isAnyModelEnabledForCoverage()
            simTargetLibs = [simTargetLibs 'covrt'];
        end
        
        numNewLibs  = length(simTargetLibs);
        
        sysLibs(end+(1:numNewLibs))      = simTargetLibs;
        sysLibPaths(end+(1:numNewLibs))  = {lMLSysLibPath};
        sysLibGroups(end+(1:numNewLibs)) = {standardGroup};
        
        ppdef        = [ppdef 'MDL_REF_SIM_TGT=1'];
        
        ppdef = [ppdef ['MODEL_HAS_DYNAMICALLY_LOADED_SFCNS='...
                        num2str(modelHasSFcnsWithNoSourceCode)]];        
    else
        ppdef = [ppdef 'MODEL_HAS_DYNAMICALLY_LOADED_SFCNS=0'];        
    end

    % Enable CompilerRequirements to true if there is OpenCV Type used
    enableCompilerSupportForOpenCVTypePlugin(buildInfo, modelName);
    if strcmp(get_param(modelName,'IsERTTarget'), 'on') && ...
            strcmp(get_param(modelName, 'ImplementImageWithCVMat'), 'on') == 1
        buildInfo.setCompilerRequirements('supportOpenCV', true);
    end

  %========================================================================
  % GRT
  %========================================================================
  case 'GRT'
    ppdef     = [ppdef 'RT'];
    ppdef     = [ppdef 'USE_RTMODEL'];
    incPaths  = [incPaths...
                 fullfile(matlabroot,'rtw','c','src','ext_mode','common')];
    incGroups = [incGroups standardGroup];
    
    mainFile  = {};
    mainPath  = {};
    mainGroup = {};
    if ~skipMain
        if strcmp(get_param(buildInfo.ModelHandle,'GRTInterface'),'off')
            % Simplified call interface
            if strcmp(get_param(buildInfo.ModelHandle,'MultiInstanceERTCode'),'off')  
                mainFile           = ['rt_main' ext];
            else
                if strcmpi(get_param(buildInfo.ModelHandle,'CodeInterfacePackaging'),'C++ class')
                  mainFile         = 'rt_cppclass_main.cpp';
                else
                  mainFile         = ['rt_malloc_main' ext]; 
                end
            end
            mainPath           = fullfile(matlabroot,'rtw','c','src','common'); 
            mainGroup          = legacyGroup;
        else
            % Classic call interface
            if strcmp(get_param(buildInfo.ModelHandle,'MultiInstanceERTCode'),'off')
                mainFile           = ['classic_main' ext];
                mainPath           = fullfile(matlabroot,'rtw','c','grt');
                mainGroup          = legacyGroup;
            else
                mainFile           = ['grt_malloc_main' ext];
                mainPath           = fullfile(matlabroot,'rtw','c','grt_malloc');
                mainGroup          = legacyGroup;
            end
        end       
        if exist(fullfile(fullBuildDir,mainFile),'file')
            mainPath = buildDir;
        end
    end
    
    if strcmp(get_param(buildInfo.ModelHandle,'GRTInterface'),'on') && ...
            (~skipMain || DeploymentDiagram.isConcurrentTasks(modelName))
        noMdlRefFiles      = {'rt_sim.c'};
        noMdlRefFilePaths  = {fullfile(matlabroot,'rtw','c','src')};
        noMdlRefFileGroups = {legacyGroup};
    end
    
    noMdlRefFiles      = [noMdlRefFiles, mainFile];
    noMdlRefFilePaths  = [noMdlRefFilePaths, mainPath];
    noMdlRefFileGroups = [noMdlRefFileGroups, mainGroup];   
    
    % If ConcurrentTasks is turned on, we are generating threaded main for ert.tlc
    % and grt.tlc, which requires to link with pthread library on Linux and Mac
    if DeploymentDiagram.isConcurrentTasks(modelName)
        [sysLibs, sysLibPaths, sysLibGroups] = addMulticoreFlags(...
            sysLibs, sysLibPaths, sysLibGroups, standardGroup, buildInfo, modelName);
    end   
    
  %========================================================================
  % RSim
  %========================================================================
  case 'RSim'
    
    coder.internal.addRsimInfo...
        (buildInfo, cs, solverMode, lRSIMWithSlSolver, ext, targetType, libsf, ...
        lMLSysLibPath)

  %========================================================================
  % Raccel
  %========================================================================
  case 'Raccel'
    
    assert(strcmp(targetType, 'NONE'), 'Target type must be NONE')
    coder.internal.addRaccelInfo...
        (buildInfo, buildInfo.ModelHandle, ...
         modelHasSFcnsWithNoSourceCode, lMLSysLibPath, ...
         fullBuildDir, relativePathToAnchor);

  %========================================================================
  % Tornado
  %========================================================================
  case 'Tornado'
    ppdef     = [ppdef 'RT'];
    ppdef     = [ppdef 'USE_RTMODEL'];
    incPaths  = [incPaths...
                 fullfile(matlabroot,'rtw','c','src','ext_mode','common')];
    incGroups = [incGroups standardGroup];
    
    srcFiles     = {['rt_main' ext] 'rt_sim.c'};
    srcFilePaths = [srcFilePaths...
                    fullfile(matlabroot,'rtw','c','tornado')...
                    fullfile(matlabroot,'rtw','c','src')];
  %========================================================================
  % STFCustom
  %========================================================================
  case 'STFCustom'
    % rtwsfcn and accel builds fall into this case
    if strcmp(lCodeFormat, 'Accelerator_S-Function')
        %=====================================================================
        % Accelerator
        %=====================================================================
        accelSysLibs     = {...
                       'mwipp'...
                       'ut'...
                       'mwmathutil'...
                       'mwsl_simtarget_instrumentation'...
                       'mwsl_simtarget_core'...
                       'mwsl_fileio'...
                       'mwsigstream'...
                       'mwslexec_simlog'...
                       'mwsl_AsyncioQueue',...;
                       libsf,...
                       'mwsimulink',...
                       'mwslexec_simbridge', ...
                       'mwstringutil', ...
                       'emlrt',...
                       'mwslio_core', ...
                       'mwslio_clients', ...
                       'mwsl_services'};
                   
        if SlCov.CoverageAPI.isAnyModelEnabledForCoverage(modelName)
            accelSysLibs = [accelSysLibs {'covrt'}];
        end
                   
        accelSysLibPaths = repmat({lMLSysLibPath}, 1, length(accelSysLibs));
        accelSysLibGroups = repmat({standardGroup}, 1, length(accelSysLibs));
        sysLibs = [sysLibs accelSysLibs];
        sysLibPaths = [sysLibPaths accelSysLibPaths];
        sysLibGroups = [sysLibGroups accelSysLibGroups];
        
        % Define MDL_REF_SIM_TGT for accelerator case (as well as for SIM target)
        ppdef        = [ppdef 'MDL_REF_SIM_TGT=1'];
    else
        [~, sysTargetFileName, ext] = fileparts(lSystemTargetFile);
        if strcmp([sysTargetFileName ext], 'rtwsfcn.tlc')
            %=====================================================================
            % rtwsfcn
            %=====================================================================
            sysLibs     = [sysLibs...
                'ut'...
                'fixedpoint'];
            sysLibPaths = [sysLibPaths...
                {lMLSysLibPath}...
                {lMLSysLibPath}];
            sysLibGroups = [sysLibGroups...
                standardGroup...
                standardGroup];
            
            % The S-function target must be able to build non-inlined
            % s-functions and therefore needs to define 'MDL_REF_SIM_TGT=1'
            ppdef = [ppdef 'MDL_REF_SIM_TGT=1'];
        end
    end
    
  %========================================================================
  % unknown
  %========================================================================
  otherwise
    % all other targets.  Nothing to be done here
end

% if the Build Option mem_alloc has been specified to use RT_MALLOC, then
% add it to the defines
if strcmp(mem_alloc,'RT_MALLOC')
    buildInfo.addDefines('RT_MALLOC', coder.make.internal.BuildInfoGroup.DefinesOptsGroup);
end

buildInfo.addMakeVars(makeVars,makeVals,makeVarGroups);
buildInfo.addDefines(ppdef, standardGroup);
buildInfo.addDefines(optDefines, coder.make.internal.BuildInfoGroup.DefinesOptsGroup);
buildInfo.addIncludePaths(incPaths, incGroups);
buildInfo.addSourcePaths(srcPaths, srcGroups);
buildInfo.addSourceFiles(srcFiles,srcFilePaths,srcFileGroups);

% note, addSysLibs will also add paths to SysLibPaths if the path is specified
buildInfo.addSysLibs(sysLibs,sysLibPaths,sysLibGroups);

% Some builds add source files only when the model ref target type is 'NONE'
if strcmp(targetType,'NONE')
    % add the info into the dep object
    buildInfo.addSourceFiles(noMdlRefFiles,noMdlRefFilePaths,noMdlRefFileGroups);
end

% Add external mode info, if required
if isValidParam(cs, 'ExtMode')
    locAddExtMode(buildInfo, modelName, cs, isHostBased, isLccCompiler, lBuildIsTMFBased);
end

% Add info for OpaqueTypeFBT testing hook
if slsvTestingHook('OpaqueTypeFBT') == 1
    locAddOpaqueTypeFBT(buildInfo, legacyGroup);
end

% set the targetInfo for this build
buildInfo.manageTargetInfo('setTargetWordSizes',targetType);

%End of function

%------------------------------------------------------------------------------
%
% function: locAddOpaqueTypeFBT
%
% inputs:
%    buildInfo
%
% returns:
%    
%
% abstract:
%
% This function adds info for opaque type FBT
%------------------------------------------------------------------------------
function locAddOpaqueTypeFBT(buildInfo, legacyGroup)
    buildInfo.addSourceFiles('OpaqueTypeFbt.cpp',...
                     [matlabroot '/test/toolbox/simulink/sl_datatypes'],...
                     legacyGroup);
    buildInfo.addSourcePaths([matlabroot '/test/toolbox/simulink/sl_datatypes'],...
                     legacyGroup);
    buildInfo.addIncludePaths([matlabroot '/test/toolbox/simulink/sl_datatypes'],...
                     legacyGroup);

%End of function

%------------------------------------------------------------------------------
%
% function: locAddExtMode 
%
% inputs:
%    buildInfo
%
% returns:
%    
%
% abstract:
%
% This function adds external mode info, if the parameter is set.
%------------------------------------------------------------------------------
function locAddExtMode(buildInfo, modelName, cs, isHostBased, isLccCompiler, lBuildIsTMFBased)

% If external mode enabled, additional info is needed
lExtMode = get_param(cs, 'ExtMode');

% SLRT has own code to add external mode required source files
isSLRT = strcmp(get_param(cs, 'IsSLRTTarget'),'on');

if isSLRT || strcmp('off', lExtMode)
    return;
end

isXCP = coder.internal.xcp.isXCPTarget(cs);

if isXCP
    % Add XCP data independent from the Platform Abstraction Layer
    addXCPDataToBuildInfo(buildInfo, cs, isHostBased);
    if slfeature('ExtModeXCPMemoryConfiguration')
        coder.internal.xcp.configureMemoryPostCodeGen(modelName, buildInfo, isHostBased);
    end
else
    % Even though some of the source files are common between different modes,
    % they should not be added blindly. If a custom transport is provided, the
    % user needs to specify the sources explicitly in the make hook (even if
    % they use some of the standard sources)
    extModeSources{3} = 'ext_work.c';
    extModeSources{2} = 'updown.c';
    extModeSources{1} = 'ext_svr.c';
    extModeSourcePaths(1:length(extModeSources)) = {[matlabroot '/rtw/c/src/ext_mode/common']};
    extModeIncludePaths = {[matlabroot '/rtw/c/src/ext_mode/common'], ...
                           [matlabroot '/toolbox/coder/rtiostream/src']};

    % add sources, source paths and include paths to the BuildInfo object
    buildInfo.addSourceFiles(extModeSources,extModeSourcePaths,'EXT_MODE');    
    buildInfo.addSourcePaths(extModeSourcePaths,'EXT_MODE');    
    buildInfo.addIncludePaths(extModeIncludePaths, 'EXT_MODE');
end

% Ideally, we only want to add the transport-layer dependent files when
% we are running on the host. However, the idelink targets which use
% the xmakefile based build process actually rely on the fact that we
% add the transport-layer related external mode files to buildInfo, so
% maintain this behavior. The same applies for XCP Targets when using
% TMF build.
isIdeLink = any(strcmp(get_param(cs, 'SystemTargetFile'),...
    {'idelink_ert.tlc', 'idelink_grt.tlc'}));
isMSVCBuild = strcmp('RTW.MSVCBuild', get_param(cs, 'TemplateMakefile'));

if ~isValidParam(cs, 'ExtModeTransport')
    % Some non-GRT/ERT derived targets do not have an ExtModeTransport parameter
    return;
end

% process External mode build dependencies from Target Framework
isTFConnectivity = locAddExtModeTargetFramework(modelName, buildInfo);

% get the active External Mode transport name
extModeTrans = getExtModeTransport(cs);
% Add default files for non-TF scenarios
if ~isTFConnectivity && (isIdeLink || isHostBased || isMSVCBuild)
    if isXCP
        addXCPDefaultAbstractionLayer(buildInfo);
        % Only default host-based scenarios, with ConcurrentTasks "off", 
        % are expected to schedule model_step and XCP background activities 
        % sequentially in the same thread. 
        %
        % When ConcurrentTasks is on we will have a native or C++ threads
        % main.
        if strcmp(get_param(modelName, 'ConcurrentTasks'), 'off')
            % This macro guarantees that all the packets generated by a model_step
            % are flushed (and sent to the host) before proceeding with the
            % next step.
            %
            % Note that the Target Framework scenario never sets this by
            % default because we expect users to provide a multi-threaded
            % main, at least with a real-time step function and lower
            % priority background function.
            defines = {'-DXCP_EXTMODE_RUN_BACKGROUND_FLUSH'};
            buildInfo.addDefines(defines, coder.make.internal.BuildInfoGroup.DefinesOptsGroup);
        end
    end
    
    % the sources for the external mode are either TCP/IP, serial (win32 only)
    % or XCP on TCP/IP (if XCP is featured on).
    % Other values indicate a custom external mode transport which is user supplied.
    rtiostreamTcpipSrcFileFullPath = fullfile(matlabroot, 'toolbox',...
                'coder', 'rtiostream', 'src', 'rtiostreamtcpip','rtiostream_tcpip.c');
    
    rtiostreamSerialSrcFileFullPath = fullfile(matlabroot, 'toolbox',...
        'coder', 'rtiostream', 'src', 'rtiostreamserial','rtiostream_serial.c');
        
    switch(extModeTrans)
        case Simulink.ExtMode.Transports.TCP.Transport
            buildInfo.addExternalModeInfo('tcpip', rtiostreamTcpipSrcFileFullPath);
            
            % Add sockets library if using LCC compiler.
            if ispc && isLccCompiler
                addLCCSocketsLib(buildInfo);
            end
            
        case Simulink.ExtMode.Transports.Serial.Transport
            buildInfo.addExternalModeInfo('serial_acks', rtiostreamSerialSrcFileFullPath);
            
        case 'serial_win32_no_acks'
            buildInfo.addExternalModeInfo('serial_no_acks', rtiostreamSerialSrcFileFullPath);   
        
        case Simulink.ExtMode.Transports.XCPTCP.Transport
            addDefaultXCPTCPIPDriver(buildInfo);
            
        case Simulink.ExtMode.Transports.XCPSerial.Transport
            addDefaultXCPSerialDriver(buildInfo);
    end
end

% This is necessary so one can take a model (configured with ert.tlc),
% set transport layer to serial and have a successful build. The
% problem is that our shipping tmfs don't have these paths in their
% list of rules. They only have it for tcpip, but not serial. We add
% this here to avoid updating all the TMFs.
if (lBuildIsTMFBased && strcmp(extModeTrans, Simulink.ExtMode.Transports.Serial.Transport))
    buildInfo.addSourcePaths(fullfile(matlabroot, 'rtw', 'c', 'src', 'ext_mode',...
        'serial'),'EXT_MODE');
    buildInfo.addSourcePaths(fullfile(matlabroot, 'toolbox', 'coder', 'rtiostream', 'src', ...
        'rtiostreamserial'),'EXT_MODE');
end

% EXT_MODE is defined explicitly for TMF builds. We don't define it for BTI,
% because it is automatically deduced from the EXT_MODE Build Arg
if lBuildIsTMFBased
    buildInfo.addDefines('-DEXT_MODE', coder.make.internal.BuildInfoGroup.DefinesOptsGroup);
end

% if this is set for external mode, then additional info is needed
if strcmp('on',get_param(cs, 'ExtModeTesting'))
    assert(~isXCP,'ExtModeTesting features are not supported yet when XCP is enabled');
    buildInfo.addSourceFiles('ext_test.c',...
        [matlabroot '/test/tools/slrtw/extmode'],...
        'EXT_MODE');
    buildInfo.addSourcePaths([matlabroot '/test/tools/slrtw/extmode'],'EXT_MODE');
    buildInfo.addDefines('-DTMW_EXTMODE_TESTING',coder.make.internal.BuildInfoGroup.DefinesOptsGroup);
end

% additional flags get added here for ext mode static alloc
if strcmp('on',get_param(cs, 'ExtModeStaticAlloc'))
    if ~isXCP
        % additional sources required by Classic External Mode only
        buildInfo.addSourceFiles('mem_mgr.c',...
            [matlabroot '/rtw/c/src/ext_mode/common'],...
            'EXT_MODE');
    end

    staticSize = get_param(cs, 'ExtModeStaticAllocSize');

    buildInfo.addDefines('-DEXTMODE_STATIC',coder.make.internal.BuildInfoGroup.DefinesOptsGroup);
    buildInfo.addDefines(['-DEXTMODE_STATIC_SIZE=' num2str(staticSize)],coder.make.internal.BuildInfoGroup.DefinesOptsGroup);
end

% additional flags get added here if Code Execution Profiling is enabled
if cs.isValidParam('CodeExecutionProfiling') &&...
       strcmp('on', get_param(cs, 'CodeExecutionProfiling')) && isXCP
    buildInfo.addDefines('-DEXTMODE_CODE_EXEC_PROFILING',coder.make.internal.BuildInfoGroup.DefinesOptsGroup);

    if isHostBased && coder.profile.private.featureOn('CustomMemoryModel')
        buildInfo.addDefines('-DEXTMODE_CODE_EXEC_PROFILING_CUSTOM',coder.make.internal.BuildInfoGroup.DefinesOptsGroup);
    elseif slfeature('ExtModeXCPMemoryConfiguration')
        % When memory configuration is enabled and profiling uses the main memory we assign to it the
        % fourth set of blocks
        buildInfo.addDefines( ...
            {'-DINTERNAL_XCP_MEM_BLOCK_4_NUMBER=10', ...
            '-DINTERNAL_XCP_MEM_BLOCK_4_SIZE=560'});
    end
end

% rtwin and open protocol do not use rtiostream.
isSLDRT = any(strcmp(cs.get_param('SystemTargetFile'),...
    {'sldrt.tlc','sldrtert.tlc','rtwin.tlc','rtwinert.tlc'}));

isOpenProtocol = strcmp(cs.get_param('ExtModeIntrfLevel'),...
    'Level2 - Open');

% our internal testing of open protocol uses rtiostream
is_ext_open_testing_intrf = strcmp(cs.get_param('ExtModeMexFile'),...
    'ext_open_testing_intrf');

if (~isSLDRT && ~isOpenProtocol) || is_ext_open_testing_intrf
    
    % add rtIOStream utility files to buildInfo. For tmf based targets, add
    % to the Sfcn group so this file gets compiled along with the other
    % hard-coded external mode files in the tmf.
    if lBuildIsTMFBased
        group = 'Sfcn';
    else %BTI
        group = 'EXT_MODE';
    end
    
    rtIOStreamUtilsSrcPath = fullfile(matlabroot,'toolbox',...
        'coder','rtiostream','src','utils');
    buildInfo.addSourceFiles('rtiostream_utils.c', rtIOStreamUtilsSrcPath, group);
    buildInfo.addIncludeFiles('rtiostream_utils.h', rtIOStreamUtilsSrcPath, group);
    buildInfo.addIncludePaths(rtIOStreamUtilsSrcPath, group);
    buildInfo.addSourcePaths(rtIOStreamUtilsSrcPath, group);
end

buildInfo.addDefines('-DON_TARGET_WAIT_FOR_START=0',coder.make.internal.BuildInfoGroup.DefinesOptsGroup);

%------------------------------------------------------------------------------
% function: locAddExtModeTargetFramework 
%
% abstract: Process External mode build dependencies from Target Framework
%
% inputs:
%    modelName, buildInfo
%
% returns: 
%    isTFConnectivity - boolean indicating whether a Target Framework based
%    External mode connectivity is being used. 
%
function isTFConnectivity = locAddExtModeTargetFramework(modelName, buildInfo)
isTFConnectivity = false;
if coder.internal.connectivity.featureOn('ExtModeTargetFramework')
    % search for a Target Framework Board and add registered files        
    [isTFTarget, board] = codertarget.utils.isTargetFrameworkTarget(get_param(modelName, 'HardwareBoard'));
    
    if isTFTarget
        % lookup the active ExternalModeConnectivity
        connectivity = Simulink.ExtMode.TargetFrameworkUtils.getActiveExternalModeConnectivity(modelName, ...
            board);
        if ~isempty(connectivity)
            % flag TF-based connectivity
            isTFConnectivity = true;
            if isempty(connectivity.XCP.XCPPlatformAbstraction)
                % default abstraction layer supports Linux, Windows and Mac
                addXCPDefaultAbstractionLayer(buildInfo);
            else
                % automatically add the define to register that we have a
                % custom abstraction layer
                buildInfo.addDefines('-DXCP_CUSTOM_PLATFORM');
                buildDependencies = connectivity.XCP.XCPPlatformAbstraction.BuildDependencies;
                if ~isempty(buildDependencies)
                    % add to BuildInfo
                    %
                    % Note that we do not use the "EXT_MODE" group which is now only relevant 
                    % to the legacy TMF + classic ExtMode scenario.
                    coder.internal.targetframework.addBuildDependenciesToBuildInfo(buildInfo, buildDependencies);
                end
            end 
            
            % lookup the CommunicationInterface
            communicationInterface = ...
                Simulink.ExtMode.TargetFrameworkUtils.getBoardCommunicationInterfaceForXCPTransport(board, ...
                    connectivity.XCP.XCPTransport);
                
            if ~isempty(communicationInterface.APIImplementations)
                assert(length(communicationInterface.APIImplementations) == 1, ...
                    'Only expect one APIImplementation');
                if ~isempty(communicationInterface.APIImplementations.BuildDependencies)
                    % add to BuildInfo
                    buildDependencies = communicationInterface.APIImplementations.BuildDependencies;
                    coder.internal.targetframework.addBuildDependenciesToBuildInfo(buildInfo, buildDependencies);
                end
            end
        end
    end
end

%=============================================================================
% Function: locSkipMainCheck 
%
% inputs:
%    cs
%
%
%
%=============================================================================
function skipMain = locSkipMainCheck(buildInfo,cs, derivedShrlibTgt, isERTSfunction)
    skipMain=true;
    
    % the target is responsible for providing a file with the main()
    % declaration.
    if buildInfo.Settings.TargetProvidesMain
        return;
    end
    
    % For ERT s-function, it is possible that a main file is generated but it should
    % not be compiled and is therefore omitted from buildInfo
    if isERTSfunction
        return;
    end

    % For SDP Function Platform, main is not needed at all.
    modelName = get_param(buildInfo.ModelHandle,'Name');
    platformType = coder.dictionary.internal.getPlatformType(modelName);
    if platformType == "FunctionPlatform" 
        return;
    end
    
    
    % For SLRT, it is possible that a main file is generated but it should not be
    % compiled and is therefore omitted from buildInfo
    if any(strcmp(cs.get_param('IsSLRTTarget'), 'on'))
        return;
    end        
    
    % For ERT shared library, it is possible that a main file is generated but it
    % should not be compiled and is therefore omitted from buildInfo
    isShrLib = strcmp('ert_shrlib.tlc', get_param(cs, 'SystemTargetFile'));
    if derivedShrlibTgt || isShrLib
        return;
    end
    
    % AUTOSAR compliant configsets have no main file
    if strcmp(cs.get_param('AutosarCompliant'),'on')
        return;
    end
    
   
    % tlmgenerator and dpigenerator do not need a main         
    if any(strcmp(cs.get_param('SystemTargetFile'),...
                  {'tlmgenerator.tlc',...
                   'tlmgenerator_ert.tlc',...
                   'tlmgenerator_grt.tlc',...
                  'systemverilog_dpi_ert.tlc',...
                  'systemverilog_dpi_grt.tlc'}))
        return;
    end
    
    % When concurrent execution is enabled main is either
    % auto-generated or provided with target
    if strcmp(cs.get_param('ConcurrentTasks'),'on')
        return;
    end

    % this target needs a main file.
    skipMain=false;

%End of Function locSkipMainCheck


function addXCPDataToBuildInfo(buildInfo, cs, isHostBased)
% Add XCP includes, paths, defines and source paths independent from the Platform
% Abstraction Layer.
%
% Note: in the initial release the user won't be allowed to modify 
% the XCP Slave Memory Allocator and the XCP Driver will be based on rtiostream.
% For this reason, the following files (part of the Default Abstraction Layer)
% will be also included:
% - xcp_mem_default.c (Default Memory Allocator implementation)
% - xcp_drv_rtiostream.c (Wrapper for rtIOStream-based XCP Driver)

xcpTargetPath = fullfile(matlabroot, 'toolbox', 'coder', 'xcp', ...
                         'src', 'target');
                     
xcpProtocolSrcPath = fullfile(matlabroot, 'toolbox', 'coder', 'xcp', 'src', ...
                              'target', 'slave', 'protocol', 'src');
xcpTransportSrcPath = fullfile(matlabroot, 'toolbox', 'coder', 'xcp', 'src', ...
                               'target', 'slave', 'transport', 'src');
xcpExtModeSrcPath = fullfile(matlabroot, 'toolbox', 'coder', 'xcp', 'src', ...
                             'target', 'ext_mode', 'src');
                     
xcpDefaultPlatformSrcPath=fullfile(matlabroot, 'toolbox', 'coder', 'xcp',...
                     'src', 'target', 'slave', 'platform', 'default');

xcpCommonSrcPath = fullfile(xcpTargetPath, 'slave', 'common');

% Add include paths
incPaths = {fullfile(xcpTargetPath, 'slave', 'include'),...
            fullfile(xcpTargetPath, 'slave', 'common'),...
            fullfile(xcpTargetPath, 'slave', 'protocol', 'src'),...
            fullfile(xcpTargetPath, 'slave', 'protocol', 'include'),...
            fullfile(xcpTargetPath, 'slave', 'transport', 'include'),...
            fullfile(xcpTargetPath, 'slave', 'transport', 'src'),...
            fullfile(xcpTargetPath, 'slave', 'platform', 'include'),...
            fullfile(xcpTargetPath, 'slave', 'platform', 'default'),...            
            fullfile(xcpTargetPath, 'ext_mode', 'include'),...
            fullfile(xcpTargetPath, 'ext_mode', 'src'),...
            fullfile(matlabroot, 'simulink', 'include'),...
            fullfile(matlabroot, 'toolbox', 'coder', 'rtiostream', 'src')};

buildInfo.addIncludePaths(incPaths, 'EXT_MODE');
            
% Add source paths
srcPaths = {xcpProtocolSrcPath,...
            xcpTransportSrcPath,...
            xcpExtModeSrcPath,...
            xcpDefaultPlatformSrcPath};
buildInfo.addSourcePaths(srcPaths,'EXT_MODE');


% Add source files
srcFiles = {'xcp_ext_common.c',...
            'xcp_ext_classic_trigger.c',...
            'xcp.c',...
            'xcp_standard.c',...
            'xcp_daq.c',...
            'xcp_calibration.c',...
            'xcp_fifo.c',...
            'xcp_transport.c',...
            'xcp_mem_default.c',...
            'xcp_drv_rtiostream.c', ...
            'xcp_utils.c'};

srcFilePaths = {xcpExtModeSrcPath,...
                xcpExtModeSrcPath,...
                xcpProtocolSrcPath,...
                xcpProtocolSrcPath,...
                xcpProtocolSrcPath,...
                xcpProtocolSrcPath,...
                xcpTransportSrcPath,...
                xcpTransportSrcPath,...
                xcpDefaultPlatformSrcPath,...
                xcpDefaultPlatformSrcPath,...
                xcpCommonSrcPath};
            
if coder.internal.xcp.isXCPOnTCPIPTarget(cs)
    % Add TCP/IP Frame Handler (common to all the TCP/IP transport 
    % layer implementations)    
    srcFiles{end+1} = 'xcp_frame_tcp.c';
    srcFilePaths{end+1} = xcpTransportSrcPath;
    
    % Add rtiostream parameters customization layer
    srcFiles{end+1} = 'xcp_ext_param_default_tcp.c';
    srcFilePaths{end+1} = xcpExtModeSrcPath;    
end

if coder.internal.xcp.isXCPOnSerialTarget(cs)
    % Add Sxi Frame Handler   
    srcFiles{end+1} = 'xcp_frame_serial.c';
    srcFilePaths{end+1} = xcpTransportSrcPath;
    
    % Add rtiostream parameters customization layer
    srcFiles{end+1} = 'xcp_ext_param_default_serial.c';
    srcFilePaths{end+1} = xcpExtModeSrcPath;
end

if coder.internal.xcp.isXCPOnCANTarget(cs)
    % Add CAN Frame Handler
    srcFiles{end+1} = 'xcp_frame_can.c';
    srcFilePaths{end+1} = xcpTransportSrcPath;
    
    % Add rtiostream parameters customization layer
    srcFiles{end+1} = 'xcp_ext_param_default_can.c';
    srcFilePaths{end+1} = xcpExtModeSrcPath;
end

buildInfo.addSourceFiles(srcFiles, srcFilePaths, 'EXT_MODE');

% Add defines specific to the XCP Slave configuration
defines = {'-DXCP_DAQ_SUPPORT',...
           '-DXCP_CALIBRATION_SUPPORT',...
           '-DXCP_TIMESTAMP_SUPPORT',...
           '-DXCP_TIMESTAMP_BASED_ON_SIMULATION_TIME', ...
           '-DXCP_SET_MTA_SUPPORT'};

% Add defines specific to the XCP-based External Mode configuration
if ~slfeature('ExtModeXCPMemoryConfiguration')
    % When automatic memory configuration is not enabled, the number of reserved pools for DAQs
    % equals the number of tasks.
    clear extmode_task_info;        % Make sure we do not use a "cached" 
                                    % version of the file from an earlier build
    tasksInfo = extmode_task_info();
    tasksNumber = length(tasksInfo);
    defines{end+1} = ['-DXCP_MEM_DAQ_RESERVED_POOLS_NUMBER=' num2str(tasksNumber)];
end
defines{end+1} = '-DEXTMODE_XCP_TRIGGER_SUPPORT';

% Configure XCP slave for big-endian targets
if coder.internal.connectivity.featureOn('XcpBigEndian')
    isBigEndian = coder.internal.xcp.isBigEndianTarget(buildInfo.ComponentName, ...
        cs, ...
        isHostBased);
    if isBigEndian
        defines{end+1} = '-DXCP_BIG_ENDIAN';
    end
end

buildInfo.addDefines(defines, coder.make.internal.BuildInfoGroup.DefinesOptsGroup);


function addXCPDefaultAbstractionLayer(buildInfo)
% Add the XCP Default Platform Abstraction Layer (except the XCP Driver)
defaultPlatformSrcPath=fullfile(matlabroot, 'toolbox', 'coder', 'xcp',...
                     'src', 'target', 'slave', 'platform', 'default');
                 
% Add source files
srcFiles = {'xcp_platform_default.c'};   % other platform abstraction layer APIs
srcFilePaths = {defaultPlatformSrcPath};

buildInfo.addSourceFiles(srcFiles, srcFilePaths, 'EXT_MODE');


function addDefaultXCPTCPIPDriver(buildInfo)
% Add Default XCP Driver for XCP on TCP/IP, based on rtiostream_tcpip.c
rtIOStreamSrcPath = fullfile(matlabroot, 'toolbox', 'coder', ...
                             'rtiostream', 'src', 'rtiostreamtcpip');
                           
% Add source paths
srcPaths = {rtIOStreamSrcPath};
buildInfo.addSourcePaths(srcPaths,'EXT_MODE');

%Add source files
srcFiles = {'rtiostream_tcpip.c'};
srcFilePaths = {rtIOStreamSrcPath};
        
buildInfo.addSourceFiles(srcFiles, srcFilePaths, 'EXT_MODE');

function addDefaultXCPSerialDriver(buildInfo)
% Add Default XCP Driver for XCP on SERIAL, based on ...
                           
rtIOStreamSrcPath = fullfile(matlabroot, 'toolbox', 'coder', ...
                             'rtiostream', 'src', 'rtiostreamserial');
                           
% Add source paths
srcPaths = {rtIOStreamSrcPath};
buildInfo.addSourcePaths(srcPaths,'EXT_MODE');

%Add source files
srcFiles = {'rtiostream_serial.c'};
        
srcFilePaths = {rtIOStreamSrcPath};

buildInfo.addSourceFiles(srcFiles, srcFilePaths, 'EXT_MODE');


function extModeTransport = getExtModeTransport(cfg)
% Retrieve the selected transport layer
transportIndex = get_param(cfg, 'ExtModeTransport');
% Return the string corresponding to the active transport layer
extModeTransport = Simulink.ExtMode.Transports.getExtModeTransport(cfg, transportIndex);


function [sysLibs, sysLibPaths, sysLibGroups] = addMulticoreFlags(...
    sysLibs, sysLibPaths, sysLibGroups, standardGroup, buildInfo, modelName)
% Add multicore code generation libraries and flags
isSLRealTime = strcmp(get_param(modelName, 'IsSLRTTarget'), 'on');
if codertarget.target.isCoderTarget(modelName) && ...
    strcmp(get_param(modelName, 'HasConcurrentBlocks'), 'on')
  %Enable posix support for coder targets
  buildInfo.setCompilerRequirements('supportMulticorePthread', true);
  return;
end

if ismac
    sysLibs      = [sysLibs 'pthread'];
    sysLibPaths  = [sysLibPaths {''}];
    sysLibGroups = [sysLibGroups standardGroup];

    if strcmp(get_param(modelName, 'HasConcurrentBlocks'), 'on')
        % If we have the feature enabled
        if (slfeature('SLMulticorePthread'))
            buildInfo.setCompilerRequirements('supportMulticorePthread', true);
        else
            buildInfo.setCompilerRequirements('supportOpenMP', true);
        end
    end
elseif isunix || isSLRealTime
    sysLibs      = [sysLibs 'pthread' 'rt'];
    sysLibPaths  = [sysLibPaths {''} {''}];
    sysLibGroups = [sysLibGroups standardGroup standardGroup];
    
    % If model contains dataflow, generated code has OpenMP threads for ert.tlc and grt.tlc
    if strcmp(get_param(modelName, 'HasConcurrentBlocks'), 'on') || ...
            strcmp(get_param(modelName, 'HasParallelForEachSubsystem'), 'on')
        % If we have the feature enabled 
        if(slfeature('SLMulticorePthread') || isSLRealTime)
            buildInfo.setCompilerRequirements('supportMulticorePthread', true);
        else
            buildInfo.setCompilerRequirements('supportOpenMP', true);
        end
    end
    
elseif strcmp(get_param(modelName, 'HasConcurrentBlocks'), 'on') || ...
        strcmp(get_param(modelName, 'HasParallelForEachSubsystem'), 'on')
    % If model contains dataflow, generated code has OpenMP threads for ert.tlc and grt.tlc
    buildInfo.setCompilerRequirements('supportOpenMP', true);
end


% Function: enableCompilerSupportForOpenCVTypePlugin =======================================================
% Abstract:
%     Set true to CompilerRequirements when model use OpenCV types without correct setting
%
function enableCompilerSupportForOpenCVTypePlugin(h, modelName)
    pluginMgr = Simulink.PluginMgr;
    isLoaded = pluginMgr.isPluginLoaded('OpenCVTypePlugin');
    % return when there is no opencvtype_plugin installed
    if ~isLoaded
        return
    end
    % return when the model does not have opencv type
    isUsingCVTypes = get_param(modelName,'IsUsingOpenCVType');
    if strcmp(isUsingCVTypes,'off')
        return
    end
    % check target language must be C++
    targetLang = get_param(modelName, 'TargetLang');
    if ~strcmp(targetLang, 'C++')
        DAStudio.error('RTW:buildProcess:OpenCVNotSupportCCodegen');
    end
    
    if strcmp(get_param(modelName, 'GenCodeOnly'), 'off')
        h.setCompilerRequirements('supportOpenCV', true);
    end
