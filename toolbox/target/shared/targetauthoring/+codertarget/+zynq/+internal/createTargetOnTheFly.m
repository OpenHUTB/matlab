function createTargetOnTheFly(tgtName,folder,varargin)

    disp(['Running  ',mfilename('fullpath'),'.m'])

    p=inputParser;
    addRequired(p,'tgtName',@ischar);
    addRequired(p,'folder',@ischar);
    addOptional(p,'isSimTgt',false,@islogical);
    addParameter(p,'hwboards',{},@iscellstr);
    addParameter(p,'isVxWorks',{},@islogical);
    addParameter(p,'devID',{},@iscellstr);
    addParameter(p,'deployerObj',{},@(x)isa(x,'matlabshared.targetsdk.Deployer'));
    p.KeepUnmatched=true;
    p.parse(tgtName,folder,varargin{:});
    isSimTgt=p.Results.isSimTgt;
    hwboards=p.Results.hwboards;
    isVxWorks=p.Results.isVxWorks;
    devID=p.Results.devID;

    if isempty(isVxWorks)
        isVxWorks=false(1,numel(hwboards));
    end

    if isempty(devID)
        [devID{1:numel(hwboards)}]=deal('ARM Cortex-A9');
    end
    tgtObj=i_createTargetObject(tgtName,folder);
    if~exist('deployerObj','var')
        deployerObj=i_createDeployerObject(tgtObj,isSimTgt);
    end
    linuxOSObj=i_createOperatingSystemObject(tgtObj);
    vxWorksOSObj=matlabshared.targetsdk.OperatingSystem('VxWorks');
    externalModeObjs=i_createExternalModeObjects(tgtObj,isSimTgt);
    pilObj=i_createPILObject(tgtObj);
    profilerObj=i_createProfilerObject(tgtObj);

    for i=1:numel(hwboards)

        hwObj=i_createHardwareObject(hwboards{i},devID{i});
        map(tgtObj,hwObj,hwboards{i});

        map(tgtObj,hwObj,deployerObj);

        map(tgtObj,hwObj,linuxOSObj);
        if isVxWorks(i)&&~isSimTgt

            map(tgtObj,hwObj,vxWorksOSObj);
        end

        map(tgtObj,hwObj,externalModeObjs(1),'TCP/IP');
        map(tgtObj,hwObj,externalModeObjs(2),'XCP on TCP/IP');

        map(tgtObj,hwObj,pilObj,'TCP/IP');

        map(tgtObj,hwObj,profilerObj);
    end

    saveTarget(tgtObj);
    i_applyCoderTargetAPIs(tgtObj,isSimTgt);
    i_updateRTWTargetInfo(tgtObj,isSimTgt);
    rehash toolbox;
    sl_refresh_customizations;
end



