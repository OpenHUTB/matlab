classdef TargetService<matlab.mixin.SetGet



    properties
        TargetFolder='';

        IOInterfaceName=''
        MaxPoolSize=[]
        ThreadPriority=[]
        BuildConfigurationInfo=[]
        ApplicationServices=[];
        HeaderFiles={}
    end
    methods(Access={?codertarget.attributes.AttributeInfo})
        function h=TargetService(structVal,targetfolder)
            if isstruct(structVal)
                if isfield(structVal,'toolchain')...
                    &&isfield(structVal,'iointerfacename')


                    h.BuildConfigurationInfo=codertarget.attributes.BuildConfigurationInfo();
                    h.BuildConfigurationInfo.DefinitionFileName=['$(TARGET_ROOT)/registry/attributes/TargetServiceBuildConfig_',codertarget.internal.makeValidFileName(structVal.iointerfacename),'.xml'];
                    h.BuildConfigurationInfo.SupportedToolchains=structVal.toolchain;
                    if isfield(structVal,'compileflags')
                        h.BuildConfigurationInfo.CompileFlags=structVal.compileflags;
                    end
                    if isfield(structVal,'library')&&~isempty(structVal.library)
                        h.BuildConfigurationInfo.Libraries=structVal.library;
                    end
                    if isfield(structVal,'linkflags')
                        h.BuildConfigurationInfo.LinkFlags=structVal.linkflags;
                    end
                elseif isstruct(structVal)...
                    &&isfield(structVal,'buildconfigurationinfofile')...
                    &&isfield(structVal,'iointerfacename')
                    h.TargetFolder=targetfolder;
                    h.BuildConfigurationInfo=...
                    codertarget.attributes.BuildConfigurationInfo(...
                    strrep(structVal.buildconfigurationinfofile,'$(TARGET_ROOT)',targetfolder)...
                    );
                else
                    DAStudio.error('codertarget:targetapi:StructureInputInvalid_MissingReqdField','TargetServices','''buildconfigurationinfofile'' and ''iointerfacename''');
                end
                h.IOInterfaceName=structVal.iointerfacename;
                h.ApplicationServices=containers.Map;
                if isfield(structVal,'applicationservice')
                    h.ApplicationServices=structVal.applicationservice;
                end
                if isfield(structVal,'MaxPoolSize')
                    h.MaxPoolSize=structVal.maxpoolsize;
                end
                if isfield(structVal,'ThreadPriority')
                    h.ThreadPriority=structVal.threadpriority;
                end
                if isfield(structVal,'headerfile')
                    h.HeaderFiles=structVal.headerfile;
                end
            else
                DAStudio.error('codertarget:targetapi:StructureInputInvalid_MissingReqdField','TargetServices','''buildconfigurationinfofile'' and ''iointerfacename''');
            end
        end
    end
    methods(Access='public')
        function out=getIOInterfaceNames(hObj)
            out=cell([numel(hObj),1]);
            for ii=1:numel(hObj)
                out{ii}=hObj(ii).IOInterfaceName;
            end
        end
        function out=getApplicationService(hObj,hModel,appServiceName)
            out=[];
            if~isempty(hModel)
                aToolchain=get_param(hModel,'Toolchain');
                ioInterface=codertarget.data.getParameterValue(getActiveConfigSet(hModel),'ExtMode.Configuration');
                TS=hObj.getTargetService('toolchain',aToolchain,'iointerfacename',ioInterface);
                assert(numel(TS)<2,['No more than one TargetService must be detected for the same toolchain (''',aToolchain,''') and iointeface (''',ioInterface,''') combination']);
                if(isempty(TS))
                    return;
                end
                if(TS.ApplicationServices.isKey(appServiceName))
                    out=TS.ApplicationServices(appServiceName);
                end
            else
                if hObj(1).ApplicationServices.isKey(appServiceName)
                    out=hObj(1).ApplicationServices(appServiceName);
                end
            end
        end
        function out=getBuildDataForModel(hObj,hModel,propName)
            aToolchain=get_param(hModel,'Toolchain');
            idx=[];
            for ii=1:numel(hObj)
                if isequal(aToolchain,hObj(ii).Toolchain)
                    idx=ii;
                end
            end
            if~isempty(idx)
                switch lower(propName)
                case 'linkflags'
                    out=hObj(ii).LinkFlags;
                case 'library'
                    out=hObj(ii).Library;
                case 'applicationservice'
                    out=hObj(ii).ApplicationService;
                end
            end
        end
        function addApplicationService(hObj,Name,Library)
            hObj.ApplicationServices(Name)=codertarget.targetservices.ApplicationService(struct('name',Name,'library',Library));
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
    methods(Hidden)
        function out=toStruct(hObj)
            p=struct;
            upperFieldNames=properties('codertarget.targetservices.TargetService');
            upperFieldNames=upperFieldNames(~ismember(upperFieldNames,{'TargetFolder','ApplicationServices','BuildConfigurationInfo'}));
            lowerFieldNames=[lower(upperFieldNames);'applicationservices';'buildconfigurationinfofile'];
            for jj=1:numel(hObj)
                for ii=1:numel(upperFieldNames)
                    p(jj).(lowerFieldNames{ii})=hObj(jj).(upperFieldNames{ii});
                end

                if~isempty(hObj(jj).ApplicationServices)
                    q=hObj(jj).ApplicationServices.values;
                    for ii=1:numel(q)
                        p(jj).applicationservice(ii)=q{ii}.toStruct;
                    end
                else
                    p(jj).applicationservice=[];
                end

                getBCDefFile=@(lfilename)strcat('$(TARGET_ROOT)','/registry','/attributes/',lfilename,'.xml');
                [~,bcDefFileNames]=cellfun(@(in)fileparts(in),{hObj(jj).BuildConfigurationInfo.DefinitionFileName},'UniformOutput',false);
                p(jj).buildconfigurationinfofile=cellfun(getBCDefFile,bcDefFileNames,'UniformOutput',false);
            end
            out=p;
        end
    end

    methods
        function set.MaxPoolSize(obj,val)
            if~isnumeric(val)&&~ischar(val)
                DAStudio.error('codertarget:targetapi:InvalidNumericProperty','MaxPoolSize');
            elseif isnumeric(val)
                if~isempty(val)
                    val=num2str(val);
                end
            elseif ischar(val)&&isnan(str2double(val))
                val=[];
            end
            obj.MaxPoolSize=val;
        end
        function set.ThreadPriority(obj,val)
            if~isnumeric(val)&&~ischar(val)
                DAStudio.error('codertarget:targetapi:InvalidNumericProperty','ThreadPriority');
            elseif isnumeric(val)
                if~isempty(val)
                    val=num2str(val);
                end
            elseif ischar(val)&&isnan(str2double(val))
                val=[];
            end
            obj.ThreadPriority=val;
        end
        function set.IOInterfaceName(obj,val)
            if~ischar(val)
                DAStudio.error('codertarget:targetapi:InvalidStringProperty','IOInterfaceName');
            end
            obj.IOInterfaceName=val;
        end
        function set.HeaderFiles(obj,val)
            if~iscell(val)&&~ischar(val)
                DAStudio.error('codertarget:targetapi:InvalidCellProperty','HeaderFiles');
            elseif ischar(val)
                val=cellstr(val);
            end
            obj.HeaderFiles=val;
        end
        function set.ApplicationServices(obj,val)
            if~(isa(val,'containers.Map')||...
                isa(val,'codertarget.targetservices.ApplicationService')||...
                (isstruct(val)&&isfield(val,'name')))
                return;
            end
            tempvar=containers.Map;
            for ii=1:numel(val)
                if iscell(val)
                    tempvar(val{ii}.name)=codertarget.targetservices.ApplicationService(val{ii});
                elseif isstruct(val)
                    tempvar(val(ii).name)=codertarget.targetservices.ApplicationService(val(ii));
                elseif isa(val,'codertarget.targetservices.ApplicationService')
                    tempvar(val.Name)=val;
                elseif isa(val,'containers.Map')
                    tempvar=val;
                    break;
                end
            end
            obj.ApplicationServices=tempvar;
        end
        function set.BuildConfigurationInfo(obj,val)
            if~isa(val,'codertarget.attributes.BuildConfigurationInfo')
                assert(false,'Cannot set BuildConfigurationInfo property with type other than codertarget.attributes.BuildConfigurationInfo');
            end
            assert(numel(val)<2,'codertarget.targetservices.TargetService cannot have more than one BuildConfiguration');
            obj.BuildConfigurationInfo=val;
        end
    end

    methods(Access='public',Hidden)
        function ts=getTargetService(h,varargin)
            p=inputParser;
            p.addParameter('os','any');
            p.addParameter('toolchain','any');
            p.addParameter('iointerfacename','any');
            p.parse(varargin{:});
            res=p.Results;
            ts=[];
            for i=1:numel(h)
                bcObj=h(i).BuildConfigurationInfo;
                isSupportedOS=isequal(res.os,'any')||...
                isequal(bcObj.SupportedOperatingSystems,{'all'})||...
                ismember(res.os,bcObj.SupportedOperatingSystems);
                isSupportedToolchain=isequal(res.toolchain,'any')||...
                isequal(bcObj.SupportedToolchains,{'all'})||...
                ismember(res.toolchain,bcObj.SupportedToolchains);
                isSupportedInterface=isequal(h(i).IOInterfaceName,'any')||...
                isequal(h(i).IOInterfaceName,{'all'})||...
                isequal(res.iointerfacename,h(i).IOInterfaceName);
                if isSupportedOS&&isSupportedToolchain&&isSupportedInterface
                    ts=[ts,h(i)];%#ok<AGROW>
                end
            end
        end
    end
end