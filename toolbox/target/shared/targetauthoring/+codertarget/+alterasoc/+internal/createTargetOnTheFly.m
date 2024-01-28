function createTargetOnTheFly(tgtName,folder,varargin)

    disp(['Running  ',mfilename('fullpath'),'.m'])

    p=inputParser;
    addRequired(p,'tgtName',@ischar);
    addRequired(p,'folder',@ischar);
    addOptional(p,'isSimTgt',false,@islogical);
    addParameter(p,'hwboards',{},@iscellstr);

    p.KeepUnmatched=true;
    p.parse(tgtName,folder,varargin{:});
    isSimTgt=p.Results.isSimTgt;
    hwboards=p.Results.hwboards;
    tgtObj=i_createTargetObject(tgtName,folder);
    deployerObj=i_createDeployerObject(tgtObj,isSimTgt);
    oSObj=i_createOperatingSystemObject(tgtObj);
    externalModeObjs=i_createExternalModeObjects(tgtObj,isSimTgt);
    pilObj=i_createPILObject(tgtObj);
    profilerObj=i_createProfilerObject(tgtObj);

    for i=1:numel(hwboards)
        hwObj=i_createHardwareObject(hwboards{i});
        map(tgtObj,hwObj,hwboards{i});

        map(tgtObj,hwObj,deployerObj);

        map(tgtObj,hwObj,oSObj);
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
        case{'AlteraArria10SoCdevelopmentkit.xml',...
            'AlteraCycloneVSoCdevelopmentkit.xml'}
            tgtHWInfo.ESBCompatible=3;

        otherwise
            tgtHWInfo.ESBCompatible=0;
        end
        tgtHWInfo.NumOfCores=2;
        if isSimTgt
            tgtHWInfo.SupportsOnlySimulation=true;
            tgtHWInfo.BaseProductID=codertarget.targethardware.BaseProductID.SOC;
        else
            tgtHWInfo.MATLABPILInfo=struct('GetPropsFcn','codertarget.alterasoc.internal.getMATLABPILProps');
            tgtHWInfo.TaskMap.isSupported='matlab:codertarget.utils.isSoCInstalledAndModelConfiguredForSoC';
            tgtHWInfo.TaskMap.useAutoMap='matlab:codertarget.utils.isSoCInstalledAndModelConfiguredForSoC';
        end
        tgtHWInfo.SubFamily='ARM Cortex-A';

        fwdInfoFileName='forwarding.xml';
        fwdObj=codertarget.forwarding.ForwardingInfo();
        fwdObj.setTargetName(tgtObj.Name);
        fwdObj.setDefinitionFileName(fwdInfoFileName);
        fwdObj.addParameter(struct('Name','FPGADesign','ForwardingFcn','codertarget.alterasoc.internal.forwardFPGAParameters'));
        fwdObj.register;
        tgtHWInfo.setForwardingInfoFile(fwdInfoFileName);

        tgtHWInfo.register;
        attributeInfoFile=tgtHWInfo.getAttributeInfoFile;
        attributeInfoFile=strrep(attributeInfoFile,'$(TARGET_ROOT)',tgtObj.Folder);
        attributeObj=codertarget.attributes.AttributeInfo(attributeInfoFile);
        attributeObj.setTargetName(tgtObj.Name);
        if~isSimTgt
            attributeObj.setOnHardwareSelectHook('codertarget.alterasoc.internal.onHardwareSelect');
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
        bc.Libraries='$(TARGET_ROOT)/bin/libcodertarget_TargetServices.lib';
        bc.DefinitionFileName=bcFileName;
        bc.SupportedToolchains='ARM Development Studio Altera Edition (DS-5 AE)';
        bc.serialize();
        attributeObj.addTargetService(bcFileName,'TCP/IP');
        attributeObj.TargetServices.BuildConfigurationInfo.CompileFlags='$(TARGET_SYSROOT) -DBOOST_CB_DISABLE_DEBUG -DBOOST_LOG_API_VERSION=200 -DBOOST_THREAD_FUTURE=unique_future -DBOOST_ALL_NO_LIB -DBOOST_ALL_DYN_LINK';
        attributeObj.TargetServices.BuildConfigurationInfo.LinkFlags='$(TARGET_SYSROOT) -lstdc++ -lboost_system -lboost_date_time -lboost_chrono -lboost_thread -lpthread -lboost_unit_test_framework';
        attributeObj.TargetServices.addApplicationService('ToAsyncQueueAppSvc',...
        '$(TARGET_ROOT)/bin/libcodertarget_ToAsyncQueueTgtAppSvc.lib');
        attributeObj.TargetServices.addApplicationService('StreamingProfilerAppSvc',...
        '$(ESB_TARGET_ROOT)/bin/libcodertarget_StreamingProfilerAppSvc.lib');
        attributeObj.register;
        [~,fname,fext]=fileparts(tgtHWInfo.getParameterInfoFile);
        parametersObj=i_createParameterInfoObject(isSimTgt);
        parametersObj.setTargetName(tgtObj.Name);
        parametersObj.setName(tgtObj.Name);
        parametersObj.DefinitionFileName=[fname,fext];
        parametersObj.register;
        fpgaIntrObj=codertarget.interrupts.FPGAInterruptsInfo;
        addNewFPGAInterrupt(fpgaIntrObj,struct('InterfacePortName','hps.f2h_irq0','InterfacePortWidth',32));
        addNewFPGAInterrupt(fpgaIntrObj,struct('InterfacePortName','hps.f2h_irq1','InterfacePortWidth',32));
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
        'if (codertarget.internal.isSpPkgInstalled(''alterasoc_ec'') || codertarget.internal.isSpPkgInstalled(''intelsoc'')), return; end');
        fcnWriter.deleteLineFromFcnAt('rtwTargetInfo',5);
    end
    fcnWriter.addLineToFcnAt('rtwTargetInfo',5,'% Register message catalog');
    fcnWriter.addLineToFcnAt('rtwTargetInfo',6,'sproot = codertarget.arm_cortex_a_base.internal.getBaseDir;');
    fcnWriter.addLineToFcnAt('rtwTargetInfo',7,'if isdir(sproot)');
    fcnWriter.addLineToFcnAt('rtwTargetInfo',8,'   matlab.internal.msgcat.setAdditionalResourceLocation(sproot);');
    fcnWriter.addLineToFcnAt('rtwTargetInfo',9,'end');
    fcnWriter.deleteLineFromFcnAt('loc_createPILConfig',4);
    fcnWriter.addLineToFcnAt('loc_createPILConfig',4,...
    'config(1).ConfigClass = ''codertarget.alterasoc.pil.ConnectivityConfig'';');

    if~isSimTgt
        fcnWriter.addLineToFcnAt('i_isConfigSetCompatible',13,...
        'elseif isa(configSet, ''coder.connectivity.MATLABConfig'')');
        fcnWriter.addLineToFcnAt('i_isConfigSetCompatible',14,'hObj = configSet.getConfig;');
        fcnWriter.addLineToFcnAt('i_isConfigSetCompatible',15,...
        'targetHardware = codertarget.target.getHardwareName(hObj);');
        fcnWriter.addLineToFcnAt('i_isConfigSetCompatible',16,...
        'hardwareList = codertarget.alterasoc.internal.getHardwarePlatforms(''matlab'');');
        fcnWriter.addLineToFcnAt('i_isConfigSetCompatible',17,...
        'isConfigSetCompatible = ~isempty(targetHardware) && ismember(targetHardware,hardwareList);');
    else
        for i=13:-1:3,fcnWriter.deleteLineFromFcnAt('i_isConfigSetCompatible',i);end
        fcnWriter.deleteFcn('loc_createPILConfig');
    end
    if~isSimTgt
        fcnWriter.addLineToFcnAt('loc_registerThisTarget',3,'ret.ShortName = ''alterasocembeddedcoder'';');
        fcnWriter.addLineToFcnAt('loc_registerBoardsForThisTarget',6,'boardInfo = codertarget.targethardware.setBaseProductID(boardInfo, ''alterasoc_ec'', ''intelsoc'');');
        fcnWriter.addLineToFcnAt('loc_registerBoardsForThisTarget',6,...
        ['if (~codertarget.internal.isSpPkgInstalled(''alterasoc_ec'') && ...'...
        ,newline,'codertarget.internal.isSpPkgInstalled(''intelsoc''))',newline...
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


function hwObj=i_createHardwareObject(hwName)
    hwObj=createHardware(hwName);
    hwObj.DeviceID='ARM Cortex-A9';
    ioInterfaceObj=hwObj.addNewEthernetInterface('TCP/IP');
    ioInterfaceObj.Port='17725';
    ioInterfaceObj.IPAddress='codertarget.alterasoc.HardwareParameterInfo.getDeviceAddress';
    ioInterfaceObj(2)=hwObj.addNewEthernetInterface('XCP on TCP/IP');
    ioInterfaceObj(2).Port='17725';
    ioInterfaceObj(2).IPAddress='codertarget.alterasoc.HardwareParameterInfo.getDeviceAddress';
end



function deployerObj=i_createDeployerObject(tgtObj,isSimTgt)
    deployerObj=addNewDeployer(tgtObj,'AlteraSoC Deployer');
    deployerObj=addTokens(deployerObj);
    if isSimTgt
        deployerObj.BuildEntryFcn='matlabshared.target.alterasocsim.installSpPkg';
    else
        deployerObj.BuildEntryFcn='codertarget.alterasoc.internal.onBuildEntryHook';
    end
    deployerObj.AfterCodeGenFcn='codertarget.alterasoc.internal.onAfterCodeGen';

    toolchainObj=addNewToolchain(deployerObj,'ARM Development Studio Altera Edition (DS-5 AE)');
    buildConfigurationObj=addNewBuildConfiguration(toolchainObj,'Build Configuration for AlteraSoC Deployer');

    buildConfigurationObj.SourceFiles{end+1}='$(TARGET_ROOT)/src/axi4Interface.c';
    buildConfigurationObj.IncludePaths{end+1}='$(TARGET_ROOT)/src';
    buildConfigurationObj.IncludePaths{end+1}='$(TARGET_ROOT)/include';
    buildConfigurationObj.IncludePaths{end+1}='$(TARGET_ROOT)/blocks/include';
    buildConfigurationObj.Defines{end+1}='ARM_PROJECT';
    buildConfigurationObj.Defines{end+1}='MW_EXTMODE_RECV_TIMEOUT_USEC=10';

    buildConfigurationObj.CompilerFlags='$(TARGET_SYSROOT)';
    buildConfigurationObj.CPPCompilerFlags='$(TARGET_SYSROOT)';
    buildConfigurationObj.LinkerFlags='$(TARGET_SYSROOT)';
    buildConfigurationObj.CPPLinkerFlags='$(TARGET_SYSROOT)';

    ldObj=addNewLoader(deployerObj,'SSHDownload Based Loader for Intel SoC  Deployer');
    ldObj.LoadCommand='matlab:codertarget.alterasoc.internal.loadandrun';
    ldObj.LoadCommandArguments='get_param(getModel(hCS), ''Name'')';
end



function deployerObj=addTokens(deployerObj)
    token.Name='ARM_CORTEX_A_BASE_ROOT_DIR';
    token.Value='codertarget.arm_cortex_a_base.internal.getSpPkgRootDir';
    deployerObj.Tokens{end+1}=token;
    token.Name='ARM_CORTEX_A_ROOT_DIR';
    token.Value='codertarget.arm_cortex_a.internal.getSpPkgRootDir';
    deployerObj.Tokens{end+1}=token;
    token.Name='TARGET_ROOT';
    token.Value='codertarget.alterasoc.internal.getSpPkgRootDir';
    deployerObj.Tokens{end+1}=token;
    token.Name='SOCFPGA_IPADDRESS';
    token.Value='codertarget.alterasoc.HardwareParameterInfo.getDeviceAddress';
    deployerObj.Tokens{end+1}=token;
    token.Name='SOCFPGA_USERNAME';
    token.Value='codertarget.alterasoc.HardwareParameterInfo.getUsername';
    deployerObj.Tokens{end+1}=token;
    token.Name='SOCFPGA_PASSWORD';
    token.Value='codertarget.alterasoc.HardwareParameterInfo.getPassword';
    deployerObj.Tokens{end+1}=token;
    token.Name='SOCFPGA_BUILDDIR';
    token.Value='codertarget.alterasoc.HardwareParameterInfo.getBuilddir';
    deployerObj.Tokens{end+1}=token;
    token.Name='ESB_TARGET_ROOT';
    token.Value='soc.intelsoc.internal.getRootFolder';
    deployerObj.Tokens{end+1}=token;
    token.Name='TARGET_SYSROOT';
    token.Value=sprintf('codertarget.linux.internal.SysrootInfo.getSysrootMacroFromModel(hObj)');
    deployerObj.Tokens{end+1}=token;
end


function out=getBoardParameters(isSimTgt)

    if isSimTgt
        fcnNameSpace='soc.internal';
    else
        fcnNameSpace='codertarget.alterasoc';
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
        extModeObj.PreConnectFcn='matlabshared.target.alterasocsim.installSpPkg';
        extModeObj.SetupFcn='matlabshared.target.alterasocsim.installSpPkg';
    else
        extModeObj.SetupFcn='codertarget.alterasoc.internal.extmodeHooks(hObj, ''setupfcn'');';
        extModeObj.PreConnectFcn='codertarget.alterasoc.internal.extmodeHooks(hObj,''preconnectfcn'');';
    end
    extModeObj.SourceFiles{end+1}='$(MATLAB_ROOT)/rtw/c/src/ext_mode/common/rtiostream_interface.c';
    extModeObj.SourceFiles{end+1}='$(MATLAB_ROOT)/rtw/c/src/ext_mode/common/ext_svr.c';
    extModeObj.SourceFiles{end+1}='$(MATLAB_ROOT)/toolbox/coder/rtiostream/src/rtiostreamtcpip/rtiostream_tcpip.c';
    extModeObj(2)=addNewExternalMode(tgtObj,'XCP on TCP/IP External mode');
    extModeObj(2).Protocol='XCP';
    extModeObj(2).PreConnectFcn='codertarget.alterasoc.internal.extmodeHooks(hObj,''preconnectfcn'');';
    extModeObj(2).SourceFiles{end+1}='$(MATLAB_ROOT)/toolbox/coder/rtiostream/src/rtiostreamtcpip/rtiostream_tcpip.c';
    extModeObj(2).SourceFiles{end+1}='$(MATLAB_ROOT)/toolbox/coder/xcp/src/target/slave/platform/default/xcp_platform_default.c';
    extModeObj(2).SetupFcn='codertarget.alterasoc.internal.extmodeHooks(hObj, ''setupfcn'');codertarget.utils.toggleXCPfeatures(''on'');';
    extModeObj(2).CloseFcn='codertarget.utils.toggleXCPfeatures(''off'');';
end


function pilObj=i_createPILObject(tgtObj)
    pilObj=addNewPIL(tgtObj,'Intel SoC PIL');
end


function profilerObj=i_createProfilerObject(tgtObj)
    profilerObj=tgtObj.getProfiler('reference');
    profilerObj=profilerObj{1};
    profilerObj.Name='Intel SoC Profiler';
    profilerObj.GetDataFcn='codertarget.alterasoc.internal.getProfileData';
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