classdef(Sealed=true)AttributeInfo<codertarget.Info






    properties(SetAccess=private,GetAccess=public)
        DefinitionFileName;
TargetFolder
    end
    properties(Access='public')

        Name='';
        TargetName='';
        TargetInitializationCalls={};
        TargetModelStopCall='';
        TargetTerminationCalls={};
        GlobalInterruptEnableCall='';
        GlobalInterruptDisableCall='';
        IncludeFiles={};
        NeedsMainFcn=true;
        MainFcnSignature='int main(int argc, char **argv)';
        MainFcnArgumentsFcn='';
        Tokens={};
        OnHardwareSelectHook='';
        OnCodeGenEntryHook='';
        OnHardwareDeselectHook='';
        OnBuildEntryHook='';
        OnAfterCodeGenHook='';
        Profiler='';
        EnableOneClick=false;
        ExternalModeInfo=[];
        ExternalModeMonitorAndTuneStateFcn='';
        ExternalModeStepByStepCmdsStateFcn='';
        PILInfo={};
        IOServerInfo={};
        IncludeStdIO=true;
        TargetServices=[];
        DetectOverrun=false;
        DetectOverrunFcn='';
        BackgroundTaskInlinedCode='';
        SchedulerInfoFiles='';
        RTOSInfoFiles='';
        IPCInfoFiles='';
        BuildConfigurationInfo=[];
        HonorRunTimeStopRequest=true;
        SDCardInBackgroundTask=false;

    end
    properties(Dependent=true,SetAccess=private)