function i_applyCoderTargetAPIs(tgtObj,isSimTgt)
    tgtHwDir=dir(fullfile(tgtObj.Folder,'registry','targethardware'));

    for ii=1:length(tgtHwDir(3:end))
        tgtHwFileName=tgtHwDir(2+ii).name;
        tgtHWInfo=codertarget.targethardware.TargetHardwareInfo(...
        fullfile(tgtObj.Folder,'registry','targethardware',tgtHwFileName),...
        tgtObj.Name);
        switch tgtHwFileName
        case{'XilinxZynqZC702evaluationkit.xml',...
            'XilinxZynq7000basedboard.xml'}
            tgtHWInfo.ESBCompatible=0;
        otherwise
            tgtHWInfo.ESBCompatible=3;
        end

        tgtHWInfo.NumOfCores=2;
        if isSimTgt
            tgtHWInfo.SupportsOnlySimulation=true;
            tgtHWInfo.BaseProductID=codertarget.targethardware.BaseProductID.SOC;
        else
            tgtHWInfo.MATLABPILInfo=struct('GetPropsFcn','codertarget.zynq.internal.getMATLABPILProps');
            tgtHWInfo.TaskMap.isSupported='matlab:codertarget.utils.isSoCInstalledAndModelConfiguredForSoC';
            tgtHWInfo.TaskMap.useAutoMap='matlab:codertarget.utils.isSoCInstalledAndModelConfiguredForSoC';
        end
        tgtHWInfo.SubFamily='ARM Cortex-A';
        if~isequal(tgtHWInfo.Name,'ZedBoard')
            tgtHWInfo.ToolChainInfo(2)=tgtHWInfo.ToolChainInfo(1);
            tgtHWInfo.ToolChainInfo(3)=tgtHWInfo.ToolChainInfo(1);
            tgtHWInfo.ToolChainInfo(2).LoaderName='Zynq Wind River Workbench DIAB Loader';
            tgtHWInfo.ToolChainInfo(2).Name='Wind River Workbench DIAB 5.9.4.0';
            tgtHWInfo.ToolChainInfo(3).LoaderName='Zynq Wind River Workbench GNU Loader';
            tgtHWInfo.ToolChainInfo(3).Name='Wind River Workbench GNU ARM 4.8.1';
        end
        tgtHWInfo.setPreferenceName('XLNXZYNQ');

        fwdInfoFileName='forwarding.xml';
        fwdObj=codertarget.forwarding.ForwardingInfo();
        fwdObj.setTargetName(tgtObj.Name);
        fwdObj.setDefinitionFileName(fwdInfoFileName);
        fwdObj.addParameter(struct('Name','FPGADesign','ForwardingFcn','codertarget.zynq.internal.forwardFPGAParameters'));
        fwdObj.register;
        tgtHWInfo.setForwardingInfoFile(fwdInfoFileName);

        tgtHWInfo.register;
        attributeInfoFile=tgtHWInfo.getAttributeInfoFile;
        attributeInfoFile=strrep(attributeInfoFile,'$(TARGET_ROOT)',tgtObj.Folder);
        attributeObj=codertarget.attributes.AttributeInfo(attributeInfoFile);
        attributeObj.setTargetName(tgtObj.Name);

        if~isSimTgt
            attributeObj.setOnHardwareSelectHook('codertarget.zynq.internal.onHardwareSelect');
        else
            attributeObj.setOnHardwareSelectHook('soc.internal.onHardwareSelect');
        end
        attributeObj.ExternalModeInfo(1).Transport.IPAddress.visible=false;
        attributeObj.ExternalModeInfo(1).CoderTargetParameter=...
        struct('name','Runtime.BuildAction','value','Build, load, and run');
        attributeObj.ExternalModeInfo(1).Task.InBackground=true;
        attributeObj.ExternalModeInfo(1).Task.InForeground=true;
        attributeObj.ExternalModeInfo(1).Task.Visible=true;
        attributeObj.ExternalModeInfo(1).Task.Default='background';
        attributeObj.DetectOverrun='true';

        attributeObj.ExternalModeInfo(2).Transport.IPAddress.visible=false;
        attributeObj.ExternalModeInfo(2).CoderTargetParameter=...
        struct('name','Runtime.BuildAction','value','Build, load, and run');
        attributeObj.ExternalModeInfo(2).Task.InBackground=true;
        attributeObj.ExternalModeInfo(2).Task.InForeground=false;
        attributeObj.ExternalModeInfo(2).Task.Visible=false;
        attributeObj.ExternalModeInfo(2).Task.Default='background';

        bcFileName=fullfile(attributeObj.TargetFolder,'registry','attributes','TargetService_BuildConfig.xml');
        bc=codertarget.attributes.BuildConfigurationInfo();
        bc.Libraries='$(SHARED_UTILS_ROOT)/bin/libcodertarget_TargetServices.lib';
        bc.DefinitionFileName=bcFileName;
        bc.SupportedToolchains={'Linaro AArch32 Linux v6.3.1'};
        bc.serialize();
        attributeObj.addTargetService(bcFileName,'TCP/IP');
        attributeObj.TargetServices.BuildConfigurationInfo.CompileFlags='$(TARGET_SYSROOT) -DBOOST_CB_DISABLE_DEBUG -DBOOST_LOG_API_VERSION=200 -DBOOST_THREAD_FUTURE=unique_future -DBOOST_ALL_NO_LIB -DBOOST_ALL_DYN_LINK';
        attributeObj.TargetServices.BuildConfigurationInfo.LinkFlags='$(TARGET_SYSROOT) -lstdc++ -lboost_system -lboost_date_time -lboost_chrono -lboost_thread -lpthread -lboost_unit_test_framework';
        attributeObj.TargetServices.addApplicationService('ToAsyncQueueAppSvc',...
        '$(SHARED_UTILS_ROOT)/bin/libcodertarget_ToAsyncQueueTgtAppSvc.lib');
        attributeObj.TargetServices.addApplicationService('StreamingProfilerAppSvc',...
        '$(ESB_TARGET_ROOT)/bin/libcodertarget_StreamingProfilerAppSvc.lib');
        attributeObj.Profiler.EnableModelInitLogging=0;
        attributeObj.register;
        [~,fname,fext]=fileparts(tgtHWInfo.getParameterInfoFile);
        parametersObj=i_createParameterInfoObject(isSimTgt);
        parametersObj.setTargetName(tgtObj.Name);
        parametersObj.setName(tgtObj.Name);
        parametersObj.DefinitionFileName=[fname,fext];
        parametersObj.register;
        fpgaIntrObj=codertarget.interrupts.FPGAInterruptsInfo;
        addNewFPGAInterrupt(fpgaIntrObj,struct('InterfacePortName','processing_system7/IRQ_F2P','InterfacePortWidth',16));
        fpgaIntrObj.DefinitionFileName=fullfile(tgtObj.Folder,'registry','interrupts',[tgtHwFileName(1:end-4),'FPGAInterrupts.xml']);
        fpgaIntrObj.serialize;
    end
