classdef DataModelAdapter


    methods(Access='private')
        function h=DataModelAdapter()

        end
    end
    methods(Static=true,Access={?codertarget.Registry})


        function hardwareInfo=getHwInfo(tgtObj,hwName)
            hardwareObj=codertarget.DataModelAdapter.getHardwareObjforHardwareName(tgtObj,hwName);
            if~isempty(hardwareObj)
                hardwareInfo=codertarget.targethardware.TargetHardwareInfo;
                hardwareInfo.setName(hardwareObj.Name);
                hardwareInfo.setTargetName(tgtObj.Name);
                hardwareInfo.TargetFolder=tgtObj.Folder;
                hardwareInfo.TargetType=codertarget.target.getTargetType(tgtObj.Name);
                hardwareInfo.setDeviceID(hardwareObj.DeviceID);
                hardwareInfo.setDisplayName(hardwareObj.Name);
                hardwareInfo.ProdHWDeviceType=hardwareObj.MathWorksDeviceType;
                deployers=codertarget.DataModelAdapter.getDeployerforHardware(tgtObj,hardwareObj);
                for i=1:numel(deployers)
                    depObj=deployers{i};
                    for j=1:numel(depObj.Toolchains)
                        toolchainName=depObj.Toolchains{1}.Name;
                        hardwareInfo.addToolChain(toolchainName);
                        if~isempty(depObj.Loaders)
                            loaderName=depObj.Loaders{1}.Name;
                            loadCmd=depObj.Loaders{1}.LoadCommand;
                            isMATLABFcn=isequal(strfind(loadCmd,'matlab:'),1);
                            if isMATLABFcn
                                loadCmd=strrep(loadCmd,'matlab:','');
                            end
                            hardwareInfo.setLoaderName(loaderName,toolchainName);
                            hardwareInfo.setLoadCommand(loadCmd,toolchainName);
                            hardwareInfo.setLoadCommandArgs(depObj.Loaders{1}.LoadCommandArguments,toolchainName);
                            hardwareInfo.setIsLoadCommandMATLABFcn(isMATLABFcn,toolchainName);
                        end
                    end
                end
                hardwareInfo.setParameterInfoFile(fullfile('$(TARGET_ROOT)',...
                'registry','parameters',[codertarget.internal.makeValidFileName(hardwareInfo.Name),'.xml']));
            end
        end

        function[attributeInfo,schedulerInfos,rtosInfos]=getFeatures(tgtObj,hwName,hardwareInfo)
            hardwareObj=codertarget.DataModelAdapter.getHardwareObjforHardwareName(tgtObj,hwName);
            attributeInfo=codertarget.DataModelAdapter.getAttrInfo(tgtObj,hwName);
            Seq=codertarget.DataModelAdapter.randomStringGenerator();
            hardwareInfo.setAttributeInfoFile(Seq);
            attributeInfo.setDefinitionFileName(Seq);



            schedulerInfos=codertarget.DataModelAdapter.getAllSchedulerInfo(tgtObj,hardwareObj);
            for i=1:numel(schedulerInfos)
                if isempty(schedulerInfos{i}.getDefinitionFileName)
                    Seq=codertarget.DataModelAdapter.randomStringGenerator();
                    hardwareInfo.addSchedulerInfoFile(Seq);
                    schedulerInfos{i}.setDefinitionFileName(Seq);
                else
                    hardwareInfo.addSchedulerInfoFile(schedulerInfos{i}.getDefinitionFileName);
                end
            end



            rtosInfos=codertarget.DataModelAdapter.getAllRTOSInfo(tgtObj,hardwareObj);
            for i=1:numel(rtosInfos)
                if isempty(rtosInfos{i}.getDefinitionFileName)
                    Seq=codertarget.DataModelAdapter.randomStringGenerator();
                    hardwareInfo.addRTOSInfoFile(Seq);
                    rtosInfos{i}.setDefinitionFileName(Seq);
                else
                    hardwareInfo.addRTOSInfoFile(rtosInfos{i}.getDefinitionFileName);
                end

            end
        end


        function attributeInfo=getAttrInfo(tgtObj,hwName)
            attributeInfo=[];
            hardwareObj=codertarget.DataModelAdapter.getHardwareObjforHardwareName(tgtObj,hwName);
            if~isempty(hardwareObj)
                attributeInfo=codertarget.attributes.AttributeInfo;
                attributeInfo.setTargetName(tgtObj.Name);
                deployers=codertarget.DataModelAdapter.getDeployerforHardware(tgtObj,hardwareObj);
                depObj=deployers{1};
                if~isempty(depObj)
                    attributeInfo.setName(depObj.Name);
                    codertarget.DataModelAdapter.addDeployerSection(depObj,attributeInfo,tgtObj);
                end
                codertarget.DataModelAdapter.addExternalModeSection(tgtObj,hardwareObj,attributeInfo);
                codertarget.DataModelAdapter.addPILSection(tgtObj,hardwareObj,attributeInfo);
                codertarget.DataModelAdapter.addProfilerSection(tgtObj,hardwareObj,attributeInfo);
            end
        end


        function rtosInfo=getAllRTOSInfo(tgtObj,hardwareObj)
            rtosInfo={};
            supportedRTOS=tgtObj.getOperatingSystem('mapped');
            for j=1:numel(supportedRTOS)
                rtosName=supportedRTOS{j}.Name;
                if ismember(rtosName,matlabshared.targetsdk.OperatingSystem.LISTOFFACTORYOS)
                    rtosFileName=lower([codertarget.internal.makeValidFileName(rtosName),'.xml']);
                    rtosFile=fullfile('$(MATLAB_ROOT)',...
                    'toolbox','target','codertarget','rtos',...
                    'registry',rtosFileName);
                    rtosFile=codertarget.utils.replaceTokensforHardwareName(hardwareObj.Name,rtosFile);
                    rtosInfo{end+1}=codertarget.rtos.RTOSInfo(rtosFile);%#ok<AGROW>
                else
                    refTgt=tgtObj.ReferenceTargets;
                    for i=1:numel(refTgt)
                        refTgtRTOS=refTgt{i}.getOperatingSystem('mapped');
                        for k=1:numel(refTgtRTOS)
                            if isequal(rtosName,refTgtRTOS{k}.Name)
                                rtosFileName=refTgtRTOS{k}.ConfigurationFile;
                                Tokens=refTgt{i}.Deployers{1}.Tokens;
                                rtosFileName=codertarget.utils.replaceTokensforHardwareName(hardwareObj.Name,rtosFileName,Tokens);
                                rtosInfo{end+1}=codertarget.Registry.manageInstance('get','rtos',rtosFileName);%#ok<AGROW>
                            end
                        end
                    end
                end
            end
        end



        function schedulerInfo=getAllSchedulerInfo(tgtObj,hardwareObj)
            schedulerInfo={};
            schedObjs=tgtObj.getBaremetalScheduler('mapped',hardwareObj);
            for i=1:numel(schedObjs)
                refTgtScheduler=codertarget.DataModelAdapter.searchRefTargetScheduler(tgtObj,hardwareObj,schedObjs{i});
                if~isempty(refTgtScheduler)
                    schedulerInfo{end+1}=refTgtScheduler;%#ok<AGROW>
                else

                    schedulerInfoObj=codertarget.scheduler.SchedulerInfo;
                    schedulerInfoObj.setTargetName(tgtObj.Name);
                    schedulerInfoObj.setName(schedObjs{i}.BaseRateTriggers{1}.Name);
                    schedulerInfoObj.setConfigureStartCall(schedObjs{i}.BaseRateTriggers{1}.ConfigurationFcn);
                    schedulerInfoObj.setInterruptDisableCall(schedObjs{i}.BaseRateTriggers{1}.DisableInterruptFcn);
                    schedulerInfoObj.setInterruptEnableCall(schedObjs{i}.BaseRateTriggers{1}.EnableInterruptFcn);
                    for k=1:numel(schedObjs{i}.BuildConfigurations)
                        schedulerInfoObj.addNewBuildConfigurationInfo(schedObjs{i}.BuildConfigurations{k});
                    end
                    schedulerInfo{end+1}=schedulerInfoObj;%#ok<AGROW>
                end
            end
        end
        function schedulerInfo=searchRefTargetScheduler(tgtObj,hardwareObj,schedObj)


            schedulerInfo={};
            refTgt=tgtObj.ReferenceTargets;
            refTgt=refTgt{1};
            refTgtSchedulers=refTgt.getBaremetalScheduler('mapped');
            for j=1:numel(refTgtSchedulers)
                if isequal(schedObj,refTgtSchedulers{j})
                    refTgtVersion=codertarget.target.getTargetVersion(refTgt.Name);
                    if(refTgtVersion==1)
                        Tokens=refTgt.Deployers{1}.Tokens;
                        schedulerFileName=schedObj.SchedulerFile;
                        schedulerFileName=codertarget.utils.replaceTokensforHardwareName(hardwareObj.Name,schedulerFileName,Tokens);
                        schedulerInfo=codertarget.Registry.manageInstance('get','scheduler',schedulerFileName);
                        return;
                    end
                end
            end
        end
        function addDeployerSection(depObj,attrInfoObj,tgtObj)
            if~isempty(depObj.Toolchains)
                for i=1:numel(depObj.Toolchains{1}.BuildConfigurations)
                    if~isempty(depObj.Toolchains{1}.BuildConfigurations{i})
                        attrInfoObj.addNewBuildConfigurationInfo(...
                        depObj.Toolchains{1}.BuildConfigurations{i});
                    end
                end
            end
            attrInfoObj.IncludeFiles=depObj.MainIncludeFiles;
            attrInfoObj.Tokens=depObj.Tokens;
            tokenFcn=codertarget.DataModelAdapter.getReferenceTargetTokenFcn(tgtObj);
            tokenName=codertarget.DataModelAdapter.getReferenceTargetTokenName(tgtObj);
            attrInfoObj.Tokens{end+1}=struct('Name',tokenName,'Value',tokenFcn);
            attrInfoObj.OnBuildEntryHook=depObj.BuildEntryFcn;
            attrInfoObj.OnAfterCodeGenHook=depObj.AfterCodeGenFcn;
            attrInfoObj.TargetInitializationCalls=depObj.HardwareInitializationFcn;
        end
        function fcn=getReferenceTargetTokenFcn(tgtObj)
            fcn=['matlabshared.target.',tgtObj.PackageName,'.getReferenceTargetRootFolder'];
        end
        function name=getReferenceTargetTokenName(tgtObj)
            name=upper([matlabshared.targetsdk.internal.makeValidFileName(tgtObj.ReferenceTargets{1}.Name),'_ROOT_DIR']);
        end
        function addExternalModeSection(tgtObj,hardwareObj,attrInfoObj)
            allExternalModeObjs=tgtObj.getExternalMode('mapped',hardwareObj);
            for i=1:numel(allExternalModeObjs)
                extModeObj=allExternalModeObjs{i};
                if tgtObj.isMapped(hardwareObj,extModeObj)
                    ioInterfaceName=tgtObj.getMapping(hardwareObj,extModeObj);
                    ioInterfaceObj=hardwareObj.getIOInterface(ioInterfaceName{1});
                    if isempty(ioInterfaceObj)
                        continue
                    end
                    ioInterfaceObj=ioInterfaceObj{1};
                    if isa(ioInterfaceObj,'matlabshared.targetsdk.EthernetInterface')
                        if attrInfoObj.isExternalMode(ioInterfaceObj.Name,'tcp/ip')
                            continue
                        end
                        attrInfoObj.addExternalModeInfo('tcpip','tcp/ip',ioInterfaceObj.Name);
                        attrInfoObj.ExternalModeInfo(end).Transport.IPAddress.value=ioInterfaceObj.IPAddress;
                        attrInfoObj.ExternalModeInfo(end).Transport.Port.value=num2str(ioInterfaceObj.Port);
                        attrInfoObj.ExternalModeInfo(end).Transport.Verbose.value='false';
                    elseif isa(ioInterfaceObj,'matlabshared.targetsdk.SerialInterface')
                        if attrInfoObj.isExternalMode(ioInterfaceObj.Name,'serial')
                            continue
                        end
                        attrInfoObj.addExternalModeInfo('serial','serial',ioInterfaceObj.Name);
                        attrInfoObj.ExternalModeInfo(end).Transport.Baudrate.value=num2str(ioInterfaceObj.DefaultBaudrate);
                        attrInfoObj.ExternalModeInfo(end).Transport.COMPort.value=ioInterfaceObj.DefaultPort;
                        attrInfoObj.ExternalModeInfo(end).Transport.Verbose.value='false';
                        attrInfoObj.ExternalModeInfo(end).Transport.AvailableBaudrates=ioInterfaceObj.AvailableBaudrates;
                        attrInfoObj.ExternalModeInfo(end).Transport.AvailableCOMPorts=ioInterfaceObj.AvailablePorts;
                    end
                    attrInfoObj.EnableOneClick=true;
                    attrInfoObj.ExternalModeInfo(end).SourceFiles=extModeObj.SourceFiles;
                    attrInfoObj.ExternalModeInfo(end).PreConnectFcn=extModeObj.PreConnectFcn;
                    attrInfoObj.ExternalModeInfo(end).SetupFcn=extModeObj.SetupFcn;
                    attrInfoObj.ExternalModeInfo(end).CloseFcn=extModeObj.CloseFcn;
                    attrInfoObj.ExternalModeInfo(end).Task.InBackground=true;
                    attrInfoObj.ExternalModeInfo(end).Task.InForeground=false;
                end
            end
        end
        function addPILSection(tgtObj,hardwareObj,attrInfoObj)
            allPILObjs=tgtObj.getPIL('mapped',hardwareObj);
            for i=1:numel(allPILObjs)
                pilObj=allPILObjs{i};
                if tgtObj.isMapped(hardwareObj,pilObj)
                    ioInterfaceName=tgtObj.getMapping(hardwareObj,pilObj);
                    ioInterfaceObj=hardwareObj.getIOInterface(ioInterfaceName{1});
                    if isempty(ioInterfaceObj)
                        continue
                    end
                    ioInterfaceObj=ioInterfaceObj{1};
                    if isa(ioInterfaceObj,'matlabshared.targetsdk.EthernetInterface')
                        if codertarget.DataModelAdapter.isPIL(attrInfoObj,pilObj.Name,'tcp/ip')
                            continue
                        end
                        attrInfoObj.addPILInfo(pilObj.Name,'tcp/ip',ioInterfaceObj.Name);
                        attrInfoObj.PILInfo{end}.Transport.IPAddress=ioInterfaceObj.IPAddress;
                        attrInfoObj.PILInfo{end}.Transport.Port=num2str(ioInterfaceObj.Port);
                    elseif isa(ioInterfaceObj,'matlabshared.targetsdk.SerialInterface')
                        if codertarget.DataModelAdapter.isPIL(attrInfoObj,pilObj.Name,'serial')
                            continue
                        end
                        attrInfoObj.addPILInfo(pilObj.Name,'serial',ioInterfaceObj.Name);
                        attrInfoObj.PILInfo{end}.Transport.Baudrate=num2str(ioInterfaceObj.DefaultBaudrate);
                        attrInfoObj.PILInfo{end}.Transport.COMPort=ioInterfaceObj.DefaultPort;
                        attrInfoObj.PILInfo{end}.Transport.AvailableBaudrates=ioInterfaceObj.AvailableBaudrates;
                        attrInfoObj.PILInfo{end}.Transport.AvailableCOMPorts=ioInterfaceObj.AvailablePorts;
                    end
                end
            end
        end
        function addProfilerSection(tgtObj,hardwareObj,attrInfoObj)
            allProfilerObjs=tgtObj.getProfiler('mapped',hardwareObj);
            for i=1:numel(allProfilerObjs)
                profObj=allProfilerObjs{i};
                if tgtObj.isMapped(hardwareObj,profObj)
                    attrInfoObj.Profiler.Name=profObj.Name;
                    attrInfoObj.Profiler.TimerSrcFile=profObj.SourceFile;
                    attrInfoObj.Profiler.TimerIncludeFile=profObj.IncludeFile;
                    attrInfoObj.Profiler.TimerReadFcn=profObj.TimerReadFcn;
                    attrInfoObj.Profiler.TimerDataType=profObj.TimerDataType;
                    attrInfoObj.Profiler.BufferName=profObj.BufferName;
                    attrInfoObj.Profiler.GetDataFcn=profObj.GetDataFcn;
                    attrInfoObj.Profiler.TimerUpcounting=num2str(profObj.TimerUpcounting);
                    attrInfoObj.Profiler.StoreCoreId=num2str(profObj.StoreCoreID);
                    attrInfoObj.Profiler.PrintData=num2str(profObj.PrintData);
                    attrInfoObj.Profiler.InstantPrint=num2str(profObj.PrintInstantly);
                    attrInfoObj.Profiler.DataLength=num2str(profObj.DataLength);
                    attrInfoObj.Profiler.TimerTicksPerS=num2str(profObj.TimerTicksPerSecond);
                end
            end
        end
        function depObj=getDeployerforHardware(tgtObj,hwObj)

            depObj=[];
            deployers=tgtObj.getDeployer('mapped');
            for i=1:numel(deployers)
                if tgtObj.isMapped(hwObj,deployers{i})
                    depObj{end+1}=deployers{i};%#ok<AGROW>
                end
            end
        end

        function hwObj=getHardwareObjforHardwareName(tgtObj,hwName)
            hwObj=[];
            hwObjList=tgtObj.getHardware;
            for i=1:numel(hwObjList)
                if isequal(hwObjList{i}.Name,hwName)
                    hwObj=hwObjList{i};
                    break;
                end
            end
        end
        function ret=isPIL(hAttribInfoObj,name,type)
            ret=false;
            assert(ischar(name)&&ischar(type),'Inputs to isPIL must be strings');
            assert(ismember(type,{'serial','tcp/ip','custom'}),'The transport type must be either ''serial'', ''tcp/ip'' or ''custom''');
            for i=1:numel(hAttribInfoObj.PILInfo)
                if isequal(hAttribInfoObj.PILInfo{i}.Name,name)&&...
                    isequal(hAttribInfoObj.PILInfo{i}.Transport.Type,type)
                    ret=true;
                    break;
                end
            end
        end
        function string=randomStringGenerator()
            string=regexprep(tempname,'\\','/');
        end
    end
end