SupportsTargetServices
    end
    methods(Access='public')
        function h=AttributeInfo(filePathName)
            if(nargin==1)
                h.DefinitionFileName=filePathName;
                h.TargetFolder=fileparts(fileparts(fileparts(h.DefinitionFileName)));
                h.deserialize;
            end
        end
        function register(h)
            h.serialize;
        end
        function ret=getDefinitionFileName(h)
            ret=h.DefinitionFileName;
        end
        function setDefinitionFileName(h,name)
            h.DefinitionFileName=name;
            h.TargetFolder=fileparts(fileparts(fileparts(h.DefinitionFileName)));
            if isempty(h.TargetFolder)
                h.TargetFolder='.';
            end
        end
        function ret=getName(h)
            ret=h.Name;
        end
        function setName(h,name)
            h.Name=name;
        end
        function ret=getTargetName(h)
            ret=h.TargetName;
        end
        function setTargetName(h,name)
            h.TargetName=name;
        end
        function ret=getTargetInitializationCalls(h)
            ret=h.TargetInitializationCalls;
        end
        function addTargetInitializationCalls(h,call)
            h.TargetInitializationCalls{end+1}=call;
        end
        function value=getHonorRunTimeStopRequest(h)
            value=h.HonorRunTimeStopRequest;
        end
        function setHonorRunTimeStopRequest(h,value)
            h.HonorRunTimeStopRequest=value;
        end
        function value=getSDCardInBackgroundTask(h)
            value=h.SDCardInBackgroundTask;
        end
        function setSDCardInBackgroundTask(h,value)
            h.SDCardInBackgroundTask=value;
        end
        function ret=getTargetModelStopCall(h)
            ret=h.TargetModelStopCall;
        end
        function setTargetModelStopCall(h,call)
            h.TargetModelStopCall=call;
        end
        function ret=getTargetTerminationCalls(h)
            ret=h.TargetTerminationCalls;
        end
        function addTargetTerminationCalls(h,call)
            h.TargetTerminationCalls{end+1}=call;
        end
        function ret=getGlobalInterruptEnableCall(h)
            ret=h.GlobalInterruptEnableCall;
        end
        function setGlobalInterruptEnableCall(h,call)
            h.GlobalInterruptEnableCall=call;
        end
        function ret=getGlobalInterruptDisableCall(h)
            ret=h.GlobalInterruptDisableCall;
        end
        function setGlobalInterruptDisableCall(h,call)
            h.GlobalInterruptDisableCall=call;
        end
        function ret=getLinkFlags(h,varargin)
            bcInfo=h.getBuildConfigurationInfo(varargin{:});
            ret=h.getCombinedStringPropertyForObjects(bcInfo,'LinkFlags');
        end
        function ret=getCompileFlags(h,varargin)
            bcInfo=h.getBuildConfigurationInfo(varargin{:});
            ret=h.getCombinedStringPropertyForObjects(bcInfo,'CompileFlags');
        end
        function ret=getCPPLinkFlags(h,varargin)
            bcInfo=h.getBuildConfigurationInfo(varargin{:});
            ret=h.getCombinedStringPropertyForObjects(bcInfo,'CPPLinkFlags');
        end
        function ret=getCPPCompileFlags(h,varargin)
            bcInfo=h.getBuildConfigurationInfo(varargin{:});
            ret=h.getCombinedStringPropertyForObjects(bcInfo,'CPPCompileFlags');
        end
        function ret=getAssemblyFlags(h,varargin)
            bcInfo=h.getBuildConfigurationInfo(varargin{:});
            ret=h.getCombinedStringPropertyForObjects(bcInfo,'AssemblyFlags');
        end
        function ret=getDefines(h,varargin)
            bcInfo=h.getBuildConfigurationInfo(varargin{:});
            ret={};
            for i=1:numel(bcInfo)
                ret=[ret,bcInfo(i).Defines];
            end
        end
        function addSourceFile(h,fileName,varargin)
            if isempty(h.getBuildConfigurationInfo)
                valueToSet.Name=[h.Name,' LegacyBuildConfiguration'];
                h.addNewBuildConfigurationInfo(valueToSet);
            end
            bcInfo=h.getBuildConfigurationInfo(varargin{:});
            for i=1:numel(bcInfo)
                bcInfo(i).SourceFiles{end+1}=fileName;
            end
        end
        function ret=getSourceFiles(h,varargin)
            bcInfo=h.getBuildConfigurationInfo(varargin{:});
            ret={};
            for i=1:numel(bcInfo)
                ret=[ret,bcInfo(i).SourceFiles];
            end
        end
        function addExternalModeInfo(h,name,type,interfaceName)
            assert(ischar(name)&&ischar(type),'Inputs to addExternalModeInfo must be strings');
            assert(ismember(type,{'serial','tcp/ip','can','custom'}),'The transport type must be either ''serial'',''tcp/ip'',''can'' or ''custom''');
            transportStruct=struct('type',type,'name',name,'iointerfacename',interfaceName);
            ExternalModeInfoStruct=struct('name',interfaceName,...
            'transport',transportStruct);
            if isempty(h.ExternalModeInfo)
                h.ExternalModeInfo=codertarget.attributes.ExternalModeInfo(ExternalModeInfoStruct,h.TargetFolder);
            else
                if~h.EnableOneClick
                    DAStudio.error('codertarget:targetapi:MultipleExtModeWithoutOneClick');
                end
                h.ExternalModeInfo(end+1)=codertarget.attributes.ExternalModeInfo(ExternalModeInfoStruct,h.TargetFolder,true);
            end
        end
        function addPILInfo(h,name,type,interfaceName)
            assert(ischar(name)&&ischar(type),'Inputs to addPILInfo must be strings');
            assert(ismember(type,{'serial','tcp/ip','custom'}),'The transport type must be either ''serial'',''tcp/ip'' or ''custom''');
            h.PILInfo{end+1}=struct('Name',name,'Transport',[]);
            switch type
            case 'serial'
                h.PILInfo{end}.Transport=struct('Type',type,'Name',name,...
                'IOInterfaceName',interfaceName,'COMPort','','Baudrate','');
                h.PILInfo{end}.Transport.COMPort='COM1';
                h.PILInfo{end}.Transport.Baudrate='115200';
                h.PILInfo{end}.Transport.AvailableCOMPorts={'COM1'};
                h.PILInfo{end}.Transport.AvailableBaudrates=115200;
            case 'tcp/ip'
                h.PILInfo{end}.Transport=struct('Type',type,'Name',name,...
                'IOInterfaceName',interfaceName,'IPAddress','','Port','');
                h.PILInfo{end}.Transport.IPAddress='10.10.10.1';
                h.PILInfo{end}.Transport.Port='22';
            case 'custom'
                assert(false,'The method addPILInfo called with an invalid PIL type.');
            end
        end
        function addIOServerInfo(h,name,toolchainName,type,interfaceName)
            assert(ischar(name)&&ischar(type),'Inputs to addIOServerInfo must be strings');
            assert(ismember(type,{'tcp/ip'}),'The transport type must be ''tcp/ip''');
            h.IOServerInfo{end+1}=struct('Name',name,'ToolchainName',toolchainName,'Transport',[]);
            switch type
            case 'tcp/ip'
                h.IOServerInfo{end}.Transport=struct('Type',type,'Name',name,...
                'IOInterfaceName',interfaceName,'IPAddress','','Port','');
                h.IOServerInfo{end}.Transport.IPAddress='10.10.10.1';
                h.IOServerInfo{end}.Transport.Port='22';
            case 'custom'
                assert(false,'The method addIOServerInfo called with an invalid IOServer type.');
            end
        end
        function ret=isExternalMode(h,name,type)
            ret=false;
            assert(ischar(name)&&ischar(type),'Inputs to isExternalMode must be strings');
            assert(ismember(type,{'serial','tcp/ip','can','custom'}),'The transport type must be either ''serial'',''tcp/ip'',''can'' or ''custom''');
            for i=1:numel(h.ExternalModeInfo)
                if isequal(h.ExternalModeInfo(i).Name,name)&&...
                    isequal(h.ExternalModeInfo(i).Transport.Type,type)
                    ret=true;
                    break;
                end
            end
        end
        function ret=isPIL(h,name,type)
            ret=false;
            assert(ischar(name)&&ischar(type),'Inputs to isPIL must be strings');
            assert(ismember(type,{'serial','tcp/ip','custom'}),'The transport type must be either ''serial'',''tcp/ip'' or ''custom''');
            for i=1:numel(h.PILInfo)
                if isequal(h.PILInfo{i}.Name,name)&&...
                    isequal(h.PILInfo{i}.Transport.type,type)
                    ret=true;
                    break;
                end
            end
        end
        function ret=getExternalModeSourceFiles(h,aIOInterfaceName)
            idx=1;
            if nargin>1
                lIOInterfaceName=h.ExternalModeInfo.getIOInterfaceNames;
                [~,idx,~]=intersect(lIOInterfaceName,aIOInterfaceName);
                if isempty(idx)
                    ret={};
                    return;
                end
            end
            ret=h.ExternalModeInfo(idx).SourceFiles;
        end
        function addExternalModeSourceFile(h,file,aIOInterfaceName)
            idx=1;
            if nargin>2
                lIOInterfaceName=h.ExternalModeInfo.getIOInterfaceNames;
                [~,idx,~]=intersect(lIOInterfaceName,aIOInterfaceName);
                if isempty(idx)
                    return;
                end
            end
            h.ExternalModeInfo(idx).SourceFiles{end+1}=file;
        end
        function ret=getIncludeFiles(h)
            ret=h.IncludeFiles;
        end
        function addIncludeFile(h,file)
            h.IncludeFiles{end+1}=file;
        end
        function ret=getIncludePaths(h,varargin)
            bcInfo=h.getBuildConfigurationInfo(varargin{:});
            ret={};
            for i=1:numel(bcInfo)
                ret=[ret,bcInfo(i).IncludePaths];
            end
        end
        function ret=getPathsToRemove(h,varargin)
            bcInfo=h.getBuildConfigurationInfo(varargin{:});
            ret={};
            for i=1:numel(bcInfo)
                ret=[ret,bcInfo(i).PathsToRemove];
            end
        end
        function ret=getNeedsMainFcn(h)
            ret=h.NeedsMainFcn;
        end
        function ret=getMainFcnSignature(h)
            ret=h.MainFcnSignature;
        end
        function setMainFcnSignature(h,val)
            h.MainFcnSignature=val;
        end
        function ret=getMainFcnArgumentsFcn(h)
            ret=h.MainFcnArgumentsFcn;
        end
        function setMainFcnArgumentsFcn(h,val)
            h.MainFcnArgumentsFcn=val;
        end
        function ret=getLinkObjects(h,varargin)
            bcInfo=h.getBuildConfigurationInfo(varargin{:});
            ret={};
            for i=1:numel(bcInfo)
                linkObjects=bcInfo(i).LinkObjects;
                for j=1:numel(linkObjects)
                    if~isstruct(linkObjects{j})
                        [pathStr,name,ext]=fileparts(linkObjects{j});
                        newElem.Name=[name,ext];
                        newElem.Path=pathStr;
                        ret=[ret,newElem];
                    else
                        ret=[ret,linkObjects{j}];
                    end
                end
            end
        end
        function ret=getSourceFilesToSkip(h,varargin)
            bcInfo=h.getBuildConfigurationInfo(varargin{:});
            ret={};
            for i=1:numel(bcInfo)
                ret=[ret,bcInfo(i).SourceFilesToSkip];
            end
        end
        function ret=getExternalModeInfoForIOInterface(h,ioInterfaceName)
            if isequal(ioInterfaceName,'firstandonly')
                idx=1;
            else
                ioInterfaceNames=h.ExternalModeInfo.getIOInterfaceNames;
                [~,idx,~]=intersect(ioInterfaceNames,ioInterfaceName);
                if isempty(idx)
                    ret={};
                    return;
                end
            end
            ret=h.ExternalModeInfo(idx);
        end
        function ret=getExternalModeSourceFilesToSkip(h,ioInterfaceName)
            idx=1;
            if nargin>1
                lIOInterfaceName=h.ExternalModeInfo.getIOInterfaceNames;
                [~,idx,~]=intersect(lIOInterfaceName,ioInterfaceName);
                if isempty(idx)
                    ret={};
                    return;
                end
            end
            ret=h.ExternalModeInfo(idx).SourceFilesToSkip;
        end
        function addExternalModeSourceFileToSkip(h,file,ioInterfaceName)
            idx=1;
            if nargin>2
                lIOInterfaceName=h.ExternalModeInfo.getIOInterfaceNames;
                [~,idx,~]=intersect(lIOInterfaceName,ioInterfaceName);
                if isempty(idx)
                    return;
                end
            end
            h.ExternalModeInfo(idx).SourceFilesToSkip{end+1}=file;
        end
        function ret=getTokens(h)
            ret=h.Tokens;
        end
        function addToken(h,token)
            if~isempty(token)
                if iscell(token)
                    for i=1:numel(token)
                        h.addToken(token{i});
                    end
                elseif~isstruct(token)
                    assert(ischar(token),'Wrong datatype for token');
                    h.Tokens{end+1}.Name=token;
                    h.Tokens{end}.Value='';
                elseif isfield(token,'Name')&&isfield(token,'Value')
                    for i=1:numel(token)
                        h.Tokens{end+1}.Name=token(i).Name;
                        h.Tokens{end}.Value=token(i).Value;
                    end
                end
            end
        end
        function ret=getOnHardwareSelectHook(h)
            ret=h.OnHardwareSelectHook;
        end
        function setOnHardwareSelectHook(h,name)
            h.OnHardwareSelectHook=name;
        end
        function ret=getOnCodeGenEntryHook(h)
            ret=h.OnCodeGenEntryHook;
        end
        function setOnCodeGenEntryHook(h,name)
            h.OnCodeGenEntryHook=name;
        end
        function ret=getOnHardwareDeselectHook(h)
            ret=h.OnHardwareDeselectHook;
        end
        function setOnHardwareDeselectHook(h,name)
            h.OnHardwareDeselectHook=name;
        end
        function ret=getOnBuildEntryHook(h)
            ret=h.OnBuildEntryHook;
        end
        function setOnBuildEntryHook(h,name)
            h.OnBuildEntryHook=name;
        end
        function ret=getOnAfterCodeGenHook(h)
            ret=h.OnAfterCodeGenHook;
        end
        function setOnAfterCodeGenHook(h,name)
            h.OnAfterCodeGenHook=name;
        end
        function addTargetService(hObj,bcfile,IOInterfaceName)
            if numel(hObj.TargetServices)>0
                hObj.TargetServices(end+1)=codertarget.targetservices.TargetService(struct('buildconfigurationinfofile',bcfile,'iointerfacename',IOInterfaceName),hObj.TargetFolder);
            else
                hObj.TargetServices=codertarget.targetservices.TargetService(struct('buildconfigurationinfofile',bcfile,'iointerfacename',IOInterfaceName),hObj.TargetFolder);
            end
        end
        function out=getTargetService(hObj,varargin)
            out=[];
            if hObj.SupportsTargetServices
                out=getTargetService(hObj.TargetServices,varargin{:});
            end
        end
        function ret=getDetectOverrun(h)
            ret=h.DetectOverrun;
        end
        function setDetectOverrun(h,name)
            h.DetectOverrun=name;
        end
        function ret=getDetectOverrunFcn(h)
            ret=h.DetectOverrunFcn;
        end
        function setDetectOverrunFcn(h,name)
            h.DetectOverrunFcn=name;
        end
        function ret=supportsAppService(obj,hModel,AppSvcName)
            ret=false;
            if nargin>1
                if obj.SupportsTargetServices
                    q=obj.TargetServices.getApplicationService(hModel,AppSvcName);
                    if~isempty(q)
                        ret=true;
                    end
                end
            else
                if obj.SupportsTargetServices&&obj.TargetServices(1).ApplicationServices.isKey(AppSvcName)
                    ret=true;
                end
            end
        end

        function setExternalModeMonitorAndTuneStateFcn(h,name)
            h.ExternalModeMonitorAndTuneStateFcn=name;
        end

        function name=getExternalModeMonitorAndTuneStateFcn(h)
            name=h.ExternalModeMonitorAndTuneStateFcn;
        end

        function setExternalModeStepByStepCmdsStateFcn(h,name)
            h.ExternalModeStepByStepCmdsStateFcn=name;
        end

        function name=getExternalModeStepByStepCmdsStateFcn(h)
            name=h.ExternalModeStepByStepCmdsStateFcn;
        end
    end
    methods(Access='public',Hidden)
        function addNewBuildConfigurationInfo(h,valueToSet)
            bcObj=codertarget.attributes.BuildConfigurationInfo;
            bcObj.set(valueToSet);
            h.addNewElementToArrayProperty(h,'BuildConfigurationInfo',bcObj);
        end
        function allBCs=getBuildConfigurationInfo(h,varargin)
            p=inputParser;
            p.addParameter('os','any');
            p.addParameter('toolchain','any');
            p.parse(varargin{:});
            current=p.Results;
            allBCs=[];
            for i=1:numel(h.BuildConfigurationInfo)
                bcObj=h.BuildConfigurationInfo(i);
                isSupportedOS=isequal(current.os,'any')||...
                isequal(bcObj.SupportedOperatingSystems,{'all'})||...
                ismember(current.os,bcObj.SupportedOperatingSystems);
                isSupportedToolchain=isequal(current.toolchain,'any')||...
                isequal(bcObj.SupportedToolchains,{'all'})||...
                ismember(current.toolchain,bcObj.SupportedToolchains);
                if isSupportedOS&&isSupportedToolchain
                    allBCs=[allBCs,bcObj];
                end
            end
        end
    end
    methods(Access='private')
        function ret=getCombinedStringPropertyForObjects(~,objs,propName)
            ret='';
            for i=1:numel(objs)
                addValues=objs(i).(propName);
                if~isempty(addValues)
                    if isempty(ret)
                        ret=strcat(ret,' ');
                    end
                    ret=strcat(ret,addValues);%#ok<*AGROW>
                end
            end
        end
        function p=getDefaultProfilerAttributes(~)
            ret.names={'Name','TimerSrcFile','TimerIncludeFile','TimerReadFcn',...
            'TimerDataType','TimerTicksPerS','TimerUpcounting',...
            'StoreCoreId','PrintData','InstantPrint','BufferName','NumberOfBuffers'...
            ,'DataLength','GetDataFcn'};
            ret.values={'','','','',...
            'uint32',1,1,...
            1,1,0,'profilingData',10,...
            400,''};
            for i=1:length(ret.names)
                p.(ret.names{i})=ret.values{i};
            end
        end
        function ret=getShortDefinitionFileName(h)
            [~,name,ext]=fileparts(h.DefinitionFileName);
            ret=[name,ext];
        end
        function setExternalModeInfo(h,inValue)
            for ii=1:numel(inValue)
                value=inValue(ii);
                if ii==1
                    h.ExternalModeInfo=codertarget.attributes.ExternalModeInfo(value,h.TargetFolder,h.EnableOneClick);
                else
                    h.ExternalModeInfo(end+1)=codertarget.attributes.ExternalModeInfo(value,h.TargetFolder,h.EnableOneClick);
                end
            end
        end
        function setPILInfo(h,valueToSet)
            for i=1:numel(valueToSet)
                value=valueToSet(i);
                if isfield(value,'Transport')&&isstruct(value.Transport)&&...
                    isfield(value.Transport,'Name')&&...
                    isfield(value.Transport,'Type')&&...
                    isfield(value.Transport,'IOInterfaceName')
                    h.addPILInfo(value.Transport.Name,value.Transport.Type,value.Transport.IOInterfaceName)
                    h.PILInfo{i}.Name=value.Name;
                    if isequal(value.Transport.Type,'serial')&&...
                        isfield(value.Transport,'AvailableCOMPorts')&&...
                        isfield(value.Transport,'AvailableBaudrates')
                        h.PILInfo{i}.Transport.AvailableCOMPorts=value.Transport.AvailableCOMPorts;
                        h.PILInfo{i}.Transport.AvailableBaudrates=value.Transport.AvailableBaudrates;
                    end
                else
                    DAStudio.error('codertarget:targetapi:StructureInputInvalid','pilinfo.transport','Name, Type, IOInterfaceName, AvailableCOMPorts, and AvailableBaudrates');
                end
            end
        end
        function setIOServerInfo(h,valueToSet)
            for i=1:numel(valueToSet)
                value=valueToSet(i);
                if isfield(value,'Transport')&&isfield(value,'ToolchainName')&&isstruct(value.Transport)&&...
                    isfield(value.Transport,'Name')&&...
                    isfield(value.Transport,'Type')&&...
                    isfield(value.Transport,'IOInterfaceName')
                    h.addIOServerInfo(value.Transport.Name,value.ToolchainName,value.Transport.Type,value.Transport.IOInterfaceName)
                    h.IOServerInfo{i}.Name=value.Name;
                    if isequal(value.Transport.Type,'tcp/ip')&&...
                        isfield(value.Transport,'IPAddress')&&...
                        isfield(value.Transport,'Port')
                        h.IOServerInfo{i}.Transport.IPAddress=value.Transport.IPAddress;
                        h.IOServerInfo{i}.Transport.Port=value.Transport.Port;
                    end
                    if isfield(value,'Peripherals')
                        h.IOServerInfo{i}.Peripherals=value.Peripherals;
                    else
                        h.IOServerInfo{i}.Peripherals={};
                    end
                else
                    DAStudio.error('codertarget:targetapi:StructureInputInvalid','IOServerinfo.transport','Name, Type, IOInterfaceName, Peripherals, IPAddress, and Port');
                end
            end
        end
        function ret=getPILInfo(h)
            ret=h.PILInfo;
        end
        function ret=getIOServerInfo(h)
            ret=h.IOServerInfo;
        end
        function ret=getSchedulerInfoFiles(h)
            ret=h.SchedulerInfoFiles;
        end
        function names=getSchedulerFilePaths(h)
            schedulers=h.getSchedulerInfoFiles;
            names=cell(1,length(schedulers));
            for i=1:numel(schedulers)
                names{i}=h.getRegistryPathName('schedulers',schedulers{i});
            end
        end
        function ret=getRTOSInfoFiles(h)
            ret=h.RTOSInfoFiles;
        end
        function names=getRTOSFilePaths(h)
            rtos=h.getRTOSInfoFiles;
            names=cell(1,length(rtos));
            for i=1:numel(rtos)
                names{i}=h.getRegistryPathName('rtos',rtos{i});
            end
        end
        function ret=getIPCInfoFiles(h)
            ret=h.IPCInfoFiles;
        end
        function names=getIPCFilePaths(h)
            ipc=h.getIPCInfoFiles;
            names=cell(1,length(ipc));
            for i=1:numel(ipc)
                names{i}=h.getRegistryPathName('ipc',ipc{i});
            end
        end
        function serialize(h)
            docObj=h.createDocument('productinfo');
            docObj.item(0).setAttribute('version','3.0');
            h.setElement(docObj,'name',h.getName);
            h.setElement(docObj,'targetname',h.getTargetName);
            h.setElement(docObj,'targetinitializationcall',h.getTargetInitializationCalls);
            h.setElement(docObj,'targetmodelstopcall',h.getTargetModelStopCall);
            h.setElement(docObj,'targetterminationcall',h.getTargetTerminationCalls);
            h.setElement(docObj,'globalinterruptenablecall',h.getGlobalInterruptEnableCall);
            h.setElement(docObj,'globalinterruptdisablecall',h.getGlobalInterruptDisableCall);
            h.setElement(docObj,'pilinfo',h.getPILInfo);
            h.setElement(docObj,'ioserverinfo',h.getIOServerInfo);
            h.setElement(docObj,'includefile',h.getIncludeFiles);
            h.setElement(docObj,'needsmainfcn',h.getNeedsMainFcn);
            h.setElement(docObj,'mainfcnsignature',h.getMainFcnSignature);
            h.setElement(docObj,'mainfcnargumentsfcn',h.getMainFcnArgumentsFcn);
            h.setElement(docObj,'token',h.getTokens);
            h.setElement(docObj,'onhardwareselecthook',h.getOnHardwareSelectHook);
            h.setElement(docObj,'oncodegenentryhook',h.getOnCodeGenEntryHook);
            h.setElement(docObj,'onhardwaredeselecthook',h.getOnHardwareDeselectHook);
            h.setElement(docObj,'onbuildentryhook',h.getOnBuildEntryHook);
            h.setElement(docObj,'onaftercodegenhook',h.getOnAfterCodeGenHook);
            h.setElement(docObj,'profiler',h.Profiler);
            h.setElement(docObj,'detectoverrun',h.getDetectOverrun);
            h.setElement(docObj,'detectoverrunfcn',h.getDetectOverrunFcn);
            h.setElement(docObj,'honorruntimestoprequest',h.getHonorRunTimeStopRequest);
            h.setElement(docObj,'sdcardinbackgroundtask',h.getSDCardInBackgroundTask);
            h.setElement(docObj,'backgroundtaskinlinedcode',h.BackgroundTaskInlinedCode);
            h.setElement(docObj,'scheduler',h.getSchedulerInfoFiles);
            h.setElement(docObj,'rtosinfo',h.getRTOSInfoFiles);
            h.setElement(docObj,'ipcinfo',h.getIPCInfoFiles);
            h.setElement(docObj,'includestdio',h.IncludeStdIO);
            h.setElement(docObj,'enableoneclick',h.EnableOneClick);
            h.setElement(docObj,'externalmodemonitorandtunestatefcn',h.getExternalModeMonitorAndTuneStateFcn);
            h.setElement(docObj,'externalmodestepbystepcmdsstatefcn',h.getExternalModeStepByStepCmdsStateFcn);
            targetName=h.getTargetName;
            targetFolder=codertarget.target.getTargetFolder(targetName);
            if~isempty(targetFolder)
                h.TargetFolder=targetFolder;
            end
            if~isempty(h.ExternalModeInfo)
                h.ExternalModeInfo.serialize();
                h.setElement(docObj,'externalmodeinfo',h.ExternalModeInfo.toStruct());
            end
            if~isempty(h.TargetServices)
                h.setElement(docObj,'targetservice',h.TargetServices.toStruct());
                h.TargetServices.serialize();
            end
            attributesFolder=codertarget.target.getAttributeRegistryFolder(h.TargetFolder);
            attributesName=fullfile(attributesFolder,h.getShortDefinitionFileName);
            attributesName=codertarget.utils.replacePathSep(attributesName);
            for i=1:numel(h.BuildConfigurationInfo)
                bcObj=h.BuildConfigurationInfo(i);
                fileName=codertarget.internal.makeValidFileName(bcObj.Name);
                absoluteFilename=[h.TargetFolder,'/registry/attributes/',fileName,'.xml'];
                bcObj.DefinitionFileName=absoluteFilename;
                bcObj.serialize();
                relativeFileName=['$(TARGET_ROOT)','/registry/attributes/',fileName,'.xml'];
                relativeFileName=codertarget.utils.replacePathSep(relativeFileName);
                h.setElement(docObj,'buildconfigurationinfofile',relativeFileName);
            end
            h.write(attributesName,docObj);
        end
        function deserializeBuildConfiguration(h,rootItem,version)
            [attributesFolder,~,~]=fileparts(h.DefinitionFileName);
            switch(version)
            case '3.0'
                bcInfoFiles=h.getElement(rootItem,'buildconfigurationinfofile','cell');
                for i=1:numel(bcInfoFiles)
                    [~,name,ext]=fileparts(bcInfoFiles{i});
                    bcFile=fullfile(attributesFolder,[name,ext]);
                    bcObj=codertarget.attributes.BuildConfigurationInfo(bcFile);
                    h.addNewBuildConfigurationInfo(bcObj.get);
                end
            otherwise
                bcname=h.getElement(rootItem,'buildconfigurationname','char');
                if isempty(bcname)
                    bcname=[h.Name,' Build Config'];
                end
                bcInfo.Name=bcname;
                bcInfo.AssemblyFlags=h.getElement(rootItem,'assemblyflags','char');
                bcInfo.CompileFlags=h.getElement(rootItem,'compileflags','char');
                bcInfo.CPPCompileFlags=h.getElement(rootItem,'cppcompileflags','char');
                bcInfo.CPPLinkFlags=h.getElement(rootItem,'cpplinkflags','char');
                bcInfo.Defines=h.getElement(rootItem,'define','cell');
                bcInfo.IncludePaths=h.getElement(rootItem,'includepath','cell');
                bcInfo.LinkFlags=h.getElement(rootItem,'linkflags','char');
                bcInfo.PathsToRemove=h.getElement(rootItem,'pathstoremove','cell');
                bcInfo.SourceFiles=h.getElement(rootItem,'sourcefile','cell');
                bcInfo.SourceFilesToSkip=h.getElement(rootItem,'sourcefiletoskip','cell');
                bcInfo.LinkObjects={};
                allItems=rootItem.getElementsByTagName('linkobject');
                for i=0:allItems.getLength-1
                    item=allItems.item(i);
                    child1=item.getElementsByTagName('linkobjectname');
                    child2=item.getElementsByTagName('linkobjectpath');
                    if(child1.getLength==1)&&(child2.getLength==1)
                        linkObj=[];
                        a=child1.item(0);
                        b=child2.item(0);
                        linkObj.Name=char(a.getFirstChild.getData);
                        linkObj.Path=char(b.getFirstChild.getData);
                        bcInfo.LinkObjects{end+1}=linkObj;
                    end
                end
                h.addNewBuildConfigurationInfo(bcInfo);
            end
        end
        function deserializeCurrent(h,rootItem,productVersion)
            h.Name=h.getElement(rootItem,'name','char');
            h.TargetName=h.getElement(rootItem,'targetname','char');
            h.TargetInitializationCalls=h.getElement(rootItem,'targetinitializationcall','cell');
            h.TargetModelStopCall=h.getElement(rootItem,'targetmodelstopcall','char');
            h.TargetTerminationCalls=h.getElement(rootItem,'targetterminationcall','cell');
            h.GlobalInterruptEnableCall=h.getElement(rootItem,'globalinterruptenablecall','char');
            h.GlobalInterruptDisableCall=h.getElement(rootItem,'globalinterruptdisablecall','char');
            h.IncludeFiles=h.getElement(rootItem,'includefile','cell');
            val=h.getElement(rootItem,'needsmainfcn','logical');
            if islogical(val)
                h.NeedsMainFcn=val;
            end
            h.MainFcnSignature=h.getElement(rootItem,'mainfcnsignature','char');
            h.MainFcnArgumentsFcn=h.getElement(rootItem,'mainfcnargumentsfcn','char');
            h.addToken(h.getElement(rootItem,'token','cell'));
            h.OnHardwareSelectHook=h.getElement(rootItem,'onhardwareselecthook','char');
            h.OnCodeGenEntryHook=h.getElement(rootItem,'oncodegenentryhook','char');
            h.OnHardwareDeselectHook=h.getElement(rootItem,'onhardwaredeselecthook','char');
            h.OnBuildEntryHook=h.getElement(rootItem,'onbuildentryhook','char');
            h.OnAfterCodeGenHook=h.getElement(rootItem,'onaftercodegenhook','char');
            h.EnableOneClick=h.getElement(rootItem,'enableoneclick','logical');
            h.ExternalModeMonitorAndTuneStateFcn=h.getElement(rootItem,'externalmodemonitorandtunestatefcn','char');
            h.ExternalModeStepByStepCmdsStateFcn=h.getElement(rootItem,'externalmodestepbystepcmdsstatefcn','char');
            h.setExternalModeInfo(h.getElement(rootItem,'externalmodeinfo','struct'));
            h.setPILInfo(h.getElement(rootItem,'pilinfo','struct'));
            h.setIOServerInfo(h.getElement(rootItem,'ioserverinfo','struct'));
            h.Profiler=h.getElement(rootItem,'profiler','struct');
            h.DetectOverrun=h.getElement(rootItem,'detectoverrun','logical');
            h.DetectOverrunFcn=h.getElement(rootItem,'detectoverrunfcn','char');
            h.TargetServices=h.getElement(rootItem,'targetservice','struct');
            h.IncludeStdIO=h.getElement(rootItem,'includestdio','char');
            val=h.getElement(rootItem,'honorruntimestoprequest','logical');
            if islogical(val)
                h.HonorRunTimeStopRequest=val;
            end
            val=h.getElement(rootItem,'sdcardinbackgroundtask','logical');
            if islogical(val)
                h.SDCardInBackgroundTask=val;
            end
            h.BackgroundTaskInlinedCode=h.getElement(rootItem,'backgroundtaskinlinedcode','char');
            h.SchedulerInfoFiles=h.getElement(rootItem,'scheduler','cell');
            h.RTOSInfoFiles=h.getElement(rootItem,'rtosinfo','cell');
            h.IPCInfoFiles=h.getElement(rootItem,'ipcinfo','cell');
            if~isempty(h.Profiler)&&~isfield(h.Profiler,'Name')
                h.Profiler.Name=[h.Name,' Profiler'];
            end
            h.deserializeBuildConfiguration(rootItem,productVersion);
        end
        function deserialize(h)
            docObj=h.read(h.DefinitionFileName);
            prodInfoList=docObj.getElementsByTagName('productinfo');
            rootItem=prodInfoList.item(0);
            prodInfo=struct;
            if rootItem.hasAttributes
                prodInfo.(char(rootItem.getAttributes.item(0).getName()))=...
                char(rootItem.getAttributes.item(0).getValue());
            end
            if~isfield(prodInfo,'version')
                prodInfo=struct('version','1.0');
            end
            switch(prodInfo.version)
            case '1.0'
                h.deserializeCurrent(rootItem,prodInfo.version);
                h.EnableOneClick=false;
                h.ExternalModeInfo.SourceFiles=h.getElement(rootItem,'externalmodesourcefile','cell');
                h.ExternalModeInfo.SourceFilesToSkip=h.getElement(rootItem,'externalmodesourcefiletoskip','cell');
            otherwise
                h.deserializeCurrent(rootItem,prodInfo.version);
            end
        end
    end
    methods
        function set.TargetFolder(h,val)
            if~ischar(val)
                DAStudio.error('codertarget:targetapi:InvalidStringProperty','TargetFolder');
            end
            h.TargetFolder=val;
            for ii=1:numel(h.ExternalModeInfo)%#ok<MCSUP>
                h.ExternalModeInfo(ii).TargetFolder=val;%#ok<MCSUP>
            end
            for ii=1:numel(h.TargetServices)%#ok<MCSUP>
                h.TargetServices(ii).TargetFolder=val;%#ok<MCSUP>
            end
        end
        function set.EnableOneClick(obj,val)
            if~ischar(val)&&~islogical(val)
                DAStudio.error('codertarget:targetapi:InvalidLogicalProperty','EnableOneClick');
            end
            if isempty(val)
                val=false;
            elseif ischar(val)
                val=~isequal(val,'false')&&~isequal(val,'0');
            end
            obj.EnableOneClick=val;
        end
        function set.IncludeStdIO(obj,val)



            if~ischar(val)&&~islogical(val)
                DAStudio.error('codertarget:targetapi:InvalidLogicalProperty','IncludeStdIO');
            end
            if isempty(val)
                val=true;
            elseif ischar(val)
                val=~isequal(val,'false')&&~isequal(val,'0');
            end
            obj.IncludeStdIO=val;
        end
        function set.TargetServices(obj,val)
            if isa(val,'codertarget.targetservices.TargetService')
                obj.TargetServices=val;
            elseif isempty(val)
                obj.TargetServices=[];
            else
                for ii=1:numel(val)
                    if isstruct(val)
                        p=codertarget.targetservices.TargetService(val(ii),obj.TargetFolder);%#ok<MCSUP>
                    elseif iscell(val)
                        p=codertarget.targetservices.TargetService(val{ii},obj.TargetFolder);%#ok<MCSUP>
                    else
                        continue;
                    end
                    if ii==1
                        obj.TargetServices=p;
                    else
                        obj.TargetServices(ii)=p;
                    end
                end
            end
        end
        function out=get.SupportsTargetServices(obj)
            out=~isempty(obj.TargetServices);
        end
        function set.BackgroundTaskInlinedCode(obj,value)
            if isempty(value)
                value='';
            end
            if~ischar(value)
                DAStudio.error('codertarget:targetapi:InvalidStringProperty','BackgroundTaskInlinedCode');
            end
            obj.BackgroundTaskInlinedCode=value;
        end
    end
end