end



function i_updateRTWTargetInfo(tgtObj,isSimTgt)
    fcnWriter=codertarget.internal.FunctionWriter;
    fcnWriter.FileName=fullfile(tgtObj.Folder,'rtwTargetInfo.m');
    fcnWriter.deserialize;
    if isSimTgt
        fcnWriter.addLineToFcnAt('rtwTargetInfo',2,...
        'if (codertarget.internal.isSpPkgInstalled(''xilinxzynq_ec'') || codertarget.internal.isSpPkgInstalled(''xilinxsoc'')), return; end');
        fcnWriter.deleteLineFromFcnAt('rtwTargetInfo',5);
    end
    fcnWriter.deleteLineFromFcnAt('loc_createPILConfig',4);
    fcnWriter.addLineToFcnAt('loc_createPILConfig',4,...
    'config(1).ConfigClass = ''zynq.pil.ConnectivityConfig'';');
    if~isSimTgt
        fcnWriter.deleteLineFromFcnAt('i_isConfigSetCompatible',6);
        fcnWriter.addLineToFcnAt('i_isConfigSetCompatible',6,...
        'hwSupportingPIL = codertarget.zynq.internal.getHardwarePlatforms;');
        fcnWriter.addLineToFcnAt('i_isConfigSetCompatible',13,...
        'elseif isa(configSet, ''coder.connectivity.MATLABConfig'')');
        fcnWriter.addLineToFcnAt('i_isConfigSetCompatible',14,'hObj = configSet.getConfig;');
        fcnWriter.addLineToFcnAt('i_isConfigSetCompatible',15,...
        'targetHardware = codertarget.target.getHardwareName(hObj);');
        fcnWriter.addLineToFcnAt('i_isConfigSetCompatible',16,...
        'hardwareList = codertarget.zynq.internal.getHardwarePlatforms(''matlab'');');
        fcnWriter.addLineToFcnAt('i_isConfigSetCompatible',17,...
        'isConfigSetCompatible = ~isempty(targetHardware) && ismember(targetHardware,hardwareList);');
    else
        for i=13:-1:3,fcnWriter.deleteLineFromFcnAt('i_isConfigSetCompatible',i);end
        fcnWriter.deleteFcn('loc_createPILConfig');
    end

    if~isSimTgt
        fcnWriter.addLineToFcnAt('loc_registerThisTarget',3,'ret.ShortName = ''matlab:codertarget.zynq.internal.getTargetShortName'';');
        fcnWriter.addLineToFcnAt('loc_registerBoardsForThisTarget',6,'boardInfo = codertarget.targethardware.setBaseProductID(boardInfo, ''xilinxzynq_ec'', ''xilinxsoc'');');
        fcnWriter.addLineToFcnAt('loc_registerBoardsForThisTarget',7,...
        ['if (~codertarget.internal.isSpPkgInstalled(''xilinxzynq_ec'') && ...'...
        ,newline,'codertarget.internal.isSpPkgInstalled(''xilinxsoc''))',newline...
        ,'boardInfo = boardInfo([boardInfo.IsSoCCompatible]);',newline,'end']);
    else
        fcnWriter.addLineToFcnAt('loc_registerThisTarget',3,'ret.ShortName = ''soc'';');
        fcnWriter.deleteFcn('i_isConfigSetCompatible');
    end
    fcnWriter.serialize;
