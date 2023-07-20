classdef(Sealed=true)ExternalModeInfo<matlab.mixin.SetGet





    properties
        TargetFolder='';

        ModelParameter=struct('name',{},'value',{},'callback',{})
        CoderTargetParameter=struct('name',{},'value',{},'callback',{})
        Transport=[]
        ProtocolConfiguration=[]
        PreConnectFcn=''
        ConnectFcn=''
        SetupFcn=''
        CloseFcn=''
        Task=[];
        BuildConfigurationInfo=[];
        PostDisconnectTargetFcn=''
    end

    properties(Dependent)
SourceFilesToSkip
SourceFiles
Name
    end

    properties(Dependent,SetAccess=private)
Protocol
    end


    methods(Access={?codertarget.attributes.AttributeInfo})
        function h=ExternalModeInfo(structVal,targetfolder,enableOneClick)
            if isstruct(structVal)
                h.TargetFolder=targetfolder;
                if nargin<3
                    enableOneClick=true;
                end
                if isfield(structVal,'buildconfigurationinfofile')
                    bcInfoFiles=cellstr(strrep(structVal.buildconfigurationinfofile,'$(TARGET_ROOT)',targetfolder));
                    for i=1:numel(bcInfoFiles)
                        bc=codertarget.attributes.BuildConfigurationInfo(bcInfoFiles{i});
                        if isempty(h.BuildConfigurationInfo)
                            h.BuildConfigurationInfo=bc;
                        else
                            h.BuildConfigurationInfo(end+1)=bc;
                        end
                    end
                else
                    h.BuildConfigurationInfo=codertarget.attributes.BuildConfigurationInfo;
                    if isfield(structVal,'sourcefile')
                        h.BuildConfigurationInfo(1).SourceFiles=structVal.sourcefile;
                    end
                    if isfield(structVal,'sourcefiletoskip')
                        h.BuildConfigurationInfo(1).SourceFilesToSkip=structVal.sourcefiletoskip;
                    end
                    try
                        if isfield(structVal.transport,'iointerfacename')
                            h.BuildConfigurationInfo(1).Name=structVal.transport.iointerfacename;
                        else
                            h.BuildConfigurationInfo(1).Name=structVal.transport.name;
                        end
                    catch

                    end
                    h.BuildConfigurationInfo(1).DefinitionFileName=fullfile('$(TARGET_ROOT)/registry/attributes/',[regexprep(h.BuildConfigurationInfo(1).Name,'\W',''),'_ExternalModeBuildConfig.xml']);
                end
                if isfield(structVal,'inbackgroundtask')&&~isempty(structVal.inbackgroundtask)
                    h.Task=codertarget.attributes.TaskInfo(structVal.inbackgroundtask);
                elseif isfield(structVal,'task')&&~isempty(structVal.task)
                    h.Task=codertarget.attributes.TaskInfo(structVal.task);
                else
                    h.Task=codertarget.attributes.TaskInfo;
                end


                if isfield(structVal,'transport')
                    h.Transport=structVal.transport;
                elseif enableOneClick

                    DAStudio.error('codertarget:targetapi:ExternalModeTransportNotSpecified');
                end


                if isfield(structVal,'protocolconfiguration')
                    h.ProtocolConfiguration=structVal.protocolconfiguration;
                end
                if enableOneClick&&isfield(structVal,'modelparameter')
                    h.ModelParameter=structVal.modelparameter;
                end
                if enableOneClick&&isfield(structVal,'codertargetparameter')
                    h.CoderTargetParameter=structVal.codertargetparameter;
                end
                if enableOneClick&&isfield(structVal,'preconnectfcn')
                    h.PreConnectFcn=structVal.preconnectfcn;
                end
                if enableOneClick&&isfield(structVal,'connectfcn')
                    h.ConnectFcn=structVal.connectfcn;
                end
                if enableOneClick&&isfield(structVal,'setupfcn')
                    h.SetupFcn=structVal.setupfcn;
                end
                if enableOneClick&&isfield(structVal,'closefcn')
                    h.CloseFcn=structVal.closefcn;
                end
                if enableOneClick&&isfield(structVal,'postdisconnecttargetfcn')
                    h.PostDisconnectTargetFcn=structVal.postdisconnecttargetfcn;
                end
            end
        end
    end
    methods
        function out=getIOInterfaceNames(h)
            out=cell(size(h));
            for ii=1:numel(h)
                if~isempty(h(ii).Transport)
                    out{ii}=h(ii).Transport.IOInterfaceName;
                else
                    out{ii}='###';
                end
            end
        end
        function serialize(hIn)
            for ii=1:numel(hIn)
                h=hIn(ii);
                for jj=1:numel(h.BuildConfigurationInfo)
                    bcObj=h.BuildConfigurationInfo(jj);
                    if isempty(bcObj.DefinitionFileName)
                        fileName=codertarget.internal.makeValidFileName(bcObj.Name);
                    else
                        [~,fileName]=fileparts(bcObj.DefinitionFileName);
                    end
                    absoluteFilename=[h.TargetFolder,'/registry/attributes/',fileName,'.xml'];
                    bcObj.DefinitionFileName=absoluteFilename;
                    bcObj.serialize;
                end
            end
        end
    end

    methods
        function set.Name(obj,val)
            if~ischar(val)
                DAStudio.error('codertarget:targetapi:InvalidStringProperty','Name');
            end
            obj.Transport.IOInterfaceName=val;
        end
        function val=get.Name(obj)
            val=obj.Transport.IOInterfaceName;
        end
        function set.Transport(obj,val)
            if~isa(val,'codertarget.attributes.IOInterface')
                if~isstruct(val)||~isfield(val,'type')||...
                    ~isfield(val,'name')
                    DAStudio.error('codertarget:targetapi:StructureInputInvalid','transport','name, type, ipaddress, port, verbose, comport, baudrate, AvailableCOMPorts, and AvailableBaudrates');
                end
                if~ismember(lower(val.type),{'serial','tcp/ip','can','custom'})
                    DAStudio.error('codertarget:targetapi:InvalidExtModeTransport');
                end
                switch lower(val.type)
                case 'tcp/ip'
                    val2Set=codertarget.attributes.TCPIPIOInterface(val);
                case 'serial'
                    val2Set=codertarget.attributes.SerialIOInterface(val);
                case 'custom'
                    val2Set=codertarget.attributes.CustomIOInterface(val);
                case 'can'
                    val2Set=codertarget.attributes.CANIOInterface(val);
                end
            else
                val2Set=val;
            end
            obj.Transport=val2Set;
        end
        function set.ProtocolConfiguration(obj,val)
            if isempty(val)
                return
            end
            if~isa(val,'codertarget.attributes.XCPProtocolConfiguration')
                validateattributes(val,{'struct'},{'scalar'});
                if~contains(lower(obj.Transport.Name),'xcp')
                    DAStudio.error('codertarget:targetapi:InvalidProtocolConfigData');
                end
                val2Set=codertarget.attributes.XCPProtocolConfiguration(val);
            else
                val2Set=val;
            end
            obj.ProtocolConfiguration=val2Set;
        end
        function set.SourceFiles(obj,val)
            assert(numel(obj.BuildConfigurationInfo)==1,'Using the derived property SourceFiles is only supported when there is a single BuildConfiguration');
            obj.BuildConfigurationInfo(1).SourceFiles=val;
        end
        function set.SourceFilesToSkip(obj,val)
            assert(numel(obj.BuildConfigurationInfo)==1,'Using the derived property SourceFiles is only supported when there is a single BuildConfiguration');
            obj.BuildConfigurationInfo(1).SourceFilesToSkip=val;
        end
        function out=get.SourceFiles(obj)
            bcs=obj.getBuildConfigurationInfo();
            out=[bcs.SourceFiles];
        end
        function out=get.SourceFilesToSkip(obj)
            bcs=obj.getBuildConfigurationInfo();
            out=[bcs.SourceFilesToSkip];
        end

        function out=get.Protocol(obj)


            if contains(lower(obj.Transport.Name),'xcp')
                out='XCP';
            else
                out='Legacy';
            end
        end

        function set.ModelParameter(obj,val)
            lfields={'name','value','callback'};
            if isempty(val)
                obj.ModelParameter=struct('name',{},'value',{},'callback',{});
            elseif(isstruct(val)&&isfield(val,'name')&&sum(isfield(val,lfields))>=2)
                for ii=1:numel(val)
                    obj.ModelParameter(ii)=struct('name',val(ii).name,'value','','callback','');
                    if isfield(val(ii),'value')
                        obj.ModelParameter(ii).value=val(ii).value;
                    end
                    if isfield(val(ii),'callback')
                        obj.ModelParameter(ii).callback=val(ii).callback;
                    end
                end
            else
                DAStudio.error('codertarget:targetapi:StructureInputInvalid',property,'name, value and callback');
            end
        end
        function set.CoderTargetParameter(obj,val)
            lfields={'name','value','callback'};
            if isempty(val)
                obj.CoderTargetParameter=struct('name',{},'value',{},'callback',{});
            elseif(isstruct(val)&&isfield(val,'name')&&sum(isfield(val,lfields))>=2)
                for ii=1:numel(val)
                    if~strncmp(val(ii).name,'ExtMode.',8)


                        obj.CoderTargetParameter(ii)=struct('name',val(ii).name,'value','','callback','');
                        if isfield(val(ii),'value')
                            obj.CoderTargetParameter(ii).value=val(ii).value;
                        end
                        if isfield(val(ii),'callback')
                            obj.CoderTargetParameter(ii).callback=val(ii).callback;
                        end
                    end
                end
            else
                DAStudio.error('codertarget:targetapi:StructureInputInvalid',property,'name, value and callback');
            end
        end
        function set.PreConnectFcn(obj,val)
            if~ischar(val)
                DAStudio.error('codertarget:targetapi:InvalidStringProperty','PreConnectFcn');
            end
            obj.PreConnectFcn=val;
        end
        function set.ConnectFcn(obj,val)
            if~ischar(val)
                DAStudio.error('codertarget:targetapi:InvalidStringProperty','ConnectFcn');
            end
            obj.ConnectFcn=val;
        end
        function set.SetupFcn(obj,val)
            if~ischar(val)
                DAStudio.error('codertarget:targetapi:InvalidStringProperty','SetupFcn');
            end
            obj.SetupFcn=val;
        end
        function set.CloseFcn(obj,val)
            if~ischar(val)
                DAStudio.error('codertarget:targetapi:InvalidStringProperty','CloseFcn');
            end
            obj.CloseFcn=val;
        end
        function set.PostDisconnectTargetFcn(obj,val)
            if~ischar(val)
                DAStudio.error('codertarget:targetapi:InvalidStringProperty','PostDisconnectTargetFcn');
            end
            obj.PostDisconnectTargetFcn=val;
        end
        function set.Task(obj,val)
            if~isa(val,'codertarget.attributes.TaskInfo')&&~isstruct(val)&&~islogical(val)
                DAStudio.error('codertarget:targetapi:StructureInputInvalid','Task','inbackground, inforeground, default and visible');
            else
                val2Set=val;
            end
            obj.Task=val2Set;
        end
        function set.BuildConfigurationInfo(obj,val)
            if~isa(val,'codertarget.attributes.BuildConfigurationInfo')
                assert(false,'Cannot set BuildConfigurationInfo property with type other than codertarget.attributes.BuildConfigurationInfo');
            end
            obj.BuildConfigurationInfo=val;
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
            res=p.Results;
            allBCs=[];
            for j=1:numel(h)
                hExtMode=h(j);
                for i=1:numel(hExtMode.BuildConfigurationInfo)
                    bcObj=hExtMode.BuildConfigurationInfo(i);
                    isSupportedOS=isequal(res.os,'any')||...
                    isequal(bcObj.SupportedOperatingSystems,{'all'})||...
                    ismember(res.os,bcObj.SupportedOperatingSystems);
                    isSupportedToolchain=isequal(res.toolchain,'any')||...
                    isequal(bcObj.SupportedToolchains,{'all'})||...
                    ismember(res.toolchain,bcObj.SupportedToolchains);
                    if isSupportedOS&&isSupportedToolchain
                        allBCs=[allBCs,bcObj];%#ok<AGROW>
                    end
                end
            end
        end

        function ret=toStruct(h)
            ret=[];
            for ii=1:numel(h)
                ret(end+1).name=h(ii).Name;%#ok<AGROW>         
                for jj=1:numel(h(ii).BuildConfigurationInfo)
                    [pathToBC,fileName]=fileparts(h(ii).BuildConfigurationInfo(jj).DefinitionFileName);
                    pathToBC=strrep(regexprep(pathToBC,'[\\/]','/'),regexprep(h(ii).TargetFolder,'[\\/]','/'),'$(TARGET_ROOT)');
                    assert(isequal(pathToBC,'$(TARGET_ROOT)/registry/attributes'),['The BuildConfiguration for ExternalModeInfo ''',h(ii).Name,''' must be within the $(TARGET_ROOT)/registry/attributes folder']);
                    ret(end).buildconfigurationinfofile(jj)={['$(TARGET_ROOT)/registry/attributes/',fileName,'.xml']};
                end
                ret(end).preconnectfcn=h(ii).PreConnectFcn;
                ret(end).connectfcn=h(ii).ConnectFcn;
                ret(end).modelparameter=h(ii).ModelParameter;
                ret(end).codertargetparameter=h(ii).CoderTargetParameter;
                if~isempty(h(ii).Transport)
                    transportFields=properties(class(h(ii).Transport));
                    for jj=1:numel(transportFields)
                        if~isempty(h(ii).Transport.(transportFields{jj}))
                            ret(end).transport.(lower(transportFields{jj}))=h(ii).Transport.(transportFields{jj});
                        end
                    end
                end
                if~isempty(h(ii).ProtocolConfiguration)
                    protocolFields=properties(class(h(ii).ProtocolConfiguration));
                    for jj=1:numel(protocolFields)
                        if~isempty(h(ii).ProtocolConfiguration.(protocolFields{jj}))
                            ret(end).protocolconfiguration.(lower(protocolFields{jj}))=h(ii).ProtocolConfiguration.(protocolFields{jj});
                        end
                    end
                end
                ret(end).setupfcn=h(ii).SetupFcn;
                ret(end).closefcn=h(ii).CloseFcn;
                ret(end).postdisconnecttargetfcn=h(ii).PostDisconnectTargetFcn;
                ret(end).task=struct('inbackground',h(ii).Task.InBackground,...
                'inforeground',h(ii).Task.InForeground,...
                'default',h(ii).Task.Default,...
                'visible',h(ii).Task.Visible);
            end
        end
    end
end





