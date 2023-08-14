




classdef Component<handle
    properties
        ComponentPackage;
        ComponentName;
        ComponentType;
        InterfacePackage;
        CSInterfacePackage;
        InterfaceFormatCtl;
        DataElementFormatCtl;
        Interfaces;
        ServiceInterfaces;
        PersistencyKeyValueInterfaces;
        CSInterfaces;
        PortFormatCtl;
        Ports;
        CSPorts;
        ServicePorts;
        PersistencyPorts;
        IsDefaultConfig;
        ModelName;
        IsAdaptive;
        PreserveExistingMapping;
        IsWizardMode;
        ChangeLogger;
        ComponentAdapter;
        InterfaceDictName;
        IsUsingInterfaceDict;
        CanAutoPopulateInterfaces;
    end

    methods
        function obj=Component(name,modelName,varargin)


            argParser=inputParser;


            argParser.addParameter('IsWizardMode',false,@(x)(islogical(x)));
            argParser.addParameter('SelectedNode',[]);
            argParser.addParameter('PreserveExistingMapping',false,@(x)(islogical(x)));
            argParser.addParameter('ChangeLogger',[]);
            argParser.parse(varargin{:});

            obj.PreserveExistingMapping=argParser.Results.PreserveExistingMapping;
            obj.IsWizardMode=argParser.Results.IsWizardMode;
            obj.ChangeLogger=argParser.Results.ChangeLogger;

            maxShortNameLength=autosar.ui.utils.getAutosarMaxShortNameLength(modelName);
            if length(name)>maxShortNameLength
                name=name(1:maxShortNameLength);
            end
            obj.IsAdaptive=Simulink.CodeMapping.isAutosarAdaptiveSTF(modelName);

            obj.ComponentAdapter=autosar.ui.wizard.builder.ComponentAdapter.getComponentAdapter(modelName,obj.IsAdaptive);

            if isempty(argParser.Results.SelectedNode)
                displayNode=autosar.ui.metamodel.PackageString.InterfacesNodeName;
            else
                displayNode=argParser.Results.SelectedNode.getDisplayLabel;
            end

            interfaceDicts=SLDictAPI.getTransitiveInterfaceDictsForModel(modelName);
            obj.InterfaceDictName='';
            if numel(interfaceDicts)>0
                assert(numel(interfaceDicts)==1,'expect 1 interface dict in model closure');
                obj.InterfaceDictName=autosar.utils.File.dropPath(interfaceDicts{1});
            end
            obj.IsUsingInterfaceDict=~isempty(obj.InterfaceDictName);







            obj.CanAutoPopulateInterfaces=~obj.IsUsingInterfaceDict||...
            (obj.IsUsingInterfaceDict&&...
            autosar.dictionary.internal.DictionaryExporter.isTempHiddenModelForDictExport(modelName));

            arRoot=[];
            mmgr=get_param(modelName,'MappingManager');
            mapping=mmgr.getActiveMappingFor(obj.ComponentAdapter.MappingKey);
            isMapped=~isempty(mapping);
            if isMapped
                m3iModel=autosar.api.Utils.m3iModel(modelName);
                assert(m3iModel.RootPackage.size==1);
                arRoot=m3iModel.RootPackage.front();

                if~autosar.api.Utils.isUsingSharedAutosarDictionary(modelName)
                    arRootShared=arRoot;
                else
                    m3iModelShared=autosarcore.ModelUtils.getSharedElementsM3IModel(modelName);
                    arRootShared=m3iModelShared.RootPackage.front();
                end
            end

            if~isempty(arRoot)
                [obj.ComponentPackage,~,~]=fileparts(arRoot.ComponentQualifiedName);
                obj.InterfacePackage=arRootShared.InterfacePackage;
            end
            if isempty(obj.ComponentPackage)
                if obj.PreserveExistingMapping
                    m3iComp=autosar.api.Utils.m3iMappedComponent(modelName);
                    obj.ComponentPackage=fileparts(autosar.api.Utils.getQualifiedName(m3iComp));
                else
                    obj.ComponentPackage=autosar.mm.util.XmlOptionsDefaultPackages.ComponentsPackage;
                end
            end
            if isempty(obj.InterfacePackage)
                obj.InterfacePackage=autosar.mm.util.XmlOptionsDefaultPackages.InterfacesPackage;
            end

            if obj.PreserveExistingMapping
                m3iComp=autosar.api.Utils.m3iMappedComponent(modelName);
                obj.ComponentName=m3iComp.Name;
            else
                obj.ComponentName=name;
            end

            obj.InterfaceFormatCtl=autosar.ui.wizard.PackageString.DefaultInterfaceFormatCtl;
            obj.DataElementFormatCtl=autosar.ui.wizard.PackageString.DefaultDataElementFormatCtl;
            obj.PortFormatCtl=autosar.ui.wizard.PackageString.DefaultPortFormatCtl;
            Port1=autosar.ui.wizard.builder.Port(autosar.ui.wizard.PackageString.DefaultPort1,...
            autosar.ui.wizard.PackageString.DefaultInterface,autosar.ui.wizard.PackageString.PortTypes(1));
            Port2=autosar.ui.wizard.builder.Port(autosar.ui.wizard.PackageString.DefaultPort2,...
            autosar.ui.wizard.PackageString.DefaultInterface,autosar.ui.wizard.PackageString.PortTypes(2));
            Port3=autosar.ui.wizard.builder.Port(autosar.ui.wizard.PackageString.DefaultPort3,...
            autosar.ui.wizard.PackageString.DefaultCSInterface,autosar.ui.wizard.PackageString.PortTypes(4));
            servicePortRequired=autosar.ui.wizard.builder.Port(autosar.ui.wizard.PackageString.DefaultServicePort1,...
            autosar.ui.wizard.PackageString.DefaultServiceInterface,autosar.ui.wizard.PackageString.PortTypes(13));
            servicePortProvided=autosar.ui.wizard.builder.Port(autosar.ui.wizard.PackageString.DefaultServicePort2,...
            autosar.ui.wizard.PackageString.DefaultServiceInterface,autosar.ui.wizard.PackageString.PortTypes(14));
            PersistencyPortRequired=autosar.ui.wizard.builder.Port(autosar.ui.wizard.PackageString.DefaultPersistencyPort1,...
            autosar.ui.wizard.PackageString.DefaultServiceInterface,autosar.ui.wizard.PackageString.PortTypes(16));
            PersistencyPortProvided=autosar.ui.wizard.builder.Port(autosar.ui.wizard.PackageString.DefaultPersistencyPort2,...
            autosar.ui.wizard.PackageString.DefaultServiceInterface,autosar.ui.wizard.PackageString.PortTypes(15));
            PersistencyPortProvidedRequired=autosar.ui.wizard.builder.Port(autosar.ui.wizard.PackageString.DefaultPersistencyPort3,...
            autosar.ui.wizard.PackageString.DefaultServiceInterface,autosar.ui.wizard.PackageString.PortTypes(17));

            serviceInterface=autosar.ui.wizard.builder.SenderReceiverInterface.empty();
            persistencyKeyValueInterface=autosar.ui.wizard.builder.SenderReceiverInterface.empty();
            if any(strcmp(displayNode,{...
                autosar.ui.metamodel.PackageString.InterfacesNodeName,...
                autosar.ui.wizard.PackageString.ReceiverPorts,...
                autosar.ui.wizard.PackageString.SenderPorts,...
                autosar.ui.wizard.PackageString.SenderReceiverPorts}))
                Interface1=autosar.ui.wizard.builder.SenderReceiverInterface(...
                autosar.ui.wizard.PackageString.DefaultInterface,'2',...
                autosar.ui.wizard.PackageString.InterfaceTypes(1));
                if argParser.Results.IsWizardMode


                    Interface2=autosar.ui.wizard.builder.ClientServerInterface(...
                    autosar.ui.wizard.PackageString.DefaultCSInterface,'1',...
                    autosar.ui.wizard.PackageString.InterfaceTypes(1));
                    serviceInterface=autosar.ui.wizard.builder.ServiceInterface(...
                    autosar.ui.wizard.PackageString.DefaultServiceInterface,...
                    '1','1',...
                    autosar.ui.wizard.PackageString.InterfaceTypes(1));
                    persistencyKeyValueInterface=autosar.ui.wizard.builder.PersistencyKeyValueInterface(...
                    autosar.ui.wizard.PackageString.DefaultPersistencyKeyValueInterface,...
                    '1',...
                    autosar.ui.wizard.PackageString.InterfaceTypes(1));
                else
                    Interface2=autosar.ui.wizard.builder.ClientServerInterface.empty();
                end
            elseif any(strcmp(displayNode,{...
                autosar.ui.metamodel.PackageString.ModeSwitchInterfacesNodeName,...
                autosar.ui.wizard.PackageString.ModeReceiverPorts}))
                Interface1=autosar.ui.wizard.builder.ModeSwitchInterface(...
                autosar.ui.wizard.PackageString.DefaultInterface,...
                autosar.ui.wizard.PackageString.NewName,'',...
                autosar.ui.wizard.PackageString.InterfaceTypes(2));
                Interface2=autosar.ui.wizard.builder.ClientServerInterface.empty();
            elseif any(strcmp(displayNode,{...
                autosar.ui.metamodel.PackageString.ClientServerInterfacesNodeName,...
                autosar.ui.wizard.PackageString.ServerPorts,...
                autosar.ui.wizard.PackageString.ClientPorts}))
                Interface1=autosar.ui.wizard.builder.SenderReceiverInterface.empty();
                Interface2=autosar.ui.wizard.builder.ClientServerInterface(...
                autosar.ui.wizard.PackageString.DefaultCSInterface,'1',...
                autosar.ui.wizard.PackageString.InterfaceTypes(1));
            elseif any(strcmp(displayNode,{...
                autosar.ui.metamodel.PackageString.NvDataInterfacesNodeName,...
                autosar.ui.wizard.PackageString.NvReceiverPorts,...
                autosar.ui.wizard.PackageString.NvSenderPorts,...
                autosar.ui.wizard.PackageString.NvSenderReceiverPorts}))
                Interface1=autosar.ui.wizard.builder.NvDataInterface(...
                autosar.ui.wizard.PackageString.DefaultNVInterface,'2',...
                autosar.ui.wizard.PackageString.InterfaceTypes(1));
                Interface2=autosar.ui.wizard.builder.NvDataInterface.empty();
            elseif any(strcmp(displayNode,{...
                autosar.ui.metamodel.PackageString.ParameterInterfacesNodeName,...
                autosar.ui.wizard.PackageString.ParameterReceiverPorts}))
                Interface1=autosar.ui.wizard.builder.ParameterInterface(...
                autosar.ui.wizard.PackageString.DefaultInterface,'2',...
                autosar.ui.wizard.PackageString.InterfaceTypes(1));
                Interface2=autosar.ui.wizard.builder.ClientServerInterface.empty();
            elseif any(strcmp(displayNode,{...
                autosar.ui.metamodel.PackageString.ModeSwitchInterfacesNodeName,...
                autosar.ui.wizard.PackageString.ModeSenderPorts}))
                Interface1=autosar.ui.wizard.builder.ModeSwitchInterface(...
                autosar.ui.wizard.PackageString.DefaultInterface,...
                autosar.ui.wizard.PackageString.NewName,'',...
                autosar.ui.wizard.PackageString.InterfaceTypes(2));
                Interface2=autosar.ui.wizard.builder.ClientServerInterface.empty();
            elseif any(strcmp(displayNode,{...
                autosar.ui.metamodel.PackageString.TriggerInterfacesNodeName,...
                autosar.ui.wizard.PackageString.TriggerReceiverPorts}))
                Interface1=autosar.ui.wizard.builder.TriggerInterface(...
                autosar.ui.wizard.PackageString.DefaultTriggerInterface,'1',...
                autosar.ui.wizard.PackageString.InterfaceTypes(1));
                Interface2=autosar.ui.wizard.builder.ClientServerInterface.empty();
            elseif any(strcmp(displayNode,{...
                autosar.ui.metamodel.PackageString.ServiceInterfacesNodeName,...
                autosar.ui.metamodel.PackageString.providedPortsNode,...
                autosar.ui.metamodel.PackageString.requiredPortsNode}))
                Interface1=autosar.ui.wizard.builder.SenderReceiverInterface.empty();
                Interface2=autosar.ui.wizard.builder.SenderReceiverInterface.empty();
                numEvents='1';
                numMethods='0';
                serviceInterface=autosar.ui.wizard.builder.ServiceInterface(...
                autosar.ui.wizard.PackageString.DefaultServiceInterface,...
                numEvents,numMethods,...
                autosar.ui.wizard.PackageString.InterfaceTypes(1));
            elseif any(strcmp(displayNode,{...
                autosar.ui.metamodel.PackageString.PersistencyKeyValueInterfacesNodeName,...
                autosar.ui.metamodel.PackageString.persistencyProvidedPortsNode,...
                autosar.ui.metamodel.PackageString.persistencyRequiredPortsNode,...
                autosar.ui.metamodel.PackageString.persistencyProvidedRequiredPortsNode}))
                Interface1=autosar.ui.wizard.builder.SenderReceiverInterface.empty();
                Interface2=autosar.ui.wizard.builder.SenderReceiverInterface.empty();
                persistencyKeyValueInterface=autosar.ui.wizard.builder.PersistencyKeyValueInterface(...
                autosar.ui.wizard.PackageString.DefaultPersistencyKeyValueInterface,...
                '1',...
                autosar.ui.wizard.PackageString.InterfaceTypes(1));
            else
                assert(false,'Unknown displayNode');
            end

            if obj.IsAdaptive
                obj.ComponentType=autosar.ui.wizard.PackageString.ComponentTypes{6};
            elseif obj.PreserveExistingMapping
                obj.ComponentType=m3iComp.Kind.toString();
            else
                obj.ComponentType=autosar.ui.wizard.PackageString.DefaultComponentType;
            end
            obj.ServicePorts=[servicePortRequired,servicePortProvided];
            obj.ServiceInterfaces=serviceInterface;
            obj.PersistencyPorts=[PersistencyPortRequired,PersistencyPortProvided,PersistencyPortProvidedRequired];
            obj.PersistencyKeyValueInterfaces=persistencyKeyValueInterface;
            obj.Ports=[Port1,Port2];
            obj.CSPorts=Port3;
            obj.CSInterfacePackage=obj.InterfacePackage;
            obj.Interfaces=Interface1;
            obj.CSInterfaces=Interface2;

            obj.IsDefaultConfig=false;
            obj.ModelName=modelName;
        end

        function ret=setComponentPackage(obj,compPackage)

            ret=0;
            maxShortNameLength=autosar.ui.utils.getAutosarMaxShortNameLength(obj.ModelName);
            idcheckmessage=autosar.ui.utils.isValidARIdentifier({compPackage},'absPath',maxShortNameLength);
            if~isempty(idcheckmessage)
                errordlg(idcheckmessage,autosar.ui.metamodel.PackageString.ErrorTitle,'replace');
                ret=-1;
            else
                obj.ComponentPackage=compPackage;
            end
        end

        function ret=setComponentName(obj,compName)

            ret=0;
            maxShortNameLength=autosar.ui.utils.getAutosarMaxShortNameLength(obj.ModelName);
            idcheckmessage=autosar.ui.utils.isValidARIdentifier({compName},'shortName',maxShortNameLength);
            if~isempty(idcheckmessage)
                errordlg(idcheckmessage,autosar.ui.metamodel.PackageString.ErrorTitle,'replace');
                ret=-1;
            else
                obj.ComponentName=compName;
            end
        end

        function ret=setComponentType(obj,compType)
            ret=0;
            if any(strcmp(compType,autosar.ui.wizard.PackageString.ComponentTypes))
                obj.ComponentType=compType;
            else
                ret=-1;
            end
        end

        function ret=setInterfacePackage(obj,interfacePackage)

            ret=0;
            maxShortNameLength=autosar.ui.utils.getAutosarMaxShortNameLength(obj.ModelName);
            idcheckmessage=autosar.ui.utils.isValidARIdentifier({interfacePackage},'absPath',maxShortNameLength);
            if~isempty(idcheckmessage)
                errordlg(idcheckmessage,autosar.ui.metamodel.PackageString.ErrorTitle,'replace');
                ret=-1;
            else
                obj.InterfacePackage=interfacePackage;
            end
        end

        function ret=setCSInterfacePackage(obj,interfacePackage)

            ret=0;
            maxShortNameLength=autosar.ui.utils.getAutosarMaxShortNameLength(obj.ModelName);
            idcheckmessage=autosar.ui.utils.isValidARIdentifier({interfacePackage},'absPath',maxShortNameLength);
            if~isempty(idcheckmessage)
                errordlg(idcheckmessage,autosar.ui.metamodel.PackageString.ErrorTitle,'replace');
                ret=-1;
            else
                obj.CSInterfacePackage=interfacePackage;
            end
        end

        function setInterfaceFormatCtl(obj,fmtCtl)
            obj.InterfaceFormatCtl=fmtCtl;
        end

        function setDataElementFormatCtl(obj,fmtCtl)
            obj.DataElementFormatCtl=fmtCtl;
        end

        function addSRInterface(obj,name,elementCount,type)
            interface=autosar.ui.wizard.builder.SenderReceiverInterface(name,...
            elementCount,type);
            obj.Interfaces(end+1)=interface;
        end
        function addMSInterface(obj,name,modeGroup,modeDeclarationGroup,type)
            interface=autosar.ui.wizard.builder.ModeSwitchInterface(name,...
            modeGroup,modeDeclarationGroup,type);
            obj.Interfaces(end+1)=interface;
        end
        function addCSInterface(obj,name,opCount,type)
            interface=autosar.ui.wizard.builder.ClientServerInterface(name,...
            opCount,type);
            obj.CSInterfaces(end+1)=interface;
        end
        function addNVInterface(obj,name,elementCount,type)
            interface=autosar.ui.wizard.builder.NvDataInterface(name,...
            elementCount,type);
            obj.Interfaces(end+1)=interface;
        end
        function addParameterInterface(obj,name,elementCount,type)
            interface=autosar.ui.wizard.builder.ParameterInterface(name,...
            elementCount,type);
            obj.Interfaces(end+1)=interface;
        end
        function addTriggerInterface(obj,name,elementCount,type)
            interface=autosar.ui.wizard.builder.TriggerInterface(name,...
            elementCount,type);
            obj.Interfaces(end+1)=interface;
        end

        function addServiceInterface(obj,name,eventCount,methodCount,type)
            interface=autosar.ui.wizard.builder.ServiceInterface(name,...
            eventCount,methodCount,type);
            obj.ServiceInterfaces(end+1)=interface;
        end
        function addPersistencyKeyValueInterface(obj,name,elementCount,type)
            interface=autosar.ui.wizard.builder.PersistencyKeyValueInterface(name,...
            elementCount,type);
            obj.PersistencyKeyValueInterfaces(end+1)=interface;
        end

        function removeInterface(obj,interface)
            assert(length(interface)==1,autosar.ui.wizard.PackageString.InterfaceMulDeleteError);
            if iscell(interface)
                interface=interface{1}.Source;
            end
            if isa(interface,'autosar.ui.wizard.builder.ClientServerInterface')
                for i=1:length(obj.CSInterfaces)
                    if obj.CSInterfaces(i)==interface
                        obj.CSInterfaces(i).delete;
                        obj.CSInterfaces(i)=[];
                        break;
                    end
                end
            elseif isa(interface,'autosar.ui.wizard.builder.ServiceInterface')
                for i=1:length(obj.ServiceInterfaces)
                    if obj.ServiceInterfaces(i)==interface
                        obj.ServiceInterfaces(i).delete;
                        obj.ServiceInterfaces(i)=[];
                        break;
                    end
                end
            elseif isa(interface,'autosar.ui.wizard.builder.PersistencyKeyValueInterface')
                for i=1:length(obj.PersistencyKeyValueInterfaces)
                    if obj.PersistencyKeyValueInterfaces(i)==interface
                        obj.PersistencyKeyValueInterfaces(i).delete;
                        obj.PersistencyKeyValueInterfaces(i)=[];
                        break;
                    end
                end
            else
                for i=1:length(obj.Interfaces)
                    if obj.Interfaces(i)==interface
                        obj.Interfaces(i).delete;
                        obj.Interfaces(i)=[];
                        break;
                    end
                end
            end
        end

        function ret=setInterface(obj,index,name,qName,interfaceProperty,...
            type,displayLabel)
            ret=0;
            if strcmp(displayLabel,autosar.ui.metamodel.PackageString.ClientServerInterfacesNodeName)
                assert(index<=length(obj.CSInterfaces),autosar.ui.wizard.PackageString.InvalidIndexError);
            elseif strcmp(displayLabel,autosar.ui.metamodel.PackageString.ServiceInterfacesNodeName)
                assert(index<=length(obj.ServiceInterfaces),autosar.ui.wizard.PackageString.InvalidIndexError);
                assert(iscell(interfaceProperty),'expected cell array of properties for service interfaces');
            elseif strcmp(displayLabel,autosar.ui.metamodel.PackageString.PersistencyKeyValueInterfacesNodeName)
                assert(index<=length(obj.PersistencyKeyValueInterfaces),autosar.ui.wizard.PackageString.InvalidIndexError);
                assert(iscell(interfaceProperty),'expected cell array of properties for persistency key value interfaces');
            else
                assert(index<=length(obj.Interfaces),autosar.ui.wizard.PackageString.InvalidIndexError);
            end
            maxShortNameLength=autosar.ui.utils.getAutosarMaxShortNameLength(obj.ModelName);
            idcheckmessage=autosar.ui.utils.isValidARIdentifier({name},'shortName',maxShortNameLength);
            if~isempty(idcheckmessage)
                errordlg(idcheckmessage,autosar.ui.metamodel.PackageString.ErrorTitle,'replace');
                ret=-1;
            elseif any(strcmp(displayLabel,{autosar.ui.metamodel.PackageString.InterfacesNodeName,...
                autosar.ui.metamodel.PackageString.NvDataInterfacesNodeName,...
                autosar.ui.metamodel.PackageString.ParameterInterfacesNodeName}))
                n=str2num(interfaceProperty);%#ok<ST2NM>
                if~isempty(n)&&n>0&&rem(n,1)~=0
                    errMsg=DAStudio.message('RTW:autosar:DataElementError',name);
                    errordlg(errMsg,...
                    autosar.ui.metamodel.PackageString.ErrorTitle,'replace');
                    ret=-1;
                end
            elseif strcmp(displayLabel,autosar.ui.metamodel.PackageString.ModeSwitchInterfacesNodeName)
                idcheckmessage=autosar.ui.utils.isValidARIdentifier({interfaceProperty},'shortName',maxShortNameLength);
                if~isempty(idcheckmessage)
                    errordlg(idcheckmessage,autosar.ui.metamodel.PackageString.ErrorTitle,'replace');
                    ret=-1;
                end
            elseif strcmp(displayLabel,autosar.ui.metamodel.PackageString.ClientServerInterfacesNodeName)
                n=str2num(interfaceProperty);%#ok<ST2NM>
                if~isempty(n)&&n>0&&rem(n,1)~=0
                    errMsg=DAStudio.message('RTW:autosar:OperationError',name);
                    errordlg(errMsg,...
                    autosar.ui.metamodel.PackageString.ErrorTitle,'replace');
                    ret=-1;
                end
            end
            if ret~=-1

                arModel=autosar.api.Utils.m3iModel(obj.ModelName);
                protectedNames={};
                for ii=1:length(autosar.ui.metamodel.PackageString.InterfacesCell)
                    interfaces=autosar.ui.utils.collectObject(arModel,...
                    autosar.ui.metamodel.PackageString.InterfacesCell{ii});
                    for jj=1:length(interfaces)
                        protectedNames=[protectedNames,autosar.api.Utils.getQualifiedName(interfaces(jj))];%#ok<AGROW>
                    end
                end
                if any(ismember(protectedNames,qName))
                    errordlg(DAStudio.message('RTW:autosar:errorDuplicateInterface',qName),...
                    autosar.ui.metamodel.PackageString.ErrorTitle,'replace');
                    ret=-1;
                    return;
                end
                if strcmp(displayLabel,autosar.ui.metamodel.PackageString.ClientServerInterfacesNodeName)
                    obj.CSInterfaces(index).setName(name);
                    obj.CSInterfaces(index).setType(type);
                elseif strcmp(displayLabel,autosar.ui.metamodel.PackageString.ServiceInterfacesNodeName)
                    obj.ServiceInterfaces(index).setName(name);
                    obj.ServiceInterfaces(index).setType(type);
                    obj.ServiceInterfaces(index).setEventCount(interfaceProperty{1});
                    obj.ServiceInterfaces(index).setMethodCount(interfaceProperty{2});
                elseif strcmp(displayLabel,autosar.ui.metamodel.PackageString.PersistencyKeyValueInterfacesNodeName)
                    obj.PersistencyKeyValueInterfaces(index).setName(name);
                    obj.PersistencyKeyValueInterfaces(index).setType(type);
                    obj.PersistencyKeyValueInterfaces(index).setDataElementCount(interfaceProperty{1});
                else
                    obj.Interfaces(index).setName(name);
                    obj.Interfaces(index).setType(type);
                end
                if any(strcmp(displayLabel,{autosar.ui.metamodel.PackageString.InterfacesNodeName,...
                    autosar.ui.metamodel.PackageString.NvDataInterfacesNodeName,...
                    autosar.ui.metamodel.PackageString.ParameterInterfacesNodeName}))
                    obj.Interfaces(index).setDataElementCount(interfaceProperty);
                elseif strcmp(displayLabel,autosar.ui.metamodel.PackageString.ModeSwitchInterfacesNodeName)
                    obj.Interfaces(index).setModeGroupName(interfaceProperty);
                elseif strcmp(displayLabel,autosar.ui.metamodel.PackageString.ClientServerInterfacesNodeName)
                    obj.CSInterfaces(index).setOperationCount(interfaceProperty);
                elseif strcmp(displayLabel,autosar.ui.metamodel.PackageString.TriggerInterfacesNodeName)
                    obj.Interfaces(index).setDataElementCount(interfaceProperty);
                end
            end
        end

        function setPortFormatCtl(obj,fmtCtl)
            obj.PortFormatCtl=fmtCtl;
        end

        function addPort(obj,name,interface,type)
            port=autosar.ui.wizard.builder.Port(name,interface,type);
            obj.Ports(end+1)=port;
        end

        function addServicePort(obj,name,interface,type)
            port=autosar.ui.wizard.builder.Port(name,interface,type);
            obj.ServicePorts(end+1)=port;
        end

        function addPersistencyPort(obj,name,interface,type)
            port=autosar.ui.wizard.builder.Port(name,interface,type);
            obj.PersistencyPorts(end+1)=port;
        end

        function addCSPort(obj,name,interface,type)
            port=autosar.ui.wizard.builder.Port(name,interface,type);
            obj.CSPorts(end+1)=port;
        end

        function ret=setPort(obj,index,name,interface,type)
            ret=0;
            if strcmp(type,autosar.ui.wizard.PackageString.PortTypes{4})||...
                strcmp(type,autosar.ui.wizard.PackageString.PortTypes{6})
                assert(index<=length(obj.CSPorts),autosar.ui.wizard.PackageString.InvalidIndexError);
            elseif strcmp(type,autosar.ui.wizard.PackageString.PortTypes{13})||...
                strcmp(type,autosar.ui.wizard.PackageString.PortTypes{14})
                assert(index<=length(obj.ServicePorts),autosar.ui.wizard.PackageString.InvalidIndexError);
            elseif strcmp(type,autosar.ui.wizard.PackageString.PortTypes{15})||...
                strcmp(type,autosar.ui.wizard.PackageString.PortTypes{16})||...
                strcmp(type,autosar.ui.wizard.PackageString.PortTypes{17})
                assert(index<=length(obj.PersistencyPorts),autosar.ui.wizard.PackageString.InvalidIndexError);
            else
                assert(index<=length(obj.Ports),autosar.ui.wizard.PackageString.InvalidIndexError);
            end
            maxShortNameLength=autosar.ui.utils.getAutosarMaxShortNameLength(obj.ModelName);
            idcheckmessage=autosar.ui.utils.isValidARIdentifier({name},'shortName',maxShortNameLength);
            if~isempty(idcheckmessage)
                errordlg(idcheckmessage,autosar.ui.metamodel.PackageString.ErrorTitle,'replace');
                ret=-1;
            else

                mmgr=get_param(obj.ModelName,'MappingManager');
                mapping=mmgr.getActiveMappingFor(autosar.api.Utils.getMappingType(obj.ModelName));
                if~isempty(mapping)
                    arModel=autosar.api.Utils.m3iModel(obj.ModelName);
                    mappedComp=[];
                    for i=1:length(autosar.ui.metamodel.PackageString.ComponentsCell)
                        compNodes=autosar.ui.utils.collectObject(arModel,...
                        autosar.ui.metamodel.PackageString.ComponentsCell(i));
                        for k=1:length(compNodes)
                            if strncmp(compNodes(k).Name,obj.ComponentName,maxShortNameLength-4)
                                mappedComp=compNodes(k);
                                break;
                            end
                        end
                        if~isempty(mappedComp)
                            break;
                        end
                    end
                    assert(~isempty(mappedComp));
                    protectedNames={};
                    for ii=1:length(autosar.ui.configuration.PackageString.Ports)
                        ports=autosar.ui.utils.collectObject(mappedComp,...
                        autosar.ui.configuration.PackageString.Ports{ii});
                        for jj=1:length(ports)
                            protectedNames=[protectedNames,ports(jj).Name];%#ok<AGROW>
                        end
                    end
                    if any(ismember(protectedNames,name))
                        errordlg(DAStudio.message('RTW:autosar:errorDuplicatePort',name),...
                        autosar.ui.metamodel.PackageString.ErrorTitle,'replace');
                        ret=-1;
                        return;
                    end
                end

                if strcmp(type,autosar.ui.wizard.PackageString.PortTypes{5})||...
                    strcmp(type,autosar.ui.wizard.PackageString.PortTypes{9})
                    schemaVersion=get_param(obj.ModelName,'AutosarSchemaVersion');
                    [~,message]=autosar.validation.ClassicMetaModelValidator.verifyPRPort(...
                    name,schemaVersion);
                    if~isempty(message)
                        errordlg(message,...
                        autosar.ui.metamodel.PackageString.ErrorTitle,'replace');
                        ret=-1;
                        return;
                    end
                end

                if strcmp(type,autosar.ui.wizard.PackageString.PortTypes{4})||...
                    strcmp(type,autosar.ui.wizard.PackageString.PortTypes{6})
                    obj.CSPorts(index).setName(name);
                    obj.CSPorts(index).setInterface(interface);
                    obj.CSPorts(index).setType(type);
                elseif strcmp(type,autosar.ui.wizard.PackageString.PortTypes{13})||...
                    strcmp(type,autosar.ui.wizard.PackageString.PortTypes{14})
                    obj.ServicePorts(index).setName(name);
                    obj.ServicePorts(index).setInterface(interface);
                    obj.ServicePorts(index).setType(type);
                elseif strcmp(type,autosar.ui.wizard.PackageString.PortTypes{15})||...
                    strcmp(type,autosar.ui.wizard.PackageString.PortTypes{16})||...
                    strcmp(type,autosar.ui.wizard.PackageString.PortTypes{17})
                    obj.PersistencyPorts(index).setName(name);
                    obj.PersistencyPorts(index).setInterface(interface);
                    obj.PersistencyPorts(index).setType(type);
                else
                    obj.Ports(index).setName(name);
                    obj.Ports(index).setInterface(interface);
                    obj.Ports(index).setType(type);
                end
            end
        end

        function removePort(obj,port)
            assert(length(port)==1,autosar.ui.wizard.PackageString.PortMulDeleteError);
            if iscell(port)
                port=port{1}.Source;
            end
            if strcmp(port.PortType,autosar.ui.wizard.PackageString.PortTypes(4))
                for i=1:length(obj.CSPorts)
                    if obj.CSPorts(i)==port
                        obj.CSPorts(i).delete;
                        obj.CSPorts(i)=[];
                        break;
                    end
                end
            elseif any(strcmp(port.PortType,autosar.ui.wizard.PackageString.PortTypes(13:14)))
                for i=1:length(obj.ServicePorts)
                    if obj.ServicePorts(i)==port
                        obj.ServicePorts(i).delete;
                        obj.ServicePorts(i)=[];
                        break;
                    end
                end
            elseif any(strcmp(port.PortType,autosar.ui.wizard.PackageString.PortTypes(15:17)))
                for i=1:length(obj.PersistencyPorts)
                    if obj.PersistencyPorts(i)==port
                        obj.PersistencyPorts(i).delete;
                        obj.PersistencyPorts(i)=[];
                        break;
                    end
                end
            else
                for i=1:length(obj.Ports)
                    if obj.Ports(i)==port
                        obj.Ports(i).delete;
                        obj.Ports(i)=[];
                        break;
                    end
                end
            end
        end

        function setDefaultConfiguration(obj,modelH)

            assert(isscalar(modelH)&&ishandle(modelH),'Expecting a model handle');

            obj.IsDefaultConfig=true;
            slInports=find_system(obj.ModelName,'SearchDepth',1,'blocktype','Inport','OutputFunctionCall','off');
            slOutports=find_system(obj.ModelName,'SearchDepth',1,'blocktype','Outport');
            if Simulink.internal.useFindSystemVariantsMatchFilter()
                slServers=find_system(obj.ModelName,'FollowLinks','on','LookUnderMasks','all',...
                'MatchFilter',@Simulink.match.activeVariants,...
                'blocktype','SubSystem','IsSimulinkFunction','on');
                slClients=find_system(obj.ModelName,'MatchFilter',@Simulink.match.codeCompileVariants,...
                'FollowLinks','on','LookUnderMasks','all','blocktype','FunctionCaller');
            else
                slServers=find_system(obj.ModelName,'FollowLinks','on','LookUnderMasks','all',...
                'blocktype','SubSystem','IsSimulinkFunction','on');
                slClients=find_system(obj.ModelName,'Variants','ActivePlusCodeVariants','FollowLinks','on',...
                'LookUnderMasks','all','blocktype','FunctionCaller');
            end



            bswClients=autosar.bsw.BasicSoftwareCaller.find(obj.ModelName);
            slClients=setdiff(slClients,bswClients);

            maxShortNameLength=autosar.ui.utils.getAutosarMaxShortNameLength(modelH);

            obj.Ports=[];
            obj.CSPorts=[];
            obj.ServicePorts=[];
            obj.Interfaces=[];
            obj.CSInterfaces=[];
            obj.ServiceInterfaces=[];
            obj.PersistencyPorts=[];
            obj.PersistencyKeyValueInterfaces=[];
            if obj.IsAdaptive






                numEvents=length(slInports);
                numMethods=0;
                if numEvents>0
                    portName=autosar.ui.metamodel.PackageString.DefaultRequiredPortName;
                    itfName=autosar.ui.metamodel.PackageString.DefaultRequiredServiceInterfaceName;

                    ServiceInterface=autosar.ui.wizard.builder.ServiceInterface(...
                    itfName,num2str(numEvents),num2str(numMethods),...
                    autosar.ui.wizard.PackageString.InterfaceTypes(1));
                    ServicePort=autosar.ui.wizard.builder.Port(...
                    portName,...
                    itfName,...
                    autosar.ui.wizard.PackageString.PortTypes(14));
                    obj.ServicePorts=[obj.ServicePorts,ServicePort];
                    obj.ServiceInterfaces=[obj.ServiceInterfaces,ServiceInterface];
                end


                numEvents=length(slOutports);
                numMethods=0;
                if numEvents>0
                    portName=autosar.ui.metamodel.PackageString.DefaultProvidedPortName;
                    itfName=autosar.ui.metamodel.PackageString.DefaultProvidedServiceInterfaceName;

                    ServiceInterface=autosar.ui.wizard.builder.ServiceInterface(...
                    itfName,num2str(numEvents),num2str(numMethods),...
                    autosar.ui.wizard.PackageString.InterfaceTypes(1));
                    ServicePort=autosar.ui.wizard.builder.Port(...
                    portName,...
                    itfName,...
                    autosar.ui.wizard.PackageString.PortTypes(13));
                    obj.ServicePorts=[obj.ServicePorts,ServicePort];
                    obj.ServiceInterfaces=[obj.ServiceInterfaces,ServiceInterface];
                end
            else
                for portIndex=1:length(slInports)
                    portName=arblk.convertPortNameToArgName(...
                    get_param(slInports{portIndex},'name'));
                    portName=arxml.arxml_private('p_create_aridentifier',...
                    portName,maxShortNameLength);
                    interfaceName=portName;
                    if autosar.composition.Utils.isCompositePortBlock(slInports{portIndex})
                        [isUsingBus,busName]=autosar.simulink.bep.Utils.isBEPUsingBusObject(slInports{portIndex});
                        if isUsingBus
                            interfaceName=busName;
                        end
                    end
                    Interface=autosar.ui.wizard.builder.SenderReceiverInterface(...
                    interfaceName,'1',...
                    autosar.ui.wizard.PackageString.InterfaceTypes(1));
                    Port=autosar.ui.wizard.builder.Port(...
                    portName,...
                    interfaceName,...
                    autosar.ui.wizard.PackageString.PortTypes(2));
                    obj.Ports=[obj.Ports,Port];
                    obj.Interfaces=[obj.Interfaces,Interface];
                end

                for portIndex=1:length(slOutports)
                    portName=arblk.convertPortNameToArgName(...
                    get_param(slOutports{portIndex},'name'));
                    portName=arxml.arxml_private('p_create_aridentifier',...
                    portName,maxShortNameLength);
                    interfaceName=portName;
                    if autosar.composition.Utils.isCompositePortBlock(slOutports{portIndex})
                        [isUsingBus,busName]=autosar.simulink.bep.Utils.isBEPUsingBusObject(slOutports{portIndex});
                        if isUsingBus
                            interfaceName=busName;
                        end
                    end
                    Interface=autosar.ui.wizard.builder.SenderReceiverInterface(...
                    interfaceName,'1',...
                    autosar.ui.wizard.PackageString.InterfaceTypes(1));
                    Port=autosar.ui.wizard.builder.Port(...
                    portName,...
                    interfaceName,...
                    autosar.ui.wizard.PackageString.PortTypes(1));
                    obj.Ports=[obj.Ports,Port];
                    obj.Interfaces=[obj.Interfaces,Interface];
                end
                for srIndex=1:length(slServers)
                    functionH=get_param(slServers{srIndex},'Handle');

                    if autosar.utils.SimulinkFunction.isGlobalSimulinkFunction(functionH)
                        fcnName=autosar.ui.utils.getSlFunctionName(functionH);
                        portName=arxml.arxml_private('p_create_aridentifier',...
                        fcnName,maxShortNameLength);
                        Interface=autosar.ui.wizard.builder.ClientServerInterface(...
                        fcnName,'1',...
                        autosar.ui.wizard.PackageString.InterfaceTypes(1));
                        Port=autosar.ui.wizard.builder.Port(...
                        portName,...
                        fcnName,...
                        autosar.ui.wizard.PackageString.PortTypes(4));
                        obj.CSPorts=[obj.CSPorts,Port];
                        obj.CSInterfaces=[obj.CSInterfaces,Interface];
                    end
                end
                for clIndex=1:length(slClients)
                    fcnName=autosar.ui.utils.getSlFunctionName(slClients{clIndex});
                    if contains(fcnName,'.')










                        continue;
                    end

                    portName=[fcnName,autosar.ui.wizard.PackageString.FcnCallSuffix];
                    portName=arxml.arxml_private('p_create_aridentifier',...
                    portName,maxShortNameLength);
                    existingPort=[];
                    existingInterface=[];
                    if~isempty(obj.CSPorts)
                        existingPort=obj.CSPorts.findobj('Name',portName);
                    end
                    if isempty(existingPort)
                        Port=autosar.ui.wizard.builder.Port(...
                        portName,...
                        fcnName,...
                        autosar.ui.wizard.PackageString.PortTypes(6));
                        obj.CSPorts=[obj.CSPorts,Port];
                    end
                    if~isempty(obj.CSInterfaces)
                        existingInterface=obj.CSInterfaces.findobj('Name',...
                        fcnName);
                    end
                    if isempty(existingInterface)
                        Interface=autosar.ui.wizard.builder.ClientServerInterface(...
                        fcnName,'1',...
                        autosar.ui.wizard.PackageString.InterfaceTypes(1));
                        obj.CSInterfaces=[obj.CSInterfaces,Interface];
                    end
                end
            end
        end

        function populateCorePackages(obj,m3iSWC,modelName)%#ok<INUSD>




            import autosar.mm.util.XmlOptionsAdapter;

            maxShortNameLength=autosar.ui.utils.getAutosarMaxShortNameLength(modelName);
            if Simulink.AutosarDictionary.ModelRegistry.hasReferencedModels(m3iSWC.rootModel)
                sharedM3IModel=autosar.dictionary.Utils.getUniqueReferencedModel(m3iSWC.rootModel);
            else
                sharedM3IModel=m3iSWC.rootModel;
            end
            assert(sharedM3IModel.RootPackage.size==1);
            arRootShared=sharedM3IModel.RootPackage.front();
            intBehQName=autosar.mm.util.XmlOptionsDefaultPackages.getInternalBehaviorQualifiedName(...
            m3iSWC.Name,maxShortNameLength);
            impQName=autosar.mm.util.XmlOptionsDefaultPackages.getImplementationQualifiedName(...
            m3iSWC.Name,maxShortNameLength);

            if isempty(arRootShared.DataTypePackage)
                arRootShared.DataTypePackage=autosar.mm.util.XmlOptionsDefaultPackages.DataTypesPackage;
            end

            if isempty(arRootShared.InterfacePackage)
                arRootShared.InterfacePackage=autosar.mm.util.XmlOptionsDefaultPackages.InterfacesPackage;
            end

            if isempty(XmlOptionsAdapter.get(m3iSWC,'InternalBehaviorQualifiedName'))
                XmlOptionsAdapter.set(m3iSWC,'InternalBehaviorQualifiedName',intBehQName);
            end

            if isempty(XmlOptionsAdapter.get(m3iSWC,'ImplementationQualifiedName'))
                XmlOptionsAdapter.set(m3iSWC,'ImplementationQualifiedName',impQName);
            end
        end

        function populateMetamodel(obj,m3iModel,modelName)



            assert(m3iModel.RootPackage.size==1);
            arRoot=m3iModel.RootPackage.front();
            if~autosar.api.Utils.isUsingSharedAutosarDictionary(modelName)
                m3iModelShared=m3iModel;
                arRootShared=arRoot;
            else
                m3iModelShared=autosarcore.ModelUtils.getSharedElementsM3IModel(modelName);
                arRootShared=m3iModelShared.RootPackage.front();
            end

            compPath=obj.ComponentPackage;
            compName=obj.ComponentName;
            m3iSWCPkg=autosar.mm.Model.getOrAddARPackage(m3iModel,compPath);


            m3iIfPkg=autosar.mm.Model.getOrAddARPackage(m3iModelShared,obj.InterfacePackage);
            if~obj.IsAdaptive
                m3iCSIfPkg=autosar.mm.Model.getOrAddARPackage(m3iModelShared,obj.CSInterfacePackage);
            end


            arRoot.ComponentQualifiedName='';


            metaClassStr=autosar.ui.wizard.builder.Component.getMetaClassStrings(obj.IsAdaptive);

            m3iSWC=autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(...
            m3iSWCPkg,m3iSWCPkg.packagedElement,compName,metaClassStr.compMetaClass);

            obj.populateCorePackages(m3iSWC,modelName);

            switch obj.ComponentType
            case autosar.ui.wizard.PackageString.ComponentTypes(1:5)
                m3iSWC.Kind=Simulink.metamodel.arplatform.component.AtomicComponentKind.(obj.ComponentType);
            case autosar.ui.wizard.PackageString.ComponentTypes{6}

            otherwise
                assert(false,'wizard.Component: Invalid component type');
            end
            mapObj=containers.Map;

            if obj.IsWizardMode

                for ifIdx=1:length(obj.Interfaces)
                    interface=obj.Interfaces(ifIdx);
                    m3iInterface=...
                    autosar.mm.sl2mm.ModelBuilder.createInSequenceNamedItem(...
                    m3iIfPkg,m3iIfPkg.packagedElement,interface.Name,metaClassStr.srifCls);
                    if strcmp(interface.InterfaceType,autosar.ui.wizard.PackageString.InterfaceTypes{2})
                        m3iInterface.IsService=true;
                    end
                    mapObj(interface.Name)=m3iInterface;
                    dElementName=interface.Name;
                    for deIdx=1:str2num(interface.DataElementCount)%#ok<ST2NM>
                        if~obj.IsDefaultConfig
                            dElementName=[autosar.ui.wizard.PackageString.DataElementNewName,...
                            num2str(deIdx)];
                        end
                        m3iData=...
                        autosar.mm.sl2mm.ModelBuilder.createInSequenceNamedItem(...
                        m3iInterface,m3iInterface.DataElements,...
                        dElementName,metaClassStr.dataCls);%#ok<NASGU>
                    end
                end
                for ifIdx=1:length(obj.CSInterfaces)
                    interface=obj.CSInterfaces(ifIdx);



                    m3iInterface=...
                    autosar.mm.sl2mm.ModelBuilder.findInSequenceNamedItem(...
                    m3iCSIfPkg,m3iCSIfPkg.packagedElement,interface.Name,metaClassStr.csifCls);
                    if~m3iInterface.isvalid()
                        m3iInterface=...
                        autosar.mm.sl2mm.ModelBuilder.createInSequenceNamedItem(...
                        m3iCSIfPkg,m3iCSIfPkg.packagedElement,interface.Name,metaClassStr.csifCls);
                        if strcmp(interface.InterfaceType,autosar.ui.wizard.PackageString.InterfaceTypes{2})
                            m3iInterface.IsService=true;
                        end
                        mapObj(interface.Name)=m3iInterface;
                        opName=interface.Name;
                        for deIdx=1:str2num(interface.OperationCount)%#ok<ST2NM>
                            if~obj.IsDefaultConfig
                                opName=[autosar.ui.wizard.PackageString.OperationNewName,...
                                num2str(deIdx)];
                            end
                            m3iOp=...
                            autosar.mm.sl2mm.ModelBuilder.createInSequenceNamedItem(...
                            m3iInterface,m3iInterface.Operations,...
                            opName,metaClassStr.opCls);
                            if obj.IsDefaultConfig

                                autosar.ui.utils.addArguments(modelName,opName,m3iOp);
                            end
                        end
                    end
                end


                slInports=find_system(obj.ModelName,'SearchDepth',1,'blocktype','Inport','OutputFunctionCall','off');
                numInports=length(slInports);
                slOutports=find_system(obj.ModelName,'SearchDepth',1,'blocktype','Outport');
                numOutports=length(slOutports);
                for ifIdx=1:length(obj.ServiceInterfaces)
                    interface=obj.ServiceInterfaces(ifIdx);
                    m3iInterface=...
                    autosar.mm.sl2mm.ModelBuilder.createInSequenceNamedItem(...
                    m3iIfPkg,m3iIfPkg.packagedElement,interface.Name,metaClassStr.svcifCls);
                    if strcmp(interface.InterfaceType,autosar.ui.wizard.PackageString.InterfaceTypes{2})
                        m3iInterface.IsService=true;
                    end
                    mapObj(interface.Name)=m3iInterface;
                    eventCount=str2double(interface.EventCount);
                    methodCount=str2double(interface.MethodCount);
                    if obj.IsDefaultConfig


                        isInterfaceForInports=(numInports==eventCount)&&...
                        (~(numOutports==eventCount)||ifIdx==1);
                    end
                    for eventIdx=1:eventCount
                        if~obj.IsDefaultConfig
                            eventName=[autosar.ui.wizard.PackageString.EventNewName,...
                            num2str(eventIdx)];
                        else


                            if isInterfaceForInports
                                eventName=get_param(slInports{eventIdx},'Name');
                            else
                                eventName=get_param(slOutports{eventIdx},'Name');
                            end
                        end

                        m3iData=...
                        autosar.mm.sl2mm.ModelBuilder.createInSequenceNamedItem(...
                        m3iInterface,m3iInterface.Events,...
                        eventName,metaClassStr.eventCls);%#ok<NASGU>
                    end
                    for methodIdx=1:methodCount
                        if~obj.IsDefaultConfig
                            methodName=[autosar.ui.wizard.PackageString.MethodNewName,...
                            num2str(methodIdx)];
                        end
                        m3iData=...
                        autosar.mm.sl2mm.ModelBuilder.createInSequenceNamedItem(...
                        m3iInterface,m3iInterface.Methods,...
                        methodName,methodCls);
                        if obj.IsDefaultConfig

                            autosar.ui.utils.addArguments(modelName,methodName,m3iData);
                        end
                    end
                end


                for pIdx=1:length(obj.Ports)
                    port=obj.Ports(pIdx);
                    if strcmp(port.PortType,autosar.ui.wizard.PackageString.PortTypes(1))

                        m3iPort=...
                        autosar.mm.sl2mm.ModelBuilder.createInSequenceNamedItem(...
                        m3iSWC,m3iSWC.SenderPorts,port.Name,metaClassStr.pPortCls);
                    elseif strcmp(port.PortType,autosar.ui.wizard.PackageString.PortTypes(2))
                        m3iPort=...
                        autosar.mm.sl2mm.ModelBuilder.createInSequenceNamedItem(...
                        m3iSWC,m3iSWC.ReceiverPorts,port.Name,metaClassStr.rPortCls);
                    elseif strcmp(port.PortType,autosar.ui.wizard.PackageString.PortTypes(5))
                        m3iPort=...
                        autosar.mm.sl2mm.ModelBuilder.createInSequenceNamedItem(...
                        m3iSWC,m3iSWC.SenderReceiverPorts,port.Name,metaClassStr.prPortCls);
                    else
                        assert(false,'Unknown port type');
                    end
                    m3iInterface=mapObj(port.Interface);
                    m3iPort.Interface=m3iInterface;
                end
                for pIdx=1:length(obj.CSPorts)
                    port=obj.CSPorts(pIdx);
                    if strcmp(port.PortType,autosar.ui.wizard.PackageString.PortTypes(4))
                        m3iPort=...
                        autosar.mm.sl2mm.ModelBuilder.createInSequenceNamedItem(...
                        m3iSWC,m3iSWC.ServerPorts,port.Name,metaClassStr.sPortCls);
                    elseif strcmp(port.PortType,autosar.ui.wizard.PackageString.PortTypes(6))
                        m3iPort=...
                        autosar.mm.sl2mm.ModelBuilder.createInSequenceNamedItem(...
                        m3iSWC,m3iSWC.ClientPorts,port.Name,metaClassStr.cPortCls);
                    else
                        assert(false,'Unknown port type');
                    end
                    m3iInterface=mapObj(port.Interface);
                    m3iPort.Interface=m3iInterface;
                end
                for pIdx=1:length(obj.ServicePorts)
                    port=obj.ServicePorts(pIdx);
                    if strcmp(port.PortType,autosar.ui.wizard.PackageString.PortTypes(13))

                        m3iPort=...
                        autosar.mm.sl2mm.ModelBuilder.createInSequenceNamedItem(...
                        m3iSWC,m3iSWC.ProvidedPorts,port.Name,metaClassStr.svcProPortCls);
                    elseif strcmp(port.PortType,autosar.ui.wizard.PackageString.PortTypes(14))

                        m3iPort=...
                        autosar.mm.sl2mm.ModelBuilder.createInSequenceNamedItem(...
                        m3iSWC,m3iSWC.RequiredPorts,port.Name,metaClassStr.svcReqPortCls);
                    else
                        assert(false,'Unknown port type');
                    end
                    m3iInterface=mapObj(port.Interface);
                    m3iPort.Interface=m3iInterface;
                end
                for pIdx=1:length(obj.PersistencyPorts)
                    port=obj.PersistencyPorts(pIdx);
                    if strcmp(port.PortType,autosar.ui.wizard.PackageString.PortTypes(15))

                        m3iPort=...
                        autosar.mm.sl2mm.ModelBuilder.createInSequenceNamedItem(...
                        m3iSWC,m3iSWC.PersistencyProvidedPorts,port.Name,metaClassStr.pstProPortCls);
                    elseif strcmp(port.PortType,autosar.ui.wizard.PackageString.PortTypes(16))

                        m3iPort=...
                        autosar.mm.sl2mm.ModelBuilder.createInSequenceNamedItem(...
                        m3iSWC,m3iSWC.PersistencyRequiredPorts,port.Name,metaClassStr.pstReqPortCls);
                    elseif strcmp(port.PortType,autosar.ui.wizard.PackageString.PortTypes(17))

                        m3iPort=...
                        autosar.mm.sl2mm.ModelBuilder.createInSequenceNamedItem(...
                        m3iSWC,m3iSWC.PersistencyProvidedRequiredPorts,port.Name,metaClassStr.pstProReqPortCls);
                    else
                        assert(false,'Unknown port type');
                    end
                    m3iInterface=mapObj(port.Interface);
                    m3iPort.Interface=m3iInterface;
                end
            end

            if~obj.IsAdaptive&&~obj.PreserveExistingMapping&&~obj.IsUsingInterfaceDict


                addrPkg=...
                autosar.ui.metamodel.SwAddrMethod.getDefaultSwAddrMethodPackage(...
                arRootShared);

                autosar.mm.util.XmlOptionsAdapter.set(arRootShared,'SwAddressMethodPackage',...
                addrPkg);
                m3iSwAddrMethodPkg=autosar.mm.Model.getOrAddARPackage(m3iModelShared,addrPkg);
                defaultSwAddrMethodNames=autosar.ui.metamodel.PackageString.DefaultSwAddrMethods;
                defaultSectionTypes={Simulink.metamodel.arplatform.behavior.SectionTypeKind.Code,...
                Simulink.metamodel.arplatform.behavior.SectionTypeKind.Const,...
                Simulink.metamodel.arplatform.behavior.SectionTypeKind.Var};
                for i=1:length(defaultSwAddrMethodNames)
                    m3iSwAddrMethod=Simulink.metamodel.arplatform.common.SwAddrMethod(m3iSwAddrMethodPkg.rootModel);
                    m3iSwAddrMethod.Name=defaultSwAddrMethodNames{i};

                    m3iSwAddrMethod.SectionType=defaultSectionTypes{i};
                    autosar.ui.metamodel.PackageString.DefaultMemoryAllocationKeywordPolicy;
                    m3iSwAddrMethodPkg.packagedElement.append(m3iSwAddrMethod);
                end
            end
        end

        function buildMapping(obj,model,mode)

            assert(strcmp(mode,'interactive')||strcmp(mode,'cmdline'));

            mapping=autosar.api.Utils.modelMapping(model);
            assert(~isempty(mapping));

            m3iModel=autosar.api.Utils.m3iModel(model);

            if~autosar.api.Utils.isUsingSharedAutosarDictionary(model)
                m3iModelShared=m3iModel;
            else
                m3iModelShared=autosarcore.ModelUtils.getSharedElementsM3IModel(model);
            end

            compObjSeq=autosar.mm.Model.findObjectByName(m3iModel,...
            [obj.ComponentPackage,'/',obj.ComponentName]);
            assert(compObjSeq.size()==1);
            m3iComp=compObjSeq.at(1);

            obj.ComponentAdapter.mapM3iComponent(m3iComp);

            maxShortNameLength=autosar.ui.utils.getAutosarMaxShortNameLength(model);
            modelName=get_param(model,'Name');

            slMappingApi=autosar.api.getSimulinkMapping(model,obj.ChangeLogger);
            if obj.IsDefaultConfig
                [outportIsMessage,inportIsMessage]=autosar.ui.wizard.builder.Component.getForceCompiledData(modelName,mapping,mode);


                obj.mapInportsAndOutports(modelName,mapping,slMappingApi,m3iModelShared,m3iComp,obj.IsAdaptive,mode,inportIsMessage,outportIsMessage);
                if~obj.IsAdaptive

                    obj.mapFunctionCallers(modelName,mapping,slMappingApi,m3iModelShared,m3iComp);



                    if~isempty(mapping.FunctionCallers)
                        autosar.ui.wizard.builder.Component.mapCallersWithSameNameToExistingCallers(mapping.FunctionCallers);
                    end




                    obj.createDefaultPortParameterMapping(modelName,mapping,slMappingApi,m3iModelShared,m3iComp);
                end
            end

            if obj.IsAdaptive
                if obj.IsDefaultConfig

                    autosar.internal.adaptive.manifest.ManifestUtilities.syncManifestMetaModelWithAutosarDictionary(obj.ModelName);
                end

                return;
            end

            m3iBehavior=m3iComp.Behavior;
            if~m3iBehavior.isvalid()
                m3iBehavior=...
                Simulink.metamodel.arplatform.behavior.ApplicationComponentBehavior(m3iModel);
                m3iBehavior.Name=autosar.ui.metamodel.PackageString.behaviorNode;
                compObjSeq.at(1).Behavior=m3iBehavior;
            end

            if isempty(mapping.InitializeFunctions.MappedTo.Runnable)
                defaultRunnableName=arxml.arxml_private('p_create_aridentifier',...
                [modelName,'_Init'],maxShortNameLength);
                runnableName=obj.getUniqueItemNameNameForAddingToSeq(...
                m3iBehavior,defaultRunnableName);
                initRunnable=autosar.ui.wizard.builder.Component.findOrCreateNamedItemInSequence(...
                m3iBehavior,m3iBehavior.Runnables,runnableName,...
                Simulink.metamodel.arplatform.behavior.Runnable.MetaClass);
                initRunnable.symbol=initRunnable.Name;

                slMappingApi.mapFunction('Initialize',initRunnable.Name);
            end

            if~isempty(mapping.TerminateFunctions)
                if isempty(mapping.TerminateFunctions.MappedTo.Runnable)
                    defaultRunnableName=arxml.arxml_private('p_create_aridentifier',...
                    [modelName,'_Terminate'],maxShortNameLength);
                    runnableName=obj.getUniqueItemNameNameForAddingToSeq(...
                    m3iBehavior,defaultRunnableName);
                    terminateRunnable=autosar.ui.wizard.builder.Component.findOrCreateNamedItemInSequence(...
                    m3iBehavior,m3iBehavior.Runnables,runnableName,...
                    Simulink.metamodel.arplatform.behavior.Runnable.MetaClass);
                    terminateRunnable.symbol=terminateRunnable.Name;

                    slMappingApi.mapFunction('Terminate',terminateRunnable.Name);
                end
            end

            periodicRate=1;
            isExportStyle=autosar.validation.ExportFcnValidator.isTopModelExportFcn(model);

            for dIdx=1:length(mapping.FcnCallInports)
                blkMapping=mapping.FcnCallInports(dIdx);
                fcnCallPortBlock=blkMapping.Block;
                fcnName=get_param(fcnCallPortBlock,'Name');
                if~slMappingApi.isFunctionMapped(['ExportedFunction:',fcnName])
                    defaultRunnableName=arblk.convertPortNameToArgName(...
                    arxml.arxml_private('p_create_aridentifier',fcnName,maxShortNameLength));
                    runnableName=obj.getUniqueItemNameNameForAddingToSeq(...
                    m3iBehavior,defaultRunnableName);
                    m3iRunnable=autosar.ui.wizard.builder.Component.findOrCreateNamedItemInSequence(...
                    m3iBehavior,m3iBehavior.Runnables,runnableName,...
                    Simulink.metamodel.arplatform.behavior.Runnable.MetaClass);
                    m3iRunnable.symbol=m3iRunnable.Name;
                    slMappingApi.mapFunction(['ExportedFunction:',fcnName],m3iRunnable.Name);
                else


                    runnableName=slMappingApi.getFunction(['ExportedFunction:',fcnName]);
                    m3iRunnable=autosar.mm.Model.findElementInSequenceByName(...
                    m3iBehavior.Runnables,runnableName);
                end

                if m3iRunnable.Events.isEmpty()
                    sampleTimeExpr=get_param(fcnCallPortBlock,'SampleTime');
                    sampleTime=slResolve(sampleTimeExpr,fcnCallPortBlock);
                    evtName=arxml.arxml_private('p_create_aridentifier',...
                    [autosar.ui.wizard.PackageString.EventPrefix,m3iRunnable.Name],...
                    maxShortNameLength);
                    if sampleTime==-1
                        obj.createDefaultExternalTriggerEventForRunnable(m3iRunnable,m3iModelShared,evtName);
                    else

                        timeEvt=autosar.ui.wizard.builder.Component.findOrCreateNamedItemInSequence(...
                        m3iBehavior,m3iBehavior.Events,evtName,...
                        Simulink.metamodel.arplatform.behavior.TimingEvent.MetaClass);
                        timeEvt.StartOnEvent=m3iRunnable;
                        timeEvt.Period=periodicRate;
                    end
                end
            end
            if~isExportStyle
                if~isempty(mapping.StepFunctions)
                    for stepMapIdx=1:length(mapping.StepFunctions)
                        if stepMapIdx==1
                            tid='';
                        else
                            tid=num2str(stepMapIdx-1);
                        end

                        stepFunctionMapping=mapping.StepFunctions(stepMapIdx);

                        if~isempty(stepFunctionMapping.MappedTo.Runnable)
                            continue;
                        end


                        partitionName=stepFunctionMapping.PartitionName;
                        if~isempty(partitionName)

                            defaultRunnableName=partitionName;
                        else

                            defaultRunnableName=arxml.arxml_private('p_create_aridentifier',...
                            [modelName,'_Step',tid],maxShortNameLength);
                        end
                        runnableName=obj.getUniqueItemNameNameForAddingToSeq(...
                        m3iBehavior,defaultRunnableName);
                        periodicRunnable=autosar.ui.wizard.builder.Component.findOrCreateNamedItemInSequence(...
                        m3iBehavior,m3iBehavior.Runnables,runnableName,...
                        Simulink.metamodel.arplatform.behavior.Runnable.MetaClass);
                        periodicRunnable.symbol=periodicRunnable.Name;


                        if periodicRunnable.Events.isEmpty()
                            evtName=arxml.arxml_private('p_create_aridentifier',...
                            [autosar.ui.wizard.PackageString.EventPrefix,periodicRunnable.Name],...
                            maxShortNameLength);

                            if stepFunctionMapping.isAperiodicPartition()
                                obj.createDefaultExternalTriggerEventForRunnable(periodicRunnable,m3iModelShared,evtName);
                            else
                                timeEvt=autosar.ui.wizard.builder.Component.findOrCreateNamedItemInSequence(...
                                m3iBehavior,m3iBehavior.Events,evtName,...
                                Simulink.metamodel.arplatform.behavior.TimingEvent.MetaClass);
                                timeEvt.StartOnEvent=periodicRunnable;
                                timeEvt.Period=mapping.StepFunctions(stepMapIdx).Period;
                            end
                        end

                        if length(mapping.StepFunctions)==1

                            slMappingApi.mapFunction('Periodic',periodicRunnable.Name);
                        else

                            if~coder.mapping.internal.doPeriodicFunctionMappingsHaveId(...
                                mapping.StepFunctions)
                                DAStudio.error('coderdictionary:api:InvalidPeriodicFunctionId',modelName);
                            end

                            taskConnectivityGraph=sltp.TaskConnectivityGraph(modelName);
                            taskName=taskConnectivityGraph.getTask(stepFunctionMapping.Id);
                            slMappingApi.mapFunction(['Periodic:',taskName],periodicRunnable.Name);
                        end
                    end
                end
            end
            if~isempty(mapping.ResetFunctions)
                for resetMapIdx=1:length(mapping.ResetFunctions)
                    fcnName=mapping.ResetFunctions(resetMapIdx).Name;

                    if slMappingApi.isFunctionMapped(['Reset:',fcnName])
                        continue;
                    end
                    tid=num2str(resetMapIdx);

                    defaultRunnableName=arxml.arxml_private('p_create_aridentifier',...
                    [modelName,'_Reset',tid],maxShortNameLength);
                    runnableName=obj.getUniqueItemNameNameForAddingToSeq(...
                    m3iBehavior,defaultRunnableName);
                    resetRunnable=autosar.ui.wizard.builder.Component.findOrCreateNamedItemInSequence(...
                    m3iBehavior,m3iBehavior.Runnables,runnableName,...
                    Simulink.metamodel.arplatform.behavior.Runnable.MetaClass);
                    resetRunnable.symbol=resetRunnable.Name;
                    slMappingApi.mapFunction(['Reset:',fcnName],resetRunnable.Name);
                end
            end

            if~isempty(mapping.ServerFunctions)

                metaClassStr=autosar.ui.wizard.builder.Component.getMetaClassStrings(false);
                m3iIfPkg=...
                autosar.mm.Model.getOrAddARPackage(m3iModelShared,obj.CSInterfacePackage);
                compObj=autosar.api.Utils.m3iMappedComponent(obj.ModelName);
                for dIdx=1:length(mapping.ServerFunctions)
                    fcnName=autosar.ui.utils.getSlFunctionName(mapping.ServerFunctions(dIdx).Block);

                    if slMappingApi.isFunctionMapped(['SimulinkFunction:',fcnName])
                        continue;
                    end

                    defaultRunnableName=arblk.convertPortNameToArgName(fcnName);
                    runnableName=obj.getUniqueItemNameNameForAddingToSeq(...
                    m3iBehavior,defaultRunnableName);
                    m3iRunnable=autosar.ui.wizard.builder.Component.findOrCreateNamedItemInSequence(...
                    m3iBehavior,m3iBehavior.Runnables,runnableName,...
                    Simulink.metamodel.arplatform.behavior.Runnable.MetaClass);
                    m3iRunnable.symbol=m3iRunnable.Name;


                    if m3iRunnable.Events.isEmpty()
                        evtName=arxml.arxml_private('p_create_aridentifier',...
                        [autosar.ui.wizard.PackageString.EventPrefix,m3iRunnable.Name],...
                        maxShortNameLength);
                        opEvt=autosar.ui.wizard.builder.Component.findOrCreateNamedItemInSequence(...
                        m3iBehavior,m3iBehavior.Events,evtName,...
                        Simulink.metamodel.arplatform.behavior.OperationInvokedEvent.MetaClass);
                        opEvt.StartOnEvent=m3iRunnable;
                    end

                    if obj.IsDefaultConfig
                        m3iInstanceRef=Simulink.metamodel.arplatform.instance.OperationPortInstanceRef(m3iModel);
                        if isempty(compObj.instanceMapping)
                            compObj.instanceMapping=...
                            Simulink.metamodel.arplatform.instance.ComponentInstanceRef(m3iModel);
                        end
                        compObj.instanceMapping.instance.append(m3iInstanceRef);
                        opEvt.instanceRef=m3iInstanceRef;
                        m3iPort=...
                        autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(...
                        compObj,compObj.ServerPorts,m3iRunnable.Name,metaClassStr.sPortCls);
                        m3iInterface=m3iPort.Interface;
                        if~m3iInterface.isvalid()
                            m3iInterface=...
                            autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(...
                            m3iIfPkg,m3iIfPkg.packagedElement,m3iRunnable.Name,metaClassStr.csifCls);
                        end
                        m3iPort.Interface=m3iInterface;
                        m3iOperation=...
                        autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(...
                        m3iInterface,m3iInterface.Operations,...
                        m3iRunnable.Name,metaClassStr.opCls);
                        m3iInstanceRef.Port=m3iPort;
                        m3iInstanceRef.Operations=m3iOperation;

                        for i=1:m3iOperation.Arguments.size()
                            m3iOperation.Arguments.front.destroy();
                        end
                        autosar.ui.utils.addArguments(modelName,fcnName,m3iOperation);
                        slMappingApi.mapFunction(['SimulinkFunction:',fcnName],m3iRunnable.Name);
                    end

                end
            end

            if~isempty(mapping.DataTransfers)
                for dIdx=1:length(mapping.DataTransfers)
                    irvMapping=mapping.DataTransfers(dIdx);
                    signalName=irvMapping.SignalName;
                    if slMappingApi.isDataTransferMapped(signalName)
                        continue
                    end
                    irvData=irvMapping.MappedTo;
                    if~isempty(irvData.IrvName)
                        m3iIrvData=autosar.ui.wizard.builder.Component.findOrCreateNamedItemInSequence(...
                        m3iBehavior,m3iBehavior.IRV,irvData.IrvName,...
                        Simulink.metamodel.arplatform.behavior.IrvData.MetaClass);
                        if strcmpi(irvData.IrvAccessMode,'Implicit')
                            m3iIrvData.Kind=Simulink.metamodel.arplatform.behavior.IrvKind.Implicit;
                        else
                            m3iIrvData.Kind=Simulink.metamodel.arplatform.behavior.IrvKind.Explicit;
                        end
                    else
                        signalName=irvMapping.SignalName;
                        irvName=arxml.arxml_private('p_create_aridentifier',...
                        signalName,maxShortNameLength);
                        if~isempty(signalName)
                            m3iIrvData=autosar.ui.wizard.builder.Component.findOrCreateNamedItemInSequence(...
                            m3iBehavior,m3iBehavior.IRV,irvName,...
                            Simulink.metamodel.arplatform.behavior.IrvData.MetaClass);
                            slMappingApi.mapDataTransfer(signalName,m3iIrvData.Name,irvData.IrvAccessMode);


                            if strcmpi(irvData.IrvAccessMode,'Implicit')
                                m3iIrvData.Kind=Simulink.metamodel.arplatform.behavior.IrvKind.Implicit;
                            else
                                m3iIrvData.Kind=Simulink.metamodel.arplatform.behavior.IrvKind.Explicit;
                            end
                        end
                    end
                end
            end



            obj.createDefaultLookups(m3iBehavior,mapping.LookupTables,maxShortNameLength);

            if~isempty(mapping.RateTransition)
                for dIdx=1:length(mapping.RateTransition)
                    irvMapping=mapping.RateTransition(dIdx);
                    if slMappingApi.isDataTransferMapped(irvMapping.Block)
                        continue
                    end

                    irvData=irvMapping.MappedTo;
                    defaultIRVName=arxml.arxml_private('p_create_aridentifier',...
                    [autosar.ui.wizard.PackageString.DefaultIRVName...
                    ,num2str(dIdx)],maxShortNameLength);
                    irvName=obj.getUniqueItemNameNameForAddingToSeq(m3iBehavior,defaultIRVName);

                    m3iIrvData=autosar.ui.wizard.builder.Component.findOrCreateNamedItemInSequence(...
                    m3iBehavior,m3iBehavior.IRV,irvName,...
                    Simulink.metamodel.arplatform.behavior.IrvData.MetaClass);
                    if strcmpi(irvData.IrvAccessMode,'Implicit')
                        m3iIrvData.Kind=Simulink.metamodel.arplatform.behavior.IrvKind.Implicit;
                    else
                        m3iIrvData.Kind=Simulink.metamodel.arplatform.behavior.IrvKind.Explicit;
                    end

                    slMappingApi.mapDataTransfer(irvMapping.Block,irvName,irvData.IrvAccessMode);

                end
            end



            autosar.ui.wizard.builder.Component.deleteUnusedM3IRunnables(mapping,m3iComp);
            autosar.ui.wizard.builder.Component.deleteUnusedM3IIRVs(mapping,m3iComp);
        end

        function createDefaultLookups(~,m3iBehavior,mappings,maxShortNameLength)


            if~isempty(mappings)
                for dIdx=1:length(mappings)
                    paramData=mappings(dIdx).MappedTo;
                    if~isempty(paramData.Parameter)
                        m3iPrmData=autosar.ui.wizard.builder.Component.findOrCreateNamedItemInSequence(...
                        m3iBehavior,m3iBehavior.Parameters,paramData.Parameter,...
                        Simulink.metamodel.arplatform.interface.ParameterData.MetaClass);
                        switch paramData.ParameterAccessMode
                        case autosar.ui.configuration.PackageString.ParameterAccessMode{2}
                            m3iPrmData.Kind=Simulink.metamodel.arplatform.behavior.ParameterKind.Shared;
                        case autosar.ui.configuration.PackageString.ParameterAccessMode{3}
                            m3iPrmData.Kind=Simulink.metamodel.arplatform.behavior.ParameterKind.Pim;
                        case autosar.ui.configuration.PackageString.ParameterAccessMode{4}
                            m3iPrmData.Kind=Simulink.metamodel.arplatform.behavior.ParameterKind.Const;
                        end
                    else
                        lutName=mappings(dIdx).LookupTableName;
                        lutNameAr=arxml.arxml_private('p_create_aridentifier',...
                        lutName,maxShortNameLength);
                        if~isempty(lutName)
                            mappings(dIdx).mapLookupTable(...
                            lutName,'Auto','',lutNameAr,'');
                        end
                    end
                end
            end
        end


        function dataType=getPropDataType(~,propName)
            strProps={'ComponentPackage','ComponentName',...
            'ComponentType','InterfacePackage','CSInterfacePackage'};
            assert(any(strcmp(propName,strProps)));
            dataType='string';
        end

        function m3iPort=mapSlPort(obj,slPortBlk,modelName,mapping,slMappingApi,m3iModelShared,m3iComp,isAdaptive)

            m3iPort=[];

            assert(m3iModelShared==autosarcore.ModelUtils.getSharedElementsM3IModel(modelName),...
            'incorrect m3iModel specified for shared elements');

            metaClassStr=autosar.ui.wizard.builder.Component.getMetaClassStrings(isAdaptive);

            isBusPort=autosar.composition.Utils.isCompositePortBlock(slPortBlk);
            isInport=strcmp(get_param(slPortBlk,'BlockType'),'Inport');
            slPortName=get_param(slPortBlk,'Name');
            if isInport
                isMapped=slMappingApi.isInportMapped(slPortName);
                slPortMapping=mapping.Inports(strcmp(slPortBlk,{mapping.Inports.Block}));
            else
                isMapped=slMappingApi.isOutportMapped(slPortName);
                slPortMapping=mapping.Outports(strcmp(slPortBlk,{mapping.Outports.Block}));
            end

            if~(~isMapped||isBusPort)


                return
            end

            mappingNeedsUpdating=~isMapped||isBusPort;



            portName=obj.ComponentAdapter.getAutosarPortName(slPortBlk);
            interfaceName=obj.ComponentAdapter.getAutosarInterfaceName(slPortBlk);

            [portCls,interfaceCls,portSeq]=obj.getPortClassAndSeq(...
            m3iModelShared,...
            m3iComp,...
            portName,...
            interfaceName,...
            slPortMapping,...
            isBusPort,...
            isInport);

            m3iPort=...
            autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(...
            m3iComp,portSeq,portName,portCls);


            m3iInterface=m3iPort.Interface;
            if~m3iInterface.isvalid()


                m3iInterfaceMetaClass=feval(sprintf('%s.MetaClass',interfaceCls));
                m3iRootPackage=m3iModelShared.rootModel.RootPackage.at(1);
                m3iSeq=Simulink.metamodel.arplatform.ModelFinder.findObjectInModel(...
                m3iRootPackage,...
                interfaceName,...
                m3iInterfaceMetaClass);

                if m3iSeq.size>0
                    m3iInterface=m3iSeq.at(1);
                else


                    if~obj.CanAutoPopulateInterfaces&&obj.isDataInterfaceMetaClass(interfaceCls)
                        assert(false,'could not find interface %s in interface dictionary %s',...
                        interfaceName,obj.InterfaceDictName);
                    end


                    m3iIfPkg=autosar.mm.Model.getOrAddARPackage(m3iModelShared,obj.InterfacePackage);
                    m3iInterface=...
                    autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(...
                    m3iIfPkg,m3iIfPkg.packagedElement,interfaceName,interfaceCls);
                end

                m3iPort.Interface=m3iInterface;

                mappingNeedsUpdating=true;
            end

            if strcmp(interfaceCls,metaClassStr.msifCls)

                mappingNeedsUpdating=true;
            end

            if~mappingNeedsUpdating
                return;
            end

            dataElementName=obj.ComponentAdapter.getAutosarElementName(slPortBlk);
            if isBusPort
                if strcmp(interfaceCls,metaClassStr.msifCls)

                    if isempty(m3iInterface.ModeGroup)
                        m3iInterface.ModeGroup=Simulink.metamodel.arplatform.interface.ModeDeclarationGroupElement(m3iModelShared);
                    end

                    elementNames=autosar.simulink.bep.Utils.getElements(slPortBlk);
                    if numel(elementNames)~=1

                        blockStr=autosar.simulink.bep.Utils.getBusPortBlockTypeStr(slPortBlk);
                        [usingBus,busObjName]=autosar.simulink.bep.Utils.isBEPUsingBusObject(slPortBlk);
                        if usingBus
                            DAStudio.error('autosarstandard:validation:modeBusPortHasMultipleElementsBus',blockStr,getfullname(slPortBlk),busObjName);
                        else
                            DAStudio.error('autosarstandard:validation:modeBusPortHasMultipleElements',blockStr,getfullname(slPortBlk))
                        end
                    end

                    m3iInterface.ModeGroup.Name=dataElementName;

                    if isInport
                        dataAccessMode=autosar.ui.wizard.PackageString.DefaultDataAccessMSInport;
                        slMappingApi.mapInport(slPortName,portName,dataElementName,dataAccessMode);
                    else
                        dataAccessMode=autosar.ui.wizard.PackageString.DefaultDataAccessMSOutport;
                        slMappingApi.mapOutport(slPortName,portName,dataElementName,dataAccessMode);
                    end

                    return;

                else
                    obj.populateBEPInterface(slPortBlk,m3iInterface,metaClassStr.dataCls);
                end
            end
        end

        function mapInportsAndOutports(obj,modelName,mapping,slMappingApi,m3iModelShared,m3iComp,isAdaptive,mode,inportIsMessage,outportIsMessage)

            if nargin<9
                assert(strcmp(mode,'onlyBep'),...
                'These options should only be omitted when mapping Bus Element Ports');


                assert(~isAdaptive,'Adaptive models require message ports');





                tempOut.Inport=0;
                tempIn.Outport=0;
                [outportIsMessage{1:numel(mapping.Outports)}]=deal(tempOut);
                [inportIsMessage{1:numel(mapping.Inports)}]=deal(tempIn);
            end
            metaClassStr=autosar.ui.wizard.builder.Component.getMetaClassStrings(obj.IsAdaptive);

            assert(m3iModelShared==autosarcore.ModelUtils.getSharedElementsM3IModel(modelName),...
            'incorrect m3iModel specified for shared elements');


            if obj.IsAdaptive

                for slPortIdx=1:length(mapping.Outports)
                    curMapping=mapping.Outports(slPortIdx);
                    slPortBlk=curMapping.Block;

                    isBusPort=autosar.composition.Utils.isCompositePortBlock(slPortBlk);
                    if(~isBusPort&&strcmp(mode,'onlyBep'))
                        continue;
                    end

                    slPortName=get_param(slPortBlk,'Name');
                    if slMappingApi.isOutportMapped(slPortName)&&~isBusPort


                        continue
                    end


                    portName=obj.ComponentAdapter.getAutosarPortName(slPortBlk);
                    m3iPort=...
                    autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(...
                    m3iComp,m3iComp.ProvidedPorts,portName,metaClassStr.svcProPortCls);


                    m3iInterface=m3iPort.Interface;
                    if~m3iInterface.isvalid()
                        m3iIfPkg=autosar.mm.Model.getOrAddARPackage(m3iModelShared,obj.InterfacePackage);
                        interfaceName=obj.ComponentAdapter.getAutosarInterfaceName(slPortBlk);
                        m3iInterface=...
                        autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(...
                        m3iIfPkg,m3iIfPkg.packagedElement,interfaceName,metaClassStr.svcifCls);
                    end
                    m3iPort.Interface=m3iInterface;

                    eventName=obj.ComponentAdapter.getAutosarElementName(slPortBlk);
                    m3iData=...
                    autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(...
                    m3iInterface,m3iInterface.Events,...
                    eventName,metaClassStr.eventCls);%#ok<NASGU>

                    if isBusPort&&~isempty(curMapping.MappedTo.AllocateMemory)
                        allocateMemory=curMapping.MappedTo.AllocateMemory;
                    else
                        allocateMemory=autosar.ui.wizard.PackageString.DefaultAllocateMemory;
                    end

                    slMappingApi.mapOutport(slPortName,portName,eventName,allocateMemory);
                end


                for slInIdx=1:length(mapping.Inports)
                    slPortBlk=mapping.Inports(slInIdx).Block;

                    isBusPort=autosar.composition.Utils.isCompositePortBlock(slPortBlk);
                    if(~isBusPort&&strcmp(mode,'onlyBep'))
                        continue;
                    end

                    slPortName=get_param(slPortBlk,'Name');
                    if slMappingApi.isInportMapped(slPortName)&&~isBusPort


                        continue
                    end


                    portName=obj.ComponentAdapter.getAutosarPortName(slPortBlk);
                    m3iPort=...
                    autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(...
                    m3iComp,m3iComp.RequiredPorts,portName,metaClassStr.svcReqPortCls);


                    m3iInterface=m3iPort.Interface;
                    if~m3iInterface.isvalid()
                        m3iIfPkg=autosar.mm.Model.getOrAddARPackage(m3iModelShared,obj.InterfacePackage);
                        interfaceName=obj.ComponentAdapter.getAutosarInterfaceName(slPortBlk);
                        m3iInterface=...
                        autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(...
                        m3iIfPkg,m3iIfPkg.packagedElement,interfaceName,metaClassStr.svcifCls);
                    end
                    m3iPort.Interface=m3iInterface;

                    eventName=obj.ComponentAdapter.getAutosarElementName(slPortBlk);
                    m3iData=...
                    autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(...
                    m3iInterface,m3iInterface.Events,...
                    eventName,metaClassStr.eventCls);%#ok<NASGU>


                    portIsMessage=inportIsMessage{slInIdx};
                    if~isempty(portIsMessage)&&portIsMessage.Outport
                        dataAccessMode=autosar.ui.wizard.PackageString.DefaultQueuedDataAccessInport;
                    else
                        dataAccessMode=autosar.ui.wizard.PackageString.DefaultDataAccessInport;
                    end

                    slMappingApi.mapInport(slPortName,portName,eventName,dataAccessMode);
                end
            else

                slPorts=[mapping.Inports,mapping.Outports];
                portIsMessageArr=[inportIsMessage(:);outportIsMessage(:)];


                if obj.IsUsingInterfaceDict
                    interfaceDictAPI=Simulink.interface.dictionary.open(obj.InterfaceDictName);
                    dictInteraceNames=interfaceDictAPI.getInterfaceNames();
                    unMappedPortsWithInterfaceDict={};
                end

                for slPortIdx=1:numel(slPorts)
                    slPortBlk=slPorts(slPortIdx).Block;
                    slPortName=get_param(slPortBlk,'Name');

                    isBusPort=autosar.composition.Utils.isCompositePortBlock(slPortBlk);
                    if(~isBusPort&&strcmp(mode,'onlyBep'))
                        continue;
                    end
                    if isBusPort&&~codermapping.internal.bep.isMappableBEP(get_param(slPortBlk,'Handle'))



                        continue;
                    end

                    isInport=strcmp(get_param(slPortBlk,'BlockType'),'Inport');
                    if isInport
                        isMapped=slMappingApi.isInportMapped(slPortName);
                    else
                        isMapped=slMappingApi.isOutportMapped(slPortName);
                    end

                    if~(~isMapped||isBusPort)


                        continue;
                    end

                    if~obj.CanAutoPopulateInterfaces
                        if isBusPort
                            [isUsingBus,busName]=autosar.simulink.bep.Utils.isBEPUsingBusObject(slPortBlk);
                            if~isUsingBus||~any(strcmp(busName,dictInteraceNames))




                                unMappedPortsWithInterfaceDict{end+1}=slPortBlk;%#ok<AGROW>
                                continue;
                            end
                        else




                            unMappedPortsWithInterfaceDict{end+1}=slPortBlk;%#ok<AGROW>
                            continue;
                        end
                    end


                    dataElementName=obj.ComponentAdapter.getAutosarElementName(slPortBlk);
                    portName=obj.ComponentAdapter.getAutosarPortName(slPortBlk);

                    m3iPort=mapSlPort(obj,slPortBlk,modelName,mapping,slMappingApi,m3iModelShared,m3iComp,isAdaptive);
                    m3iInterface=m3iPort.Interface;

                    if strcmp(m3iInterface.MetaClass.qualifiedName,metaClassStr.msifCls)

                        continue;
                    end


                    if isempty(dataElementName)

                        if isInport
                            dataAccessMode=autosar.ui.wizard.PackageString.DefaultDataAccessInport;
                            slMappingApi.mapInport(slPortName,portName,'',dataAccessMode);
                        else
                            dataAccessMode=autosar.ui.wizard.PackageString.DefaultDataAccessOutport;
                            slMappingApi.mapOutport(slPortName,portName,'',dataAccessMode);
                        end
                    else

                        if obj.IsUsingInterfaceDict



                            m3iData=...
                            autosar.mm.sl2mm.ModelBuilder.findInSequenceNamedItem(...
                            m3iInterface,m3iInterface.DataElements,...
                            dataElementName,metaClassStr.dataCls);
                            assert(m3iData.isvalid(),'interface %s should have dataElement %s',...
                            m3iInterface.Name,dataElementName);
                        else
                            m3iData=...
                            autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(...
                            m3iInterface,m3iInterface.DataElements,...
                            dataElementName,metaClassStr.dataCls);
                        end




                        portIsMessage=portIsMessageArr{slPortIdx};

                        isConnectedToSignalInvalidation=...
                        autosar.ui.wizard.builder.Component.isPortBlockConnectedToSignalInvalidation(...
                        slPorts(slPortIdx).Block);
                        if~isempty(portIsMessage)&&~isInport&&portIsMessage.Inport
                            dataAccessMode=autosar.ui.wizard.PackageString.DefaultQueuedDataAccessOutport;
                        elseif~isempty(portIsMessage)&&isInport&&portIsMessage.Outport
                            dataAccessMode=autosar.ui.wizard.PackageString.DefaultQueuedDataAccessInport;
                        elseif isConnectedToSignalInvalidation
                            dataAccessMode=autosar.ui.wizard.PackageString.DefaultSignalInvalidationDataAccess;
                        else
                            if isBusPort&&~isempty(slPorts(slPortIdx).MappedTo.DataAccessMode)
                                dataAccessMode=slPorts(slPortIdx).MappedTo.DataAccessMode;
                            else
                                if isInport
                                    dataAccessMode=autosar.ui.wizard.PackageString.DefaultDataAccessInport;
                                else
                                    dataAccessMode=autosar.ui.wizard.PackageString.DefaultDataAccessOutport;
                                end
                            end
                        end

                        if any(strcmp(dataAccessMode,...
                            {'QueuedExplicitReceive','QueuedExplicitSend'}))


                            m3iData.SwCalibrationAccess=...
                            Simulink.metamodel.foundation.SwCalibrationAccessKind.NotAccessible;
                        end


                        if isInport
                            slMappingApi.mapInport(slPortName,portName,dataElementName,dataAccessMode);
                        else
                            slMappingApi.mapOutport(slPortName,portName,dataElementName,dataAccessMode);
                        end

                        autosar.mm.sl2mm.ComSpecBuilder.addOrUpdateM3IComSpec(portName,dataElementName,dataAccessMode,modelName);
                        if isBusPort&&...
                            strcmp(dataAccessMode,'QueuedExplicitReceive')




                            queueCapacity=get_param(slPortBlk,'MessageQueueCapacity');
                            if~any(strcmp(queueCapacity,{'auto','-1'}))

                                m3iComSpec=autosar.ui.comspec.ComSpecUtils.getM3IComSpec(...
                                m3iComp,portName,dataElementName,...
                                isInport);
                                autosar.ui.comspec.ComSpecPropertyHandler.setComSpecPropertyValue(...
                                m3iComSpec,'QueueLength',queueCapacity);
                            end
                        end
                    end
                end


                if obj.modelContainsRootBusPorts(mapping)
                    autosar.ui.wizard.builder.Component.destroyUnusedSRPorts(...
                    mapping,...
                    m3iComp,...
                    metaClassStr.rPortCls,...
                    metaClassStr.pPortCls);
                end



                if obj.IsUsingInterfaceDict&&~isempty(unMappedPortsWithInterfaceDict)
                    DAStudio.warning('autosarstandard:dictionary:InterfaceDictCannotAutoMapPorts',...
                    autosar.api.Utils.cell2str(unMappedPortsWithInterfaceDict),...
                    obj.InterfaceDictName);
                end

            end
        end

    end

    methods(Access=private)
        function[receiverPorts,senderPorts]=findPortsForAdaptiveModel(obj)


            ports=obj.ServicePorts;
            rPortIndexes=strcmp([ports.PortType],autosar.ui.wizard.PackageString.PortTypes(14));
            sPortIndexes=strcmp([ports.PortType],autosar.ui.wizard.PackageString.PortTypes(13));
            receiverPorts=ports(rPortIndexes);
            senderPorts=ports(sPortIndexes);
        end

        function uniqueName=getUniqueItemNameNameForAddingToSeq(obj,m3iSeq,defaultName)


            qualifiedName=autosar.api.UnnamedElement.getQualifiedName(m3iSeq);
            uniqueName=autosar.api.Utils.createUniqueNameInSeq(obj.ModelName,defaultName,qualifiedName);
        end

        function createDefaultExternalTriggerEventForRunnable(obj,m3iRunnable,m3iModelShared,evtName)



            metaClassStr=autosar.ui.wizard.builder.Component.getMetaClassStrings(obj.IsAdaptive);
            m3iBehavior=m3iRunnable.containerM3I;
            m3iComp=m3iBehavior.containerM3I;
            m3iModel=m3iComp.rootModel;
            maxShortNameLength=autosar.ui.utils.getAutosarMaxShortNameLength(obj.ModelName);


            trigRportName=arxml.arxml_private('p_create_aridentifier',...
            [autosar.ui.wizard.PackageString.TriggersNewName,m3iRunnable.Name],...
            maxShortNameLength);
            m3iTrigRecvPort=Simulink.metamodel.arplatform.ModelFinder.findOrCreateNamedItemInSequence(...
            m3iComp,m3iComp.TriggerReceiverPorts,trigRportName,metaClassStr.trigrPortCls);


            m3iInterface=m3iTrigRecvPort.Interface;
            if~m3iInterface.isvalid()
                m3iIfPkg=autosar.mm.Model.getOrAddARPackage(m3iModelShared,obj.InterfacePackage);
                interfaceName=trigRportName;
                m3iInterface=...
                autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(...
                m3iIfPkg,m3iIfPkg.packagedElement,interfaceName,metaClassStr.trigifCls);
                m3iTrigRecvPort.Interface=m3iInterface;
            end

            triggerElmName=trigRportName;
            m3iTrigger=...
            autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(...
            m3iInterface,m3iInterface.Triggers,...
            triggerElmName,metaClassStr.trigCls);


            m3iExtTrigEvt=autosar.ui.wizard.builder.Component.findOrCreateNamedItemInSequence(...
            m3iBehavior,m3iBehavior.Events,evtName,...
            Simulink.metamodel.arplatform.behavior.ExternalTriggerOccurredEvent.MetaClass);
            m3iExtTrigEvt.StartOnEvent=m3iRunnable;

            m3iInstanceRef=Simulink.metamodel.arplatform.instance.TriggerInstanceRef(m3iModel);
            if isempty(m3iComp.instanceMapping)
                m3iComp.instanceMapping=...
                Simulink.metamodel.arplatform.instance.ComponentInstanceRef(m3iModel);
            end

            if~isempty(m3iExtTrigEvt.instanceRef)
                for ii=m3iComp.instanceMapping.instance.size():-1:1
                    if m3iComp.instanceMapping.instance.at(ii)==m3iExtTrigEvt.instanceRef
                        m3iComp.instanceMapping.instance.at(ii).destroy();
                        break;
                    end
                end
            end
            m3iComp.instanceMapping.instance.append(m3iInstanceRef);
            m3iExtTrigEvt.instanceRef=m3iInstanceRef;
            m3iInstanceRef.Port=m3iTrigRecvPort;
            m3iInstanceRef.Trigger=m3iTrigger;
        end

        function createDefaultPortParameterMapping(obj,modelName,mapping,slMappingApi,m3iModel,m3iComp)








            parameters=mapping.ModelScopedParameters;
            maxShortNameLength=autosar.ui.utils.getAutosarMaxShortNameLength(modelName);
            metaClassStr=autosar.ui.wizard.builder.Component.getMetaClassStrings(obj.IsAdaptive);

            for paramIdx=1:length(parameters)
                curParam=parameters(paramIdx);
                if~strcmp(curParam.MappedTo.ArDataRole,'PortParameter')

                    continue;
                end
                paramName=curParam.Parameter;
                mappedParamPort=slMappingApi.getParameter(paramName,'Port');
                mappedParamElement=slMappingApi.getParameter(paramName,'DataElement');
                if isempty(mappedParamPort)

                    portName=arxml.arxml_private('p_create_aridentifier',...
                    paramName,maxShortNameLength);
                    m3iPort=...
                    autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(...
                    m3iComp,m3iComp.ParameterReceiverPorts,portName,metaClassStr.paramRecPortCls);
                elseif isempty(mappedParamElement)



                    portName=mappedParamPort;
                    m3iPort=...
                    autosar.mm.sl2mm.ModelBuilder.findInSequenceNamedItem(...
                    m3iComp,m3iComp.ParameterReceiverPorts,portName,metaClassStr.paramRecPortCls);
                    assert(length(m3iPort)==1,'Expected to find exactly 1 parameter port');
                else

                    continue
                end



                m3iInterface=m3iPort.Interface;
                if~m3iInterface.isvalid()
                    m3iIfPkg=autosar.mm.Model.getOrAddARPackage(m3iModel,obj.InterfacePackage);
                    interfaceName=portName;
                    m3iInterface=...
                    autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(...
                    m3iIfPkg,m3iIfPkg.packagedElement,interfaceName,metaClassStr.paramifCls);
                end
                m3iPort.Interface=m3iInterface;

                paramElementName=arxml.arxml_private('p_create_aridentifier',...
                paramName,maxShortNameLength);
                m3iData=...
                autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(...
                m3iInterface,m3iInterface.DataElements,...
                paramElementName,metaClassStr.paramDataCls);%#ok<NASGU>

                slMappingApi.mapParameter(paramName,'PortParameter',...
                'Port',portName,'DataElement',paramElementName);
            end
        end

        function[portCls,interfaceCls,portSeq]=getPortClassAndSeq(obj,m3iModel,m3iComp,portName,interfaceName,slPort,isBusElementPort,isInport)

            isAdaptive=false;
            metaClassStr=obj.getMetaClassStrings(isAdaptive);

            if isBusElementPort
                [portCls,interfaceCls]=obj.getCompositePortClass(m3iModel,m3iComp,portName,interfaceName,slPort,isInport);
            else
                interfaceCls=metaClassStr.srifCls;
                if isInport
                    portCls=metaClassStr.rPortCls;
                else
                    portCls=metaClassStr.pPortCls;
                end
            end

            switch portCls
            case metaClassStr.pPortCls
                portSeq=m3iComp.SenderPorts;
            case metaClassStr.nvsPortCls
                portSeq=m3iComp.NvSenderPorts;
            case metaClassStr.msPortCls
                portSeq=m3iComp.ModeSenderPorts;
            case metaClassStr.rPortCls
                portSeq=m3iComp.ReceiverPorts;
            case metaClassStr.nvrPortCls
                portSeq=m3iComp.NvReceiverPorts;
            case metaClassStr.mrPortCls
                portSeq=m3iComp.ModeReceiverPorts;
            case metaClassStr.nvsrPortCls
                portSeq=m3iComp.NvSenderReceiverPorts;
            case metaClassStr.prPortCls
                portSeq=m3iComp.SenderReceiverPorts;
            otherwise
                assert(false,'Unexpected port type')
            end
        end

        function[portCls,interfaceCls]=getCompositePortClass(obj,m3iModel,m3iComp,portName,interfaceName,slPort,isInport)

            isAdaptive=false;
            metaClassStr=obj.getMetaClassStrings(isAdaptive);


            m3iNvSenderReceiverPort=autosar.mm.sl2mm.ModelBuilder.findInSequenceNamedItem(...
            m3iComp,m3iComp.NvSenderReceiverPorts,portName,metaClassStr.nvsrPortCls);
            if~isempty(m3iNvSenderReceiverPort)
                portCls=metaClassStr.nvsrPortCls;
                interfaceCls=metaClassStr.nvdifCls;
                return;
            end


            m3iSenderReceiverPort=autosar.mm.sl2mm.ModelBuilder.findInSequenceNamedItem(...
            m3iComp,m3iComp.SenderReceiverPorts,portName,metaClassStr.prPortCls);
            if~isempty(m3iSenderReceiverPort)
                portCls=metaClassStr.prPortCls;
                interfaceCls=metaClassStr.srifCls;
                return;
            end

            interfaceCls=metaClassStr.srifCls;
            if isInport
                portCls=metaClassStr.rPortCls;

                m3iNvReceiverPort=autosar.mm.sl2mm.ModelBuilder.findInSequenceNamedItem(...
                m3iComp,m3iComp.NvReceiverPorts,portName,metaClassStr.nvrPortCls);
                if~isempty(m3iNvReceiverPort)
                    portCls=metaClassStr.nvrPortCls;
                    interfaceCls=metaClassStr.nvdifCls;
                    return;
                end

                m3iModeReceiverPort=autosar.mm.sl2mm.ModelBuilder.findInSequenceNamedItem(...
                m3iComp,m3iComp.ModeReceiverPorts,portName,metaClassStr.mrPortCls);
                if~isempty(m3iModeReceiverPort)
                    portCls=metaClassStr.mrPortCls;
                    interfaceCls=metaClassStr.msifCls;
                    return;
                end

                m3iReceiverPort=autosar.mm.sl2mm.ModelBuilder.findInSequenceNamedItem(...
                m3iComp,m3iComp.ReceiverPorts,portName,metaClassStr.rPortCls);
                if isempty(m3iReceiverPort)
                    if strcmp(slPort.MappedTo.DataAccessMode,'ModeReceive')
                        portCls=metaClassStr.mrPortCls;
                        interfaceCls=metaClassStr.msifCls;
                        return;
                    end
                end
            else
                portCls=metaClassStr.pPortCls;

                m3iNvSenderPort=autosar.mm.sl2mm.ModelBuilder.findInSequenceNamedItem(...
                m3iComp,m3iComp.NvSenderPorts,portName,metaClassStr.nvsPortCls);
                if~isempty(m3iNvSenderPort)
                    portCls=metaClassStr.nvsPortCls;
                    interfaceCls=metaClassStr.nvdifCls;
                    return;
                end

                m3iModeSenderPort=autosar.mm.sl2mm.ModelBuilder.findInSequenceNamedItem(...
                m3iComp,m3iComp.ModeSenderPorts,portName,metaClassStr.msPortCls);
                if~isempty(m3iModeSenderPort)
                    portCls=metaClassStr.msPortCls;
                    interfaceCls=metaClassStr.msifCls;
                    return;
                end

                m3iSenderPort=autosar.mm.sl2mm.ModelBuilder.findInSequenceNamedItem(...
                m3iComp,m3iComp.SenderPorts,portName,metaClassStr.pPortCls);
                if isempty(m3iSenderPort)
                    if strcmp(slPort.MappedTo.DataAccessMode,'ModeSend')
                        portCls=metaClassStr.msPortCls;
                        interfaceCls=metaClassStr.msifCls;
                        return;
                    end
                end
            end

            m3iDataInterfaceSeq=autosar.mm.Model.findObjectByMetaClass(m3iModel,Simulink.metamodel.arplatform.interface.DataInterface.MetaClass,true,true);

            m3iDataInterface=autosar.mm.sl2mm.ModelBuilder.findInSequenceNamedItem(...
            m3iModel,m3iDataInterfaceSeq,interfaceName,metaClassStr.srifCls);
            if~isempty(m3iDataInterface)

                if isInport
                    portCls=metaClassStr.rPortCls;
                else
                    portCls=metaClassStr.pPortCls;
                end
                interfaceCls=metaClassStr.srifCls;
                return;
            end

            m3iDataInterface=autosar.mm.sl2mm.ModelBuilder.findInSequenceNamedItem(...
            m3iModel,m3iDataInterfaceSeq,interfaceName,metaClassStr.nvdifCls);
            if~isempty(m3iDataInterface)

                if isInport
                    portCls=metaClassStr.nvrPortCls;
                else
                    portCls=metaClassStr.nvsPortCls;
                end
                interfaceCls=metaClassStr.nvdifCls;
                return;
            end

            m3iModeSwitchInterfaceSeq=autosar.mm.Model.findObjectByMetaClass(m3iModel,Simulink.metamodel.arplatform.interface.ModeSwitchInterface.MetaClass,true,true);
            m3iModeSwitchInterface=autosar.mm.sl2mm.ModelBuilder.findInSequenceNamedItem(...
            m3iModel,m3iModeSwitchInterfaceSeq,interfaceName,metaClassStr.msifCls);
            if~isempty(m3iModeSwitchInterface)

                if isInport
                    portCls=metaClassStr.mrPortCls;
                else
                    portCls=metaClassStr.msPortCls;
                end
                interfaceCls=metaClassStr.msifCls;
                return;
            end
        end

        function mapFunctionCallers(obj,modelName,mapping,slMappingApi,m3iModel,m3iComp)


            metaClassStr=autosar.ui.wizard.builder.Component.getMetaClassStrings(obj.IsAdaptive);
            maxShortNameLength=autosar.ui.utils.getAutosarMaxShortNameLength(modelName);

            if obj.IsAdaptive


                return;
            else
                for clIndx=1:length(mapping.FunctionCallers)
                    fcnName=autosar.ui.utils.getSlFunctionName(...
                    mapping.FunctionCallers(clIndx).Block);
                    if slMappingApi.isFunctionCallerMapped(fcnName)
                        continue
                    end
                    portName=mapping.FunctionCallers(clIndx).MappedTo.ClientPort;
                    if isempty(portName)
                        portName=[fcnName,autosar.ui.wizard.PackageString.FcnCallSuffix];
                        portName=arxml.arxml_private('p_create_aridentifier',...
                        portName,maxShortNameLength);
                    end


                    m3iPort=...
                    autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(...
                    m3iComp,m3iComp.ClientPorts,portName,metaClassStr.cPortCls);





                    interfaceName=fcnName;
                    m3iCSIfPkg=autosar.mm.Model.getOrAddARPackage(m3iModel,obj.CSInterfacePackage);
                    m3iInterface=...
                    autosar.mm.sl2mm.ModelBuilder.findInSequenceNamedItem(...
                    m3iCSIfPkg,m3iCSIfPkg.packagedElement,interfaceName,metaClassStr.csifCls);
                    if~m3iInterface.isvalid()
                        m3iInterface=...
                        autosar.mm.sl2mm.ModelBuilder.createInSequenceNamedItem(...
                        m3iCSIfPkg,m3iCSIfPkg.packagedElement,interfaceName,metaClassStr.csifCls);
                    end
                    m3iPort.Interface=m3iInterface;
                    opName=interfaceName;
                    m3iOp=...
                    autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(...
                    m3iInterface,m3iInterface.Operations,...
                    opName,metaClassStr.opCls);
                    if obj.IsDefaultConfig

                        autosar.ui.utils.addArguments(modelName,opName,m3iOp);
                    end
                    slMappingApi.mapFunctionCaller(fcnName,portName,m3iOp.Name)
                end
            end
        end

        function populateBEPInterface(obj,slPortBlk,m3iInterface,dataCls)





            assert(strcmp(get_param(slPortBlk,'IsBusElementPort'),'on'));




            if~obj.CanAutoPopulateInterfaces
                return;
            end




            [isUsingBus,busName]=autosar.simulink.bep.Utils.isBEPUsingBusObject(slPortBlk);
            if isUsingBus
                [exists,busObj]=autosar.utils.Workspace.objectExistsInModelScope(obj.ModelName,busName);
                assert(exists,sprintf('Simulink.Bus object referenced by %s cannot be found',getfullname(slPortBlk)));
                for busElementIdx=1:numel(busObj.Elements)

                    autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(...
                    m3iInterface,m3iInterface.DataElements,...
                    busObj.Elements(busElementIdx).Name,dataCls);
                end
            else
                elementNames=autosar.simulink.bep.Utils.getElements(slPortBlk);
                for busElementIdx=1:numel(elementNames)

                    autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(...
                    m3iInterface,m3iInterface.DataElements,...
                    elementNames{busElementIdx},dataCls);
                end
            end
        end
    end

    methods(Static,Access=public)


        function deleteUnusedM3IRunnables(mapping,m3iComp)
            unMatchedRunSet=autosar.mm.util.Set();
            m3iBehavior=m3iComp.Behavior;
            for i=1:m3iBehavior.Runnables.size()
                unMatchedRunSet.set(m3iBehavior.Runnables.at(i).Name);
            end

            for i=1:length(mapping.InitializeFunctions)
                unMatchedRunSet.remove(mapping.InitializeFunctions(i).MappedTo.Runnable);
            end
            for i=1:length(mapping.ResetFunctions)
                unMatchedRunSet.remove(mapping.ResetFunctions(i).MappedTo.Runnable);
            end
            for i=1:length(mapping.TerminateFunctions)
                unMatchedRunSet.remove(mapping.TerminateFunctions(i).MappedTo.Runnable);
            end
            for i=1:length(mapping.ServerFunctions)
                unMatchedRunSet.remove(mapping.ServerFunctions(i).MappedTo.Runnable);
            end
            for i=1:length(mapping.FcnCallInports)
                unMatchedRunSet.remove(mapping.FcnCallInports(i).MappedTo.Runnable);
            end
            for i=1:length(mapping.StepFunctions)
                unMatchedRunSet.remove(mapping.StepFunctions(i).MappedTo.Runnable);
            end

            unMatchedRunnables=unMatchedRunSet.getKeys();
            for runIdx=1:length(unMatchedRunnables)
                m3iRun=autosar.mm.Model.findRunnableByName(unMatchedRunnables{runIdx},m3iComp);
                m3iEvents=m3iRun.Events;
                for evIdx=1:m3iEvents.size()
                    m3iEvents.front.destroy();
                end
                m3iRun.destroy();
            end
        end



        function deleteUnusedM3IIRVs(mapping,m3iComp)
            unMatchedIrvSet=autosar.mm.util.Set();
            m3iBehavior=m3iComp.Behavior;
            for i=1:m3iBehavior.IRV.size()
                unMatchedIrvSet.set(m3iBehavior.IRV.at(i).Name);
            end

            for i=1:length(mapping.DataTransfers)
                unMatchedIrvSet.remove(mapping.DataTransfers(i).MappedTo.IrvName);
            end

            for i=1:length(mapping.RateTransition)
                unMatchedIrvSet.remove(mapping.RateTransition(i).MappedTo.IrvName);
            end

            unMatchedIrvss=unMatchedIrvSet.getKeys();
            for i=1:length(unMatchedIrvss)
                m3iIrv=autosar.mm.Model.findObjectByNameAndMetaClass(m3iBehavior,unMatchedIrvss{i},...
                Simulink.metamodel.arplatform.behavior.IrvData.MetaClass);
                m3iIrv.at(1).destroy();
            end
        end
    end

    methods(Static,Access=private)
        function metaClassStr=getMetaClassStrings(isAdaptive)

            metaPkgName='Simulink.metamodel.arplatform';
            if isAdaptive
                compMetaClassExt='AdaptiveApplication';
            else
                compMetaClassExt='AtomicComponent';
            end
            metaClassStr.compMetaClass=[metaPkgName,'.component.',compMetaClassExt];
            metaClassStr.srifCls=[metaPkgName,'.interface.SenderReceiverInterface'];
            metaClassStr.nvsrifCls=[metaPkgName,'.interface.NvSenderReceiverInterface'];
            metaClassStr.nvdifCls=[metaPkgName,'.interface.NvDataInterface'];
            metaClassStr.msifCls=[metaPkgName,'.interface.ModeSwitchInterface'];
            metaClassStr.csifCls=[metaPkgName,'.interface.ClientServerInterface'];
            metaClassStr.trigifCls=[metaPkgName,'.interface.TriggerInterface'];
            metaClassStr.svcifCls=[metaPkgName,'.interface.ServiceInterface'];
            metaClassStr.pkvifCls=[metaPkgName,'.interface.PersistencyKeyValueInterface'];
            metaClassStr.paramifCls=[metaPkgName,'.interface.ParameterInterface'];
            metaClassStr.rPortCls=[metaPkgName,'.port.DataReceiverPort'];
            metaClassStr.pPortCls=[metaPkgName,'.port.DataSenderPort'];
            metaClassStr.prPortCls=[metaPkgName,'.port.DataSenderReceiverPort'];
            metaClassStr.nvsPortCls=[metaPkgName,'.port.NvDataSenderPort'];
            metaClassStr.nvrPortCls=[metaPkgName,'.port.NvDataReceiverPort'];
            metaClassStr.nvsrPortCls=[metaPkgName,'.port.NvDataSenderReceiverPort'];
            metaClassStr.msPortCls=[metaPkgName,'.port.ModeSenderPort'];
            metaClassStr.mrPortCls=[metaPkgName,'.port.ModeReceiverPort'];
            metaClassStr.sPortCls=[metaPkgName,'.port.ServerPort'];
            metaClassStr.cPortCls=[metaPkgName,'.port.ClientPort'];
            metaClassStr.trigrPortCls=[metaPkgName,'.port.TriggerReceiverPort'];
            metaClassStr.svcReqPortCls=[metaPkgName,'.port.ServiceRequiredPort'];
            metaClassStr.svcProPortCls=[metaPkgName,'.port.ServiceProvidedPort'];
            metaClassStr.pstReqPortCls=[metaPkgName,'.port.PersistencyRequiredPort'];
            metaClassStr.pstProPortCls=[metaPkgName,'.port.PersistencyProvidedPort'];
            metaClassStr.pstProReqPortCls=[metaPkgName,'.port.PersistencyProvidedRequiredPort'];
            metaClassStr.paramRecPortCls=[metaPkgName,'.port.ParameterReceiverPort'];
            metaClassStr.dataCls=[metaPkgName,'.interface.FlowData'];
            metaClassStr.eventCls=[metaPkgName,'.interface.FlowData'];
            metaClassStr.methodCls=[metaPkgName,'.interface.Operation'];
            metaClassStr.opCls=[metaPkgName,'.interface.Operation'];
            metaClassStr.trigCls=[metaPkgName,'.interface.Trigger'];
            metaClassStr.paramDataCls=[metaPkgName,'.interface.ParameterData'];
            metaClassStr.perDataCls=[metaPkgName,'.interface.PersistencyData'];
        end

        function m3iItem=findOrCreateNamedItemInSequence(m3iParent,m3iSeq,elmName,metaClass)
            caseInsensitive=true;
            m3iElms=autosar.mm.Model.findObjectByName(m3iParent,elmName,caseInsensitive);
            if m3iElms.isEmpty()

                m3iItem=Simulink.metamodel.arplatform.ModelFinder.findOrCreateNamedItemInSequence(...
                m3iParent,m3iSeq,elmName,...
                metaClass.qualifiedName);
                return;
            elseif(double(m3iElms.size())==1)

                if(m3iElms.at(1).MetaClass==metaClass)
                    m3iItem=m3iElms.at(1);
                    return;
                else



                    assert(false,'Cannot add object %s to the meta-model as another object with the same name exists.',elmName);
                end
            else

                assert(false,'Cannot add object %s to the meta-model as another object with the same name exists.',elmName);
            end
        end

        function mapCallersWithSameNameToExistingCallers(functionCallersMap)
            for dtMapIdx=1:length(functionCallersMap)
                blkMap=functionCallersMap(dtMapIdx);


                fcnCall=get_param(blkMap.Block,'FunctionPrototype');
                if isa(blkMap.MappedTo,'Simulink.AutosarTarget.PortOperation')
                    portPropName='ClientPort';
                    operationPropName='Operation';
                else
                    portPropName='Port';
                    operationPropName='Method';
                end
                if isempty(blkMap.MappedTo.(portPropName))&&...
                    isempty(blkMap.MappedTo.(operationPropName))
                    for ii=1:length(functionCallersMap)
                        candidateBlkMap=functionCallersMap(ii);
                        if ii~=dtMapIdx&&...
                            strcmp(fcnCall,get_param(candidateBlkMap.Block,'FunctionPrototype'))&&...
                            ~isempty(candidateBlkMap.MappedTo.(portPropName))&&...
                            ~isempty(candidateBlkMap.MappedTo.(operationPropName))
                            blkMap.mapPortOperation(...
                            functionCallersMap(ii).MappedTo.(portPropName),...
                            functionCallersMap(ii).MappedTo.(operationPropName));
                            break;
                        end
                    end
                end
            end
        end

        function m3iOperation=findOperationForAdaptiveFcnCallerOrServerFcn(m3iComp,fcnName,portType)



            m3iOperation=[];
            switch portType
            case 'Required'
                m3iPorts=m3iComp.RequiredPorts;
            case 'Provided'
                m3iPorts=m3iComp.ProvidedPorts;
            otherwise
                assert(false,'Unexpected port type');
            end
            for ii=1:m3iPorts.size()
                m3iInterface=m3iPorts.at(ii).Interface;
                if m3iInterface.Methods.size==1
                    if strcmp(m3iInterface.Methods.at(1).Name,fcnName)
                        m3iOperation=m3iInterface.Methods.at(1);
                        return;
                    end
                end
            end
        end

        function destroyUnusedSRPorts(mapping,m3iComp,rPortCls,pPortCls)
            portMappings={mapping.Inports.MappedTo,mapping.Outports.MappedTo};
            usedPorts=unique(cellfun(@(portElement)portElement.Port,portMappings,'UniformOutput',false));


            receiverPorts=m3iComp.ReceiverPorts;
            rPortsToRemove={};
            for ii=1:receiverPorts.size()
                if~any(strcmp(receiverPorts.at(ii).Name,usedPorts))
                    rPortsToRemove=[rPortsToRemove,receiverPorts.at(ii).Name];%#ok<AGROW>
                end
            end
            for elemIdx=1:numel(rPortsToRemove)
                port=autosar.mm.sl2mm.ModelBuilder.findInSequenceNamedItem(...
                m3iComp,m3iComp.ReceiverPorts,...
                rPortsToRemove{elemIdx},rPortCls);
                port.destroy();
            end


            senderPorts=m3iComp.SenderPorts;
            pPortsToRemove={};
            for ii=1:senderPorts.size()
                if~any(strcmp(senderPorts.at(ii).Name,usedPorts))
                    pPortsToRemove=[pPortsToRemove,senderPorts.at(ii).Name];%#ok<AGROW>
                end
            end
            for elemIdx=1:numel(pPortsToRemove)
                port=autosar.mm.sl2mm.ModelBuilder.findInSequenceNamedItem(...
                m3iComp,m3iComp.SenderPorts,...
                pPortsToRemove{elemIdx},pPortCls);
                port.destroy();
            end
        end

        function ret=modelContainsRootBusPorts(mapping)
            ret=false;
            slPorts=[mapping.Inports,mapping.Outports];
            for ii=1:numel(slPorts)
                if autosar.composition.Utils.isCompositePortBlock(slPorts(ii).Block)
                    ret=true;
                    return;
                end
            end
        end

        function isConnected=isPortBlockConnectedToSignalInvalidation(portBlock)

            isConnected=false;
            if strcmp(get_param(portBlock,'BlockType'),'Inport')

                return;
            end

            portData=get_param(portBlock,'PortConnectivity');
            connectedBlkH=portData.SrcBlock;
            if connectedBlkH==-1

                return;
            end
            isConnected=strcmp(get_param(connectedBlkH,'BlockType'),'SignalInvalidation');
        end

        function isDataIntf=isDataInterfaceMetaClass(interfaceCls)
            isDataIntf=any(strcmp(interfaceCls,{...
            'Simulink.metamodel.arplatform.interface.SenderReceiverInterface',...
            'Simulink.metamodel.arplatform.interface.NvDataInterface',...
            'Simulink.metamodel.arplatform.interface.ModeSwitchInterface'}));
        end
    end

    methods(Static,Access=public)
        function[outportIsMessage,inportIsMessage]=getForceCompiledData(modelName,mapping,mode)
            cleanupObj=[];
            if(strcmp(get_param(modelName,'SimulationStatus'),'stopped'))
                try
                    cleanupObj=autosar.validation.CompiledModelUtils.forceCompiledModel(modelName);
                catch ME
                    if strcmp(mode,'cmdline')
                        cleanupObj=autosar.mm.util.MessageReporter.suppressWarningTrace();
                        MSLDiagnostic(ME).reportAsWarning;
                    else
                        errHandle=[];
                        if~isempty(ME.handles)
                            errHandle=ME.handles{1};
                        end
                        newException=MSLException(errHandle,...
                        ME.identifier,ME.message);
                        for idx=1:length(ME.cause)
                            newException=newException.addCause(MSLException(...
                            ME.cause{idx}.handles{1},...
                            ME.cause{idx}.identifier,ME.cause{idx}.message));
                        end
                        autosar.ui.utils.parseException(...
                        newException,...
                        autosar.ui.configuration.PackageString.MapRootName,...
                        autosar.ui.configuration.PackageString.MappingLink,...
                        [],[],[],[],[],modelName,'Warning');
                    end
                end
            end
            if~Simulink.CodeMapping.isMappedToAutosarSubComponent(modelName)
                outportIsMessage=get_param({mapping.Outports.Block},'CompiledPortIsMessage');
                inportIsMessage=get_param({mapping.Inports.Block},'CompiledPortIsMessage');

                autosar.bsw.BasicSoftwareCaller.syncModel(modelName);
            end

            if(~strcmp(get_param(modelName,'SimulationStatus'),'stopped'))
                delete(cleanupObj);
            end
        end
    end
end