end


function tgtObj=i_createTargetObject(tgtName,folder)
    refTgt='ARM Cortex-A Base';
    tgtObj=createTarget(tgtName,refTgt,folder);
end



function hwObj=i_createHardwareObject(hwName,devID)
    hwObj=createHardware(hwName,devID);
    ioInterfaceObj=hwObj.addNewEthernetInterface('TCP/IP');
    ioInterfaceObj.Port='17725';
    ioInterfaceObj.IPAddress='codertarget.zynq.HardwareParameterInfo.getDeviceAddress';
    ioInterfaceObj(2)=hwObj.addNewEthernetInterface('XCP on TCP/IP');
    ioInterfaceObj(2).Port='17725';
    ioInterfaceObj(2).IPAddress='codertarget.zynq.HardwareParameterInfo.getDeviceAddress';
end


function deployerObj=i_createDeployerObject(tgtObj,isSimTgt)
    deployerObj=addNewDeployer(tgtObj,'Xilinx Zynq Deployer');
    deployerObj=addTokens(deployerObj);
    deployerObj.AfterCodeGenFcn='codertarget.zynq.internal.onAfterCodeGen';
    if isSimTgt
        deployerObj.BuildEntryFcn='matlabshared.target.xilinxzynqsim.installSpPkg';
    else
        deployerObj.BuildEntryFcn='codertarget.zynq.internal.onBuildEntryHook';
    end

    toolchainObjArmLin=addNewToolchain(deployerObj,'Linaro AArch32 Linux v6.3.1');
    buildConfigurationObjArmLin=addNewBuildConfiguration(toolchainObjArmLin,'Build Configuration for Linaro AArch32 Linux');

    buildConfigurationObjArmLin.SourceFiles{end+1}='$(SHARED_UTILS_ROOT)/src/axi4Lite.c';
    buildConfigurationObjArmLin.IncludePaths{end+1}='$(SHARED_UTILS_ROOT)/src';
    buildConfigurationObjArmLin.IncludePaths{end+1}='$(SHARED_UTILS_ROOT)/include';
    buildConfigurationObjArmLin.IncludePaths{end+1}='$(SHARED_UTILS_ROOT)/blocks/include';
    buildConfigurationObjArmLin.Defines{end+1}='ARM_PROJECT';
    buildConfigurationObjArmLin.Defines{end+1}='MW_EXTMODE_RECV_TIMEOUT_USEC=10';

    buildConfigurationObjArmLin.CompilerFlags='$(TARGET_SYSROOT)';
    buildConfigurationObjArmLin.CPPCompilerFlags='$(TARGET_SYSROOT)';
    buildConfigurationObjArmLin.LinkerFlags='$(TARGET_SYSROOT)';
    buildConfigurationObjArmLin.CPPLinkerFlags='$(TARGET_SYSROOT)';

    ldObj=addNewLoader(deployerObj,'Zynq Linaro Linux Loader');
    ldObj.LoadCommand='matlab:codertarget.zynq.internal.loadandrun';
    ldObj.LoadCommandArguments='get_param(getModel(hCS), ''Name'')';
end



function deployerObj=addTokens(deployerObj)
    token.Name='ARM_CORTEX_A_BASE_ROOT_DIR';
    token.Value='codertarget.arm_cortex_a_base.internal.getSpPkgRootDir';
    deployerObj.Tokens{end+1}=token;
    token.Name='ARM_CORTEX_A_ROOT_DIR';
    token.Value='codertarget.arm_cortex_a.internal.getSpPkgRootDir';
    deployerObj.Tokens{end+1}=token;
    token.Name='ARM_CORTEX_A_INSTALLDIR';
    token.Value='codertarget.arm_cortex_a.internal.getSpPkgRootDir';
    deployerObj.Tokens{end+1}=token;
    token.Name='SHARED_UTILS_ROOT';
    token.Value='codertarget.zynq.internal.getSpPkgRootDir';
    deployerObj.Tokens{end+1}=token;
    token.Name='TARGET_ROOT';
    token.Value='codertarget.zynq.internal.getSpPkgRootDir';
    deployerObj.Tokens{end+1}=token;
    token.Name='XILINXZYNQ_IPADDRESS';
    token.Value='codertarget.zynq.HardwareParameterInfo.getDeviceAddress';
    deployerObj.Tokens{end+1}=token;
    token.Name='XILINXZYNQ_USERNAME';
    token.Value='codertarget.zynq.HardwareParameterInfo.getUsername';
    deployerObj.Tokens{end+1}=token;
    token.Name='XILINXZYNQ_PASSWORD';
    token.Value='codertarget.zynq.HardwareParameterInfo.getPassword';
    deployerObj.Tokens{end+1}=token;
    token.Name='XILINXZYNQ_BUILDDIR';
    token.Value='codertarget.zynq.HardwareParameterInfo.getBuilddir';
    deployerObj.Tokens{end+1}=token;
    token.Name='ESB_TARGET_ROOT';
    token.Value='soc.zynq.internal.getRootFolder';
    deployerObj.Tokens{end+1}=token;
    token.Name='TARGET_SYSROOT';
    token.Value=sprintf('codertarget.linux.internal.SysrootInfo.getSysrootMacroFromModel(hObj)');
    deployerObj.Tokens{end+1}=token;
end

function out=getBoardParameters(isSimTgt)

    if isSimTgt
        fcnNameSpace='soc.internal';
    else
        fcnNameSpace='codertarget.zynq';
    end

    out.DeviceAddress.Value=...
    [fcnNameSpace,'.HardwareParameterInfo.getDeviceAddress'];
    out.DeviceAddress.Callback=...
    [fcnNameSpace,'.HardwareParameterInfo.onDeviceAddressChange'];

    out.Username.Value=...
    [fcnNameSpace,'.HardwareParameterInfo.getUsername'];
    out.Username.Callback=...
    [fcnNameSpace,'.HardwareParameterInfo.onUsernameChange'];

    out.Password.Value=...
    [fcnNameSpace,'.HardwareParameterInfo.getPassword'];
    out.Password.Callback=...
    [fcnNameSpace,'.HardwareParameterInfo.onPasswordChange'];
end



function osObj=i_createOperatingSystemObject(tgtObj)
    osObj=getOperatingSystem(tgtObj,'reference');
end


function extModeObj=i_createExternalModeObjects(tgtObj,isSimTgt)
    extModeObj=addNewExternalMode(tgtObj,'TCP/IP External mode');
    if isSimTgt
        extModeObj.PreConnectFcn='matlabshared.target.xilinxzynqsim.installSpPkg';
        extModeObj.SetupFcn='matlabshared.target.xilinxzynqsim.installSpPkg';
    else
        extModeObj.SetupFcn='codertarget.zynq.internal.extmodeHooks(hObj, ''setupfcn'');';
        extModeObj.PreConnectFcn='codertarget.zynq.internal.extmodeHooks(hObj,''preconnectfcn'');';
    end

    extModeObj.SourceFiles{end+1}='$(MATLAB_ROOT)/rtw/c/src/ext_mode/common/rtiostream_interface.c';
    extModeObj.SourceFiles{end+1}='$(MATLAB_ROOT)/rtw/c/src/ext_mode/common/ext_svr.c';
    extModeObj.SourceFiles{end+1}='$(MATLAB_ROOT)/toolbox/coder/rtiostream/src/rtiostreamtcpip/rtiostream_tcpip.c';
    extModeObj(2)=addNewExternalMode(tgtObj,'XCP on TCP/IP External mode');
    extModeObj(2).Protocol='XCP';
    extModeObj(2).PreConnectFcn='codertarget.zynq.internal.extmodeHooks(hObj,''preconnectfcn'');';
    extModeObj(2).SourceFiles{end+1}='$(MATLAB_ROOT)/toolbox/coder/rtiostream/src/rtiostreamtcpip/rtiostream_tcpip.c';
    extModeObj(2).SourceFiles{end+1}='$(MATLAB_ROOT)/toolbox/coder/xcp/src/target/slave/platform/default/xcp_platform_default.c';
    extModeObj(2).SetupFcn='codertarget.zynq.internal.extmodeHooks(hObj, ''setupfcn'');codertarget.utils.toggleXCPfeatures(''on'');';
    extModeObj(2).CloseFcn='codertarget.utils.toggleXCPfeatures(''off'');';
end



function pilObj=i_createPILObject(tgtObj)
    pilObj=addNewPIL(tgtObj,'Xilinx Zynq PIL');
end



function profilerObj=i_createProfilerObject(tgtObj)
    profilerObj=tgtObj.getProfiler('reference');
    profilerObj=profilerObj{1};
    profilerObj.Name='Xilinx Zynq Profiler';
    profilerObj.GetDataFcn='codertarget.zynq.internal.getProfileData';
end



function p=i_createParameterInfoObject(isSimTgt)
    p=codertarget.parameter.ParameterInfo;
    bp=getBoardParameters(isSimTgt);
    boardParamsVis='1';
    if isSimTgt
        boardParamsVis='0';
    end
    p.addParameter('Group','Board Parameters','Name','Device Address:','Type','edit','Tag','DeviceAddress','Enabled','1','Visible',boardParamsVis,'Value',bp.DeviceAddress.Value,'Data','','RowSpan','[0,0]','ColSpan','[1,3]','Alignment','1','DialogRefresh','0','Storage','BoardParameters.DeviceAddress','DoNotStore','false','Callback',bp.DeviceAddress.Callback,'SaveValueAsString','true','Entries','','ValueType','callback','ValueRange','','ToolTip','');
    p.addParameter('Group','Board Parameters','Name','Username:','Type','edit','Tag','Username','Enabled','1','Visible',boardParamsVis,'Value',bp.Username.Value,'Data','','RowSpan','[0,0]','ColSpan','[1,2]','Alignment','1','DialogRefresh','0','Storage','BoardParameters.Username','DoNotStore','false','Callback',bp.Username.Callback,'SaveValueAsString','true','Entries','','ValueType','callback','ValueRange','','ToolTip','');
    p.addParameter('Group','Board Parameters','Name','Password:','Type','edit','Tag','Password','Enabled','1','Visible',boardParamsVis,'Value',bp.Password.Value,'Data','','RowSpan','[0,0]','ColSpan','[1,2]','Alignment','1','DialogRefresh','0','Storage','BoardParameters.Password','DoNotStore','false','Callback',bp.Password.Callback,'SaveValueAsString','true','Entries','','ValueType','callback','ValueRange','','ToolTip','');
    if~isSimTgt
        p.addParameter('Group','Build options','Name','Build action:','Type','combobox','Tag','Build_action','Enabled','1','Visible','1','Value','Build, load, and run','Data','','RowSpan','[1,1]','ColSpan','[1,3]','Alignment','1','DialogRefresh','0','Storage','Runtime.BuildAction','DoNotStore','false','Callback','widgetChangedCallback','SaveValueAsString','true','Entries','Build; Build and load; Build, load, and run','ValueType','','ValueRange','','ToolTip','');
    end
    p.addParameter('Group','Clocking','Name','CPU Clock (MHz):','Type','edit','Tag','CPU_Clock_in_MHz','Enabled','1','Visible','1','Value','1000','Data','','RowSpan','[0,0]','ColSpan','[1,3]','Alignment','1','DialogRefresh','0','Storage','Clocking.cpuClockRateMHz','DoNotStore','false','Callback','widgetChangedCallback','SaveValueAsString','true','Entries','','ValueType','','ValueRange','','ToolTip','');
end







