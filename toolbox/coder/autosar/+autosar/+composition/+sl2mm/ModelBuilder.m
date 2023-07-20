classdef ModelBuilder<handle





    properties(SetAccess=immutable,GetAccess=private)
        ModelName;
        CompositionQName;
        ExportServicePorts;
        ValidateCompositionModel;
    end

    properties(Access=private)
        M3IModel;
        M3IComposition;

        ComponentPrototypes;
        AssemblyConnectors;
        DelegationConnectors;



        UnmatchedComponentPrototypesMap;
        UnmatchedPortsMap;
        UnmatchedAssemblyConnectorsMap;
        UnmatchedDelegationConnectorsMap;
    end


    properties(Dependent)
        CompositionPackage;
        CompositionName;
        MaxShortNameLength;
    end

    properties(Constant,Access=private)

        ComponentMetaClass='Simulink.metamodel.arplatform.component.AtomicComponent';
        CompositionMetaClass='Simulink.metamodel.arplatform.composition.CompositionComponent';
        CompPrototypeMetaClass='Simulink.metamodel.arplatform.composition.ComponentPrototype';
        AssemblyMetaClass='Simulink.metamodel.arplatform.composition.AssemblyConnector';
        AssemblyProviderMetaClass='Simulink.metamodel.arplatform.instance.CompositionPPortInstanceRef';
        AssemblyRequesterMetaClass='Simulink.metamodel.arplatform.instance.CompositionRPortInstanceRef';
        DelegationMetaClass='Simulink.metamodel.arplatform.composition.DelegationConnector';
        DelegationInnerRPortMetaClass='Simulink.metamodel.arplatform.instance.CompositionRPortInstanceRef';
        DelegationInnerPPortMetaClass='Simulink.metamodel.arplatform.instance.CompositionPPortInstanceRef';
        RPortMetaClass='Simulink.metamodel.arplatform.port.DataReceiverPort';
        PPortMetaClass='Simulink.metamodel.arplatform.port.DataSenderPort';
    end


    methods
        function compositionPackage=get.CompositionPackage(this)
            compositionPackage=autosar.utils.splitQualifiedName(this.CompositionQName);
        end

        function compositionName=get.CompositionName(this)
            [~,compositionName]=autosar.utils.splitQualifiedName(this.CompositionQName);
        end

        function maxShortNameLength=get.MaxShortNameLength(this)
            maxShortNameLength=get_param(this.ModelName,'AutosarMaxShortNameLength');
        end
    end

    methods


        function this=ModelBuilder(modelName,compositionQName,...
            exportServicePorts,validateCompositionModel)
            this.ModelName=modelName;
            this.CompositionQName=compositionQName;
            this.ExportServicePorts=exportServicePorts;
            this.ValidateCompositionModel=validateCompositionModel;

            this.UnmatchedComponentPrototypesMap=containers.Map();
            this.UnmatchedPortsMap=containers.Map();
            this.UnmatchedAssemblyConnectorsMap=containers.Map();
            this.UnmatchedDelegationConnectorsMap=containers.Map();

            this.markAsUnmatched();
        end


        function build(this)


            if this.ValidateCompositionModel
                this.validateCompositionModel();
            end

            if autosar.api.Utils.isMapped(this.ModelName)
                autosar.ui.utils.registerListenerCB(this.M3IModel);
            end



            if~autosar.api.Utils.isMappedToComposition(this.ModelName)
                autosar.composition.sl2mm.ModelBuilder.createEmptyCompositionMapping(this.ModelName);
            end
            this.M3IModel=autosar.api.Utils.m3iModel(this.ModelName);


            this.collectComponentPrototypesInfo();
            this.collectConnectorsInfo();


            this.buildMetaModel();


            this.populateMapping();
        end
    end

    methods(Access=private)

        function markAsUnmatched(this)
            if autosar.api.Utils.isMappedToComposition(this.ModelName)
                m3iComposition=autosar.api.Utils.m3iMappedComponent(this.ModelName);
                m3iComponentPrototypes=m3iComposition.Components;
                for k=1:m3iComponentPrototypes.size()
                    this.UnmatchedComponentPrototypesMap(m3iComponentPrototypes.at(k).Name)=true;
                end

                m3iAssemblyConnectors=m3i.filter(@(x)...
                isa(x,'Simulink.metamodel.arplatform.composition.AssemblyConnector'),...
                m3iComposition.Connectors);
                for k=1:length(m3iAssemblyConnectors)
                    this.UnmatchedAssemblyConnectorsMap(m3iAssemblyConnectors{k}.Name)=true;
                end


                m3iDelegationConnectors=m3i.filter(@(x)...
                isa(x,'Simulink.metamodel.arplatform.composition.DelegationConnector'),...
                m3iComposition.Connectors);
                for k=1:length(m3iDelegationConnectors)
                    this.UnmatchedDelegationConnectorsMap(m3iDelegationConnectors{k}.Name)=true;
                end


                for k=1:length(m3iDelegationConnectors)
                    this.UnmatchedPortsMap(m3iDelegationConnectors{k}.OuterPort.Name)=true;
                end
            end
        end

        function deleteUnmatched(this)



            unmatchedCompProtoNames=this.UnmatchedComponentPrototypesMap.keys();
            for k=1:length(unmatchedCompProtoNames)
                m3iCompProto=autosar.mm.Model.findObjectByName(this.M3IComposition,unmatchedCompProtoNames{k});
                m3iCompProto=m3iCompProto.at(1);
                if~autosar.composition.sl2mm.ModelBuilder.isRoundTripComponent(m3iCompProto)
                    m3iCompProto.destroy();
                end
            end



            unmatchedAssemblyConnectors=this.UnmatchedAssemblyConnectorsMap.keys();
            for k=1:numel(unmatchedAssemblyConnectors)
                m3iAssembly=autosar.mm.Model.findObjectByName(this.M3IComposition,unmatchedAssemblyConnectors{k});
                m3iAssembly=m3iAssembly.at(1);
                PCompPrototype=m3iAssembly.Provider.ComponentPrototype;
                RCompPrototype=m3iAssembly.Requester.ComponentPrototype;
                m3iProvidedPort=m3iAssembly.Provider.ProvidedPort;
                m3iRequiredPort=m3iAssembly.Requester.RequiredPort;

                isConnectingComponentsToBeRoundTripped=...
                autosar.composition.sl2mm.ModelBuilder.isRoundTripComponent(PCompPrototype)||...
                autosar.composition.sl2mm.ModelBuilder.isRoundTripComponent(RCompPrototype);
                isConnectingPortsToBeRoundTripped=...
                autosar.composition.sl2mm.ModelBuilder.isRoundTripPort(m3iProvidedPort)||...
                autosar.composition.sl2mm.ModelBuilder.isRoundTripPort(m3iRequiredPort);

                if~isConnectingComponentsToBeRoundTripped&&...
                    ~isConnectingPortsToBeRoundTripped
                    m3iAssembly.destroy();
                end
            end



            unmatchedDelegationConnectors=this.UnmatchedDelegationConnectorsMap.keys();
            for k=1:numel(unmatchedDelegationConnectors)
                m3iDelegation=autosar.mm.Model.findObjectByName(this.M3IComposition,unmatchedDelegationConnectors{k});
                m3iDelegation=m3iDelegation.at(1);
                innerCompPrototype=m3iDelegation.InnerPort.ComponentPrototype;

                if~autosar.composition.sl2mm.ModelBuilder.isRoundTripComponent(innerCompPrototype)&&...
                    ~autosar.composition.sl2mm.ModelBuilder.isRoundTripPort(m3iDelegation.OuterPort)
                    m3iDelegation.OuterPort.destroy();
                    m3iDelegation.destroy();
                end
            end
        end

        function buildMetaModel(this)
            trans=M3I.Transaction(this.M3IModel);


            compositionPkg=this.CompositionPackage;
            compositionName=this.CompositionName;
            m3iCompositionPkg=autosar.mm.Model.getOrAddARPackage(this.M3IModel,compositionPkg);


            this.M3IComposition=autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(...
            m3iCompositionPkg,m3iCompositionPkg.packagedElement,compositionName,this.CompositionMetaClass);


            for idx=1:length(this.ComponentPrototypes)
                this.findOrCreateComponentPrototypes(this.ComponentPrototypes(idx));
            end


            for idx=1:length(this.AssemblyConnectors)
                this.findOrCreateAssemblyConnector(this.AssemblyConnectors(idx));
            end


            for idx=1:length(this.DelegationConnectors)
                this.findOrCreateDelegationConnector(this.DelegationConnectors(idx));
            end


            this.deleteUnmatched();

            trans.commit();
        end

        function m3iConnector=findOrCreateDelegationConnector(this,connectorSpec)



            m3iDelegationConnectors=m3i.filter(@(x)...
            isa(x,'Simulink.metamodel.arplatform.composition.DelegationConnector'),...
            this.M3IComposition.Connectors);

            matchedExistingConnector=false;
            for k=1:length(m3iDelegationConnectors)
                m3iDelegationConnector=m3iDelegationConnectors{k};
                if connectorSpec.IsInbound
                    if strcmp(connectorSpec.InnerCompPrototypeName,m3iDelegationConnector.InnerPort.ComponentPrototype.Name)&&...
                        isa(m3iDelegationConnector.InnerPort,this.DelegationInnerRPortMetaClass)&&...
                        strcmp(connectorSpec.InnerPortPrototypeQName,autosar.api.Utils.getQualifiedName(m3iDelegationConnector.InnerPort.RequiredPort))&&...
                        strcmp(connectorSpec.OuterPortPrototypeName,m3iDelegationConnector.OuterPort.Name)
                        matchedExistingConnector=true;
                        break;
                    end
                else
                    if strcmp(connectorSpec.InnerCompPrototypeName,m3iDelegationConnector.InnerPort.ComponentPrototype.Name)&&...
                        isa(m3iDelegationConnector.InnerPort,this.DelegationInnerPPortMetaClass)&&...
                        strcmp(connectorSpec.InnerPortPrototypeQName,autosar.api.Utils.getQualifiedName(m3iDelegationConnector.InnerPort.ProvidedPort))&&...
                        strcmp(connectorSpec.OuterPortPrototypeName,m3iDelegationConnector.OuterPort.Name)
                        matchedExistingConnector=true;
                        break;
                    end
                end
            end


            if matchedExistingConnector
                m3iConnector=m3iDelegationConnector;
                if this.UnmatchedDelegationConnectorsMap.isKey(m3iDelegationConnector.Name)
                    this.UnmatchedDelegationConnectorsMap.remove(m3iDelegationConnector.Name);
                end
                return
            end

            connectorName=connectorSpec.calculateConnectorName(this.MaxShortNameLength);
            m3iConnector=...
            autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(...
            this.M3IComposition,this.M3IComposition.Connectors,connectorName,this.DelegationMetaClass);


            portMetaClass=connectorSpec.InnerCompM3IPort.MetaClass.qualifiedName;
            portPropName=autosar.composition.sl2mm.ModelBuilder.getPortPropertyNameFromMetaClass(portMetaClass);
            [componentQName,innerPortName]=autosar.utils.splitQualifiedName(connectorSpec.InnerPortPrototypeQName);
            m3iComponent=autosar.mm.Model.findChildByName(this.M3IModel,componentQName);
            if connectorSpec.IsInbound

                m3iConnector.InnerPort=eval(sprintf('%s(this.M3IModel)',this.DelegationInnerRPortMetaClass));
                m3iConnector.InnerPort.RequiredPort=autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(...
                m3iComponent,m3iComponent.(portPropName),innerPortName,portMetaClass);
            else

                m3iConnector.InnerPort=eval(sprintf('%s(this.M3IModel)',this.DelegationInnerPPortMetaClass));
                m3iConnector.InnerPort.ProvidedPort=autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(...
                m3iComponent,m3iComponent.(portPropName),innerPortName,portMetaClass);
            end

            m3iCompProto=...
            autosar.mm.sl2mm.ModelBuilder.findInSequenceNamedItem(...
            this.M3IComposition,this.M3IComposition.Components,...
            connectorSpec.InnerCompPrototypeName,this.CompPrototypeMetaClass);
            m3iConnector.InnerPort.ComponentPrototype=m3iCompProto;


            m3iConnector.OuterPort=autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(...
            this.M3IComposition,this.M3IComposition.(portPropName),connectorSpec.OuterPortPrototypeName,portMetaClass);


            arPkg=this.M3IModel.RootPackage.at(1);
            interfaceName=connectorSpec.InnerCompM3IPort.Interface.Name;
            m3iInterfaceMetaClass=connectorSpec.InnerCompM3IPort.Interface.MetaClass;
            seq=Simulink.metamodel.arplatform.ModelFinder.findObjectInModel(arPkg,interfaceName,m3iInterfaceMetaClass);
            if(seq.size==0)

                m3iInterface=eval(sprintf('%s(this.M3IModel)',m3iInterfaceMetaClass.qualifiedName));
                m3iInterface.Name=interfaceName;
                if isa(m3iInterface,'Simulink.metamodel.arplatform.interface.SenderReceiverInterface')
                    autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(...
                    m3iInterface,m3iInterface.DataElements,...
                    connectorSpec.InnerCompM3IPort.Interface.DataElements.at(1).Name,...
                    'Simulink.metamodel.arplatform.interface.FlowData');
                end
                interfaceQName=autosar.api.Utils.getQualifiedName(...
                connectorSpec.InnerCompM3IPort.Interface);
                interfacePkgName=autosar.utils.splitQualifiedName(...
                interfaceQName);
                m3iInterfacePkg=autosar.mm.Model.getOrAddARPackage(this.M3IModel,interfacePkgName);
                m3iInterfacePkg.packagedElement.append(m3iInterface);
            else
                m3iInterface=seq.at(1);
            end
            m3iConnector.OuterPort.Interface=m3iInterface;
        end

        function m3iComponentPrototype=findOrCreateComponentPrototypes(this,componentPrototypeSpec)
            m3iComponentPrototype=...
            autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(...
            this.M3IComposition,this.M3IComposition.Components,componentPrototypeSpec.Name,this.CompPrototypeMetaClass);


            if this.UnmatchedComponentPrototypesMap.isKey(componentPrototypeSpec.Name)
                this.UnmatchedComponentPrototypesMap.remove(m3iComponentPrototype.Name);
            end



            [componentPkg,componentName]=autosar.utils.splitQualifiedName(componentPrototypeSpec.ComponentQName);
            m3iComponentPkg=autosar.mm.Model.getOrAddARPackage(this.M3IModel,componentPkg);

            if strcmp(componentPrototypeSpec.ComponentType,'Composition')
                cMetaClass=this.CompositionMetaClass;
            else
                cMetaClass=this.ComponentMetaClass;
            end
            m3iComponent=autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(...
            m3iComponentPkg,m3iComponentPkg.packagedElement,componentName,cMetaClass);
            if strcmp(componentPrototypeSpec.ComponentType,'Composition')
                cKind=Simulink.metamodel.arplatform.component.AtomicComponentKind.Application;
            else
                cKind=Simulink.metamodel.arplatform.component.AtomicComponentKind.(componentPrototypeSpec.ComponentType);
            end
            m3iComponent.Kind=cKind;
            m3iComponentPrototype.Type=m3iComponent;
        end

        function m3iConnector=findOrCreateAssemblyConnector(this,connectorSpec)



            m3iAssemblyConnectors=m3i.filter(@(x)...
            isa(x,'Simulink.metamodel.arplatform.composition.AssemblyConnector'),...
            this.M3IComposition.Connectors);
            for k=1:length(m3iAssemblyConnectors)
                m3iAssemblyConnector=m3iAssemblyConnectors{k};
                if strcmp(connectorSpec.ProviderCompPrototypeName,m3iAssemblyConnector.Provider.ComponentPrototype.Name)&&...
                    strcmp(connectorSpec.ProviderPortPrototypeQName,autosar.api.Utils.getQualifiedName(m3iAssemblyConnector.Provider.ProvidedPort))&&...
                    strcmp(connectorSpec.RequesterCompPrototypeName,m3iAssemblyConnector.Requester.ComponentPrototype.Name)&&...
                    strcmp(connectorSpec.RequesterPortPrototypeQName,autosar.api.Utils.getQualifiedName(m3iAssemblyConnector.Requester.RequiredPort))
                    m3iConnector=m3iAssemblyConnector;


                    if this.UnmatchedAssemblyConnectorsMap.isKey(m3iAssemblyConnector.Name)
                        this.UnmatchedAssemblyConnectorsMap.remove(m3iAssemblyConnector.Name);
                    end
                    return;
                end
            end



            connectorName=connectorSpec.calculateConnectorName(this.MaxShortNameLength);
            m3iConnector=...
            autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(...
            this.M3IComposition,this.M3IComposition.Connectors,connectorName,this.AssemblyMetaClass);


            m3iConnector.Provider=eval(sprintf('%s(this.M3IModel)',this.AssemblyProviderMetaClass));
            [componentQName,providerPortName]=autosar.utils.splitQualifiedName(connectorSpec.ProviderPortPrototypeQName);
            m3iComponent=autosar.mm.Model.findChildByName(this.M3IModel,componentQName);



            m3iProviderPort=autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(...
            m3iComponent,m3iComponent.SenderPorts,providerPortName,this.PPortMetaClass);
            m3iConnector.Provider.ProvidedPort=m3iProviderPort;
            m3iCompProto=...
            autosar.mm.sl2mm.ModelBuilder.findInSequenceNamedItem(...
            this.M3IComposition,this.M3IComposition.Components,...
            connectorSpec.ProviderCompPrototypeName,this.CompPrototypeMetaClass);
            m3iConnector.Provider.ComponentPrototype=m3iCompProto;


            m3iConnector.Requester=eval(sprintf('%s(this.M3IModel)',this.AssemblyRequesterMetaClass));
            [componentQName,requesterPortName]=autosar.utils.splitQualifiedName(connectorSpec.RequesterPortPrototypeQName);
            m3iComponent=autosar.mm.Model.findChildByName(this.M3IModel,componentQName);



            m3iRequesterPort=autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(...
            m3iComponent,m3iComponent.ReceiverPorts,requesterPortName,this.RPortMetaClass);
            m3iConnector.Requester.RequiredPort=m3iRequesterPort;
            m3iCompProto=...
            autosar.mm.sl2mm.ModelBuilder.findInSequenceNamedItem(...
            this.M3IComposition,this.M3IComposition.Components,...
            connectorSpec.RequesterCompPrototypeName,this.CompPrototypeMetaClass);
            m3iConnector.Requester.ComponentPrototype=m3iCompProto;
        end

        function populateMapping(this)


            mapping=autosar.api.Utils.modelMapping(this.ModelName);


            componentId=this.M3IComposition.qualifiedName;
            compositionObj=Simulink.AutosarTarget.Composition(...
            componentId,this.CompositionName);
            mapping.mapComposition(compositionObj);


            slMapping=autosar.api.getSimulinkMapping(this.ModelName);
            for idx=1:numel(mapping.ModelBlocks)
                modelBlockMapping=mapping.ModelBlocks(idx);
                if isempty(modelBlockMapping.MappedTo)||...
                    isempty(modelBlockMapping.MappedTo.PrototypeName)
                    compPrototypeName=get_param(modelBlockMapping.Block,'Name');
                    compPrototypeQName=[this.CompositionQName,'/',compPrototypeName];

                    slMapping.mapModelBlock(compPrototypeName,compPrototypeName,...
                    compPrototypeQName);
                end
            end


            for idx=1:numel(mapping.Inports)
                inportMapping=mapping.Inports(idx);



                if isempty(inportMapping.MappedTo.Port)
                    [ARPortName,ARDataElementName,ARDataAccessMode]=...
                    autosar.composition.sl2mm.ModelBuilder.findCompositionPortMapping(inportMapping.Block);

                    inportMapping.mapPortElement(ARPortName,ARDataElementName,ARDataAccessMode);
                end
            end


            for idx=1:numel(mapping.Outports)
                outportMapping=mapping.Outports(idx);



                if isempty(outportMapping.MappedTo.Port)
                    [ARPortName,ARDataElementName,ARDataAccessMode]=...
                    autosar.composition.sl2mm.ModelBuilder.findCompositionPortMapping(outportMapping.Block);

                    outportMapping.mapPortElement(ARPortName,ARDataElementName,ARDataAccessMode);
                end
            end
        end

        function validateCompositionModel(this)



            compileObj=autosar.validation.CompiledModelUtils.forceCompiledModel(this.ModelName);
            compileObj.delete();

            assert(autosar.validation.ExportFcnValidator.isTopModelExportFcn(this.ModelName),...
            'Model %s is not a valid composition model because it is not an export-functions model');



            modelBlocks=find_system(this.ModelName,'LookUnderMasks','all',...
            'FollowLinks','on','BlockType','ModelReference');
            for blkIdx=1:length(modelBlocks)
                modelBlock=modelBlocks{blkIdx};
                refModel=get_param(modelBlock,'ModelName');
                if~bdIsLoaded(refModel)
                    load_system(refModel);
                end
                assert(autosar.api.Utils.isMapped(refModel),...
                'Model %s is not mapped to a component or composition. Map the model first.',refModel);
            end
        end

        function collectComponentPrototypesInfo(this)

            modelBlocks=find_system(this.ModelName,'LookUnderMasks','all',...
            'FollowLinks','on','BlockType','ModelReference');


            this.ComponentPrototypes=[];
            modelMapping=autosar.api.Utils.modelMapping(this.ModelName);
            for blkIdx=1:length(modelBlocks)
                modelBlock=modelBlocks{blkIdx};
                blockMapping=modelMapping.ModelBlocks.findobj('Block',modelBlock);
                isAlreadyMapped=~isempty(blockMapping)&&~isempty(blockMapping.MappedTo.PrototypeName);
                if isAlreadyMapped
                    compPrototypeName=blockMapping.MappedTo.PrototypeName;
                else
                    compPrototypeName=arblk.convertPortNameToArgName(...
                    get_param(modelBlock,'name'));
                    compPrototypeName=arxml.arxml_private('p_create_aridentifier',...
                    compPrototypeName,this.MaxShortNameLength);
                end
                refModel=get_param(modelBlock,'ModelName');
                if~bdIsLoaded(refModel)
                    load_system(refModel);
                end
                m3iComp=autosar.api.Utils.m3iMappedComponent(refModel);
                compQName=autosar.api.Utils.getQualifiedName(m3iComp);


                if autosar.api.Utils.isMappedToComposition(refModel)
                    compKind='Composition';
                else
                    compKind=m3iComp.Kind.toString();
                end


                compPrototype=autosar.composition.sl2mm.private.ComponentPrototype(...
                compPrototypeName,compQName,compKind);
                this.ComponentPrototypes=[this.ComponentPrototypes,compPrototype];
            end
        end

        function collectConnectorsInfo(this)



            modelBlocks=find_system(this.ModelName,'LookUnderMasks','all',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'FollowLinks','on','BlockType','ModelReference');
            slInports=find_system(this.ModelName,'SearchDepth',1,'blocktype',...
            'Inport','OutputFunctionCall','off');


            slSignalLines=[];
            for blkIdx=1:length(modelBlocks)
                slSignalLines=[slSignalLines
                autosar.composition.sl2mm.ModelBuilder...
                .findCompositionSignalLinesFromSrcBlock(modelBlocks{blkIdx})];%#ok<AGROW>
            end


            for blkIdx=1:length(slInports)
                slSignalLines=[slSignalLines
                autosar.composition.sl2mm.ModelBuilder...
                .findCompositionSignalLinesFromSrcBlock(slInports{blkIdx})];%#ok<AGROW>
            end


            compositionModelMapping=autosar.api.Utils.modelMapping(this.ModelName);
            for lineIdx=1:length(slSignalLines)
                slSignalLine=slSignalLines(lineIdx);
                srcBlkH=get_param(slSignalLine.getSrcPortHandle(),'SrcBlockHandle');
                dstBlkH=get_param(slSignalLine.getDstPortHandle(),'DstBlockHandle');
                srcBlkType=get_param(srcBlkH,'BlockType');
                dstBlkType=get_param(dstBlkH,'BlockType');
                isAssembly=strcmp(srcBlkType,'ModelReference')&&...
                strcmp(dstBlkType,'ModelReference');
                if isAssembly
                    srcPortH=get(slSignalLine.getSrcPortHandle(),'SrcPortHandle');
                    portNum=get_param(srcPortH,'PortNumber');
                    portType=get_param(srcPortH,'PortType');
                    refModelName=get_param(get_param(srcPortH,'Parent'),'ModelName');
                    portType(1)=upper(portType(1));
                    slPort=find_system(refModelName,'SearchDepth',1,...
                    'BlockType',portType,'Port',num2str(portNum));
                    m3iProviderPort=autosar.composition.sl2mm.ModelBuilder.findARPortMappedToSLPort(...
                    refModelName,slPort{1});
                    providerPortQName=autosar.api.Utils.getQualifiedName(m3iProviderPort);
                    providerCompProtoName=get_param(srcBlkH,'Name');


                    dstPortH=get(slSignalLine.getDstPortHandle(),'DstPortHandle');
                    portNum=get_param(dstPortH,'PortNumber');
                    portType=get_param(dstPortH,'PortType');
                    refModelName=get_param(get_param(dstPortH,'Parent'),'ModelName');
                    portType(1)=upper(portType(1));
                    slPort=find_system(refModelName,'SearchDepth',1,...
                    'BlockType',portType,'Port',num2str(portNum));
                    m3iRequesterPort=autosar.composition.sl2mm.ModelBuilder.findARPortMappedToSLPort(...
                    refModelName,slPort{1});
                    requesterPortQName=autosar.api.Utils.getQualifiedName(m3iRequesterPort);
                    requesterCompProtoName=get_param(dstBlkH,'Name');
                    assemblyConnector=autosar.composition.sl2mm.private.AssemblyConnector(...
                    providerCompProtoName,providerPortQName,requesterCompProtoName,requesterPortQName);
                    this.AssemblyConnectors=[this.AssemblyConnectors,assemblyConnector];
                else
                    isOutBound=strcmp(srcBlkType,'ModelReference')&&strcmp(dstBlkType,'Outport');
                    isInBound=strcmp(srcBlkType,'Inport')&&strcmp(dstBlkType,'ModelReference');
                    isDelegation=isOutBound||isInBound;

                    if isDelegation
                        if isOutBound
                            srcPortH=get(slSignalLine.getSrcPortHandle(),'SrcPortHandle');
                            portNum=num2str(get_param(srcPortH,'PortNumber'));
                            refModelName=get_param(get_param(srcPortH,'Parent'),'ModelName');
                            innerSlPort=find_system(refModelName,'SearchDepth',1,...
                            'BlockType','Outport','Port',portNum);
                            assert(length(innerSlPort)==1,'could not find Outport with portNum "%s" in "%s".',portNum,refModelName);
                            innerM3IPort=autosar.composition.sl2mm.ModelBuilder.findARPortMappedToSLPort(...
                            refModelName,innerSlPort{1});
                            innerCompProtoName=get_param(srcBlkH,'Name');




                            outerSlPort=[this.ModelName,'/',get_param(dstBlkH,'Name')];
                            blockMapping=compositionModelMapping.Outports.findobj('Block',outerSlPort);
                            isAlreadyMapped=~isempty(blockMapping)&&~isempty(blockMapping.MappedTo.Port);
                            if isAlreadyMapped
                                outerPortName=blockMapping.MappedTo.Port;
                            else

                                outerPortName=innerM3IPort.Name;
                            end
                        else
                            dstPortH=get(slSignalLine.getDstPortHandle(),'DstPortHandle');
                            portNum=num2str(get_param(dstPortH,'PortNumber'));
                            refModelName=get_param(get_param(dstPortH,'Parent'),'ModelName');
                            innerSlPort=find_system(refModelName,'SearchDepth',1,...
                            'BlockType','Inport','Port',portNum);
                            assert(length(innerSlPort)==1,'could not find Inport with portNum "%s" in "%s".',portNum,refModelName);
                            innerM3IPort=autosar.composition.sl2mm.ModelBuilder.findARPortMappedToSLPort(...
                            refModelName,innerSlPort{1});
                            innerCompProtoName=get_param(dstBlkH,'Name');




                            outerSlPort=[this.ModelName,'/',get_param(srcBlkH,'Name')];
                            blockMapping=compositionModelMapping.Inports.findobj('Block',outerSlPort);
                            isAlreadyMapped=~isempty(blockMapping)&&~isempty(blockMapping.MappedTo.Port);
                            if isAlreadyMapped
                                outerPortName=blockMapping.MappedTo.Port;
                            else

                                outerPortName=innerM3IPort.Name;
                            end
                        end

                        innerPortQName=autosar.api.Utils.getQualifiedName(innerM3IPort);
                        delegationConnector=autosar.composition.sl2mm.private.DelegationConnector(...
                        innerCompProtoName,innerPortQName,outerPortName,isInBound,innerM3IPort);
                        this.DelegationConnectors=[this.DelegationConnectors,delegationConnector];
                    end
                end
            end




            providedServerOperations=[];
            for mdlIdx=1:length(modelBlocks)
                modelBlock=modelBlocks{mdlIdx};
                modelName=get_param(modelBlock,'ModelName');
                m3iComp=autosar.api.Utils.m3iMappedComponent(modelName);
                for serIdx=1:m3iComp.ServerPorts.size()
                    innerM3IPort=m3iComp.ServerPorts.at(serIdx);
                    if this.ExportServicePorts||~innerM3IPort.Interface.IsService

                        innerPortQName=autosar.api.Utils.getQualifiedName(innerM3IPort);
                        innerCompProtoName=get_param(modelBlock,'Name');
                        outerPortName=innerM3IPort.Name;
                        isInBound=false;
                        delegationConnector=autosar.composition.sl2mm.private.DelegationConnector(...
                        innerCompProtoName,innerPortQName,outerPortName,isInBound,innerM3IPort);
                        this.DelegationConnectors=[this.DelegationConnectors,delegationConnector];




                        providedServerOperation=struct('ProviderCompProtoName',get_param(modelBlock,'Name'),...
                        'ProviderPortQName',autosar.api.Utils.getQualifiedName(innerM3IPort),...
                        'ClientServerInterface',autosar.api.Utils.getQualifiedName(innerM3IPort.Interface));
                        providedServerOperations=[providedServerOperations,providedServerOperation];%#ok<AGROW>
















                    end
                end
            end



            for mdlIdx=1:length(modelBlocks)
                modelBlock=modelBlocks{mdlIdx};
                modelName=get_param(modelBlock,'ModelName');
                m3iComp=autosar.api.Utils.m3iMappedComponent(modelName);
                for clientIdx=1:m3iComp.ClientPorts.size()
                    innerM3IPort=m3iComp.ClientPorts.at(clientIdx);

                    if this.ExportServicePorts||~innerM3IPort.Interface.IsService
                        clientPortInterface=autosar.api.Utils.getQualifiedName(innerM3IPort.Interface);
                        if~isempty(providedServerOperations)
                            hits=strcmp(clientPortInterface,{providedServerOperations.ClientServerInterface});
                        else
                            hits=false;
                        end
                        innerPortQName=autosar.api.Utils.getQualifiedName(innerM3IPort);
                        innerCompProtoName=get_param(modelBlock,'Name');






                        if length(find(hits))==1

                            provider=providedServerOperations(hits);
                            assemblyConnector=autosar.composition.sl2mm.private.AssemblyConnector(...
                            provider.ProviderCompProtoName,provider.ProviderPortQName,innerCompProtoName,innerPortQName);
                            this.AssemblyConnectors=[this.AssemblyConnectors,assemblyConnector];
                        else

                            outerPortName=innerM3IPort.Name;
                            isInBound=true;
                            delegationConnector=autosar.composition.sl2mm.private.DelegationConnector(...
                            innerCompProtoName,innerPortQName,outerPortName,isInBound,innerM3IPort);
                            this.DelegationConnectors=[this.DelegationConnectors,delegationConnector];
                        end
                    end
                end
            end
        end
    end

    methods(Static,Access=private)
        function createEmptyCompositionMapping(modelName)


            mmgr=get_param(modelName,'MappingManager');
            [~]=Simulink.AutosarTarget.Component('','');
            [~]=Simulink.AutosarTarget.Composition('','');
            mappingType='AutosarComposition';
            mapping=mmgr.getActiveMappingFor(mappingType);
            if~isempty(mapping)
                mapping.unmap();
                mmgr.deleteMapping(mapping);
            end
            mappingName=autosar.api.Utils.createMappingName(modelName,mappingType);
            mmgr.createMapping(mappingName,mappingType);
            mmgr.activateMapping(mappingName);
            mapping=mmgr.getActiveMappingFor(mappingType);

            m3iModel=Simulink.metamodel.foundation.Factory.createNewModel();


            t=M3I.Transaction(m3iModel);
            m3iModel.Name='AUTOSAR';
            autosarPkg=Simulink.metamodel.arplatform.common.AUTOSAR(m3iModel);
            autosarPkg.Name='AUTOSAR';
            m3iModel.RootPackage.append(autosarPkg);

            t.commit();

            mapping.AUTOSAR_ROOT=m3iModel;
        end

        function propName=getPortPropertyNameFromMetaClass(portMetaClass)
            if strcmp(portMetaClass,'Simulink.metamodel.arplatform.port.DataReceiverPort')
                propName='ReceiverPorts';
            elseif strcmp(portMetaClass,'Simulink.metamodel.arplatform.port.DataSenderPort')
                propName='SenderPorts';
            elseif strcmp(portMetaClass,'Simulink.metamodel.arplatform.port.ModeReceiverPort')
                propName='ModeReceiverPorts';
            elseif strcmp(portMetaClass,'Simulink.metamodel.arplatform.port.ModeSenderPort')
                propName='ModeSenderPorts';
            elseif strcmp(portMetaClass,'Simulink.metamodel.arplatform.port.ClientPort')
                propName='ClientPorts';
            elseif strcmp(portMetaClass,'Simulink.metamodel.arplatform.port.ServerPort')
                propName='ServerPorts';
            elseif strcmp(portMetaClass,'Simulink.metamodel.arplatform.port.NvReceiverPort')
                propName='NvReceiverPorts';
            elseif strcmp(portMetaClass,'Simulink.metamodel.arplatform.port.NvSenderPort')
                propName='NvSenderPorts';
            elseif strcmp(portMetaClass,'Simulink.metamodel.arplatform.port.ParameterReceiverPort')
                propName='ParameterReceiverPorts';
            elseif strcmp(portMetaClass,'Simulink.metamodel.arplatform.port.TriggerReceiverPort')
                propName='TriggerReceiverPorts';
            else
                assert(false,'Unexpected port meta class: %s',portMetaClass);
            end
        end



        function m3iPort=findARPortMappedToSLPort(modelName,slPortName)
            mapping=autosar.api.Utils.modelMapping(modelName);
            slPortType=get_param(slPortName,'BlockType');
            if strcmp(slPortType,'Inport')
                blockMappings=mapping.Inports;
            else
                blockMappings=mapping.Outports;
            end
            blockMapping=blockMappings.findobj('Block',slPortName);
            assert(~isempty(blockMapping),...
            'Simulink port %s is not mapped! Map the Simulink port first.',slPortName);
            ARPortName=blockMapping.MappedTo.Port;
            m3iComp=autosar.api.Utils.m3iMappedComponent(modelName);
            m3iPortSeq=autosar.mm.Model.findObjectByName(m3iComp,ARPortName);
            assert(m3iPortSeq.size()==1,'Could not find ARPortName %s in model %s!',...
            ARPortName,modelName);
            m3iPort=m3iPortSeq.at(1);
        end

        function roundTrip=isRoundTripPort(m3iPort)


            roundTrip=~autosar.composition.mm2sl.SLConnector.portRequiresWiredConnection(m3iPort);
        end

        function toRoundTripFlag=isRoundTripComponent(m3iCompPrototype)






            cpTypeMetaClass=getMetaClass(m3iCompPrototype.Type);
            toRoundTripFlag=false;

            if strcmp(cpTypeMetaClass.qualifiedName,...
                'Simulink.metamodel.arplatform.component.ParameterComponent')
                toRoundTripFlag=true;
            elseif strcmp(cpTypeMetaClass.qualifiedName,...
                'Simulink.metamodel.arplatform.component.AtomicComponent')
                cpKind=m3iCompPrototype.Type.Kind;
                if(cpKind==Simulink.metamodel.arplatform.component.AtomicComponentKind.NvBlock)...
                    ||(cpKind==Simulink.metamodel.arplatform.component.AtomicComponentKind.Service)
                    toRoundTripFlag=true;
                end
            end
        end

        function[ARPortName,ARDataElementName,ARDataAccessMode]=findCompositionPortMapping(slPortName)




            portType=get_param(slPortName,'BlockType');
            assert(any(strcmp(portType,{'Inport','Outport'})),...
            'Unsupported block type "%s".',portType)
            switch portType
            case 'Inport'
                slSigLines=autosar.composition.sl2mm.ModelBuilder...
                .findCompositionSignalLinesFromSrcBlock(slPortName);
                assert(~isempty(slSigLines),'slSigLines is empty!');

                slSigLine=slSigLines(1);
                modelBlockName=getfullname(get(slSigLine.getDstPortHandle,'DstBlockHandle'));
                portNum=num2str(get(get(slSigLine.getDstPortHandle,'DstPortHandle'),'PortNum'));
            case 'Outport'
                pconn=get_param(slPortName,'PortConnectivity');
                srcBlk=pconn.SrcBlock;



                if strcmp(get_param(srcBlk,'BlockType'),'Merge')
                    pconn=get_param(srcBlk,'PortConnectivity');
                    idx=cellfun(@(x)~isempty(x),{pconn.SrcBlock});
                    assert(any(idx),'No inputs connected to merge block ''%s''',...
                    getfullname(srcBlk));
                    srcIdx=find(idx,1);
                    pconn=pconn(srcIdx);
                    srcBlk=pconn.SrcBlock;
                end

                if strcmp(get_param(srcBlk,'BlockType'),'From')
                    gotoBlk=get_param(srcBlk,'GotoBlock');
                    pconn=get_param(gotoBlk.handle,'PortConnectivity');
                    srcBlk=pconn.SrcBlock;
                end
                srctype=get_param(srcBlk,'BlockType');
                assert(strcmp(srctype,'ModelReference'),...
                'Unable to trace ''%s'' to model block.',slPortName);
                modelBlockName=getfullname(srcBlk);
                ph=get_param(modelBlockName,'PortHandles');
                outPortHandles=ph.Outport;
                portNum=num2str(get(outPortHandles(pconn.SrcPort+1),'PortNum'));
            end


            refModelName=get_param(modelBlockName,'ModelName');


            if~bdIsLoaded(refModelName)
                load_system(refModelName);
            end


            slPortName=find_system(refModelName,'SearchDepth',1,...
            'BlockType',portType,'Port',portNum);
            slPortName=slPortName{1};

            mapping=autosar.api.Utils.modelMapping(refModelName);
            if strcmp(portType,'Inport')
                blockmapping=mapping.Inports.findobj('Block',slPortName);
            else
                blockmapping=mapping.Outports.findobj('Block',slPortName);
            end
            ARPortName=blockmapping.MappedTo.Port;
            ARDataElementName=blockmapping.MappedTo.Element;
            ARDataAccessMode=blockmapping.MappedTo.DataAccessMode;
        end

        function slSignalLines=findCompositionSignalLinesFromSrcBlock(srcBlockH)



















            blockType=get_param(srcBlockH,'BlockType');
            assert(any(strcmp(blockType,{'ModelReference','Inport'})),...
            'Cannot mark connections for unsupported block Type %s.',blockType);

            slSignalLines=[];
            parentName=get_param(srcBlockH,'Parent');

            blockPC=get_param(srcBlockH,'PortConnectivity');
            for pcIdx=1:length(blockPC)
                if isempty(blockPC(pcIdx).DstBlock)
                    continue;
                end

                dstBlkHandles=blockPC(pcIdx).DstBlock;
                dstPortNums=blockPC(pcIdx).DstPort;

                sourcePort=[get_param(srcBlockH,'Name'),'/',blockPC(pcIdx).Type];
                for dstBlkIdx=1:length(dstBlkHandles)
                    dstBlkHandle=dstBlkHandles(dstBlkIdx);
                    dstPortNum=dstPortNums(dstBlkIdx);

                    dstBlkType=get_param(dstBlkHandle,'BlockType');
                    switch(dstBlkType)
                    case 'Goto'

                        gotoBlkObj=get_param(dstBlkHandle,'Object');
                        fromBlks=[gotoBlkObj.FromBlocks.handle];
                        for fromIdx=1:length(fromBlks)
                            hSrcBlk=fromBlks(fromIdx);
                            pconn=autosar.composition.sl2mm.ModelBuilder...
                            .findDestinationForFromBlock(hSrcBlk);
                            for dstIdx=1:length(pconn.DstBlock)

                                dstPort=[get_param(pconn.DstBlock(dstIdx),'Name'),'/',num2str(pconn.DstPort(dstIdx)+1)];
                                slSignalLines=[slSignalLines
                                autosar.composition.mm2sl.SLSignalLine(parentName,sourcePort,dstPort)];%#ok<AGROW>
                            end
                        end
                    case 'ModelReference'

                        dstPort=[get_param(dstBlkHandle,'Name'),'/',num2str(dstPortNum+1)];
                        slSignalLines=[slSignalLines
                        autosar.composition.mm2sl.SLSignalLine(parentName,sourcePort,dstPort)];%#ok<AGROW>
                    case 'Outport'

                        dstPort=[get_param(dstBlkHandle,'Name'),'/1'];
                        slSignalLines=[slSignalLines
                        autosar.composition.mm2sl.SLSignalLine(parentName,sourcePort,dstPort)];%#ok<AGROW>
                    case 'Merge'

                        pconn=autosar.composition.sl2mm.ModelBuilder...
                        .findDestinationForMergeBlock(dstBlkHandle);
                        for dstIdx=1:length(pconn.DstBlock)
                            dstPort=[get_param(pconn.DstBlock(dstIdx),'Name'),'/',num2str(pconn.DstPort(dstIdx)+1)];
                            slSignalLines=[slSignalLines
                            autosar.composition.mm2sl.SLSignalLine(parentName,sourcePort,dstPort)];%#ok<AGROW>
                        end
                    otherwise

                    end
                end
            end
        end

        function pconn=findDestinationForMergeBlock(hSrcBlock)




            srcBlockType=get_param(hSrcBlock,'BlockType');
            assert(any(strcmp(srcBlockType,{'Merge'})),...
            'Unsupported block type ''%s''.',srcBlockType);


            pconn=get_param(hSrcBlock,'PortConnectivity');
            idx=cellfun(@(x)~isempty(x),{pconn.DstPort});
            assert(any(idx),'Unconnected output from merge block ''%s''',...
            getfullname(hSrcBlock));
            pconn=pconn(idx);

            assert(length(pconn.DstBlock)==1,...
            'Branching is not supported for ''%s''.',...
            getfullname(hSrcBlock));
            dstBlkType=get_param(pconn.DstBlock,'BlockType');

            assert(any(strcmp(dstBlkType,...
            {'ModelReference','Outport'})),...
            'Unsupported destination block type ''%s'' from ''%s''.',...
            dstBlkType,getfullname(hSrcBlock));

        end

        function pconn=findDestinationForFromBlock(hSrcBlock)







            srcBlockType=get_param(hSrcBlock,'BlockType');
            assert(any(strcmp(srcBlockType,{'From'})),...
            'Unsupported block type ''%s''.',srcBlockType);


            pconn=get_param(hSrcBlock,'PortConnectivity');
            hDstBlock=pconn.DstBlock;
            dstBlkType=get_param(hDstBlock,'BlockType');
            assert(length(pconn.DstBlock)==1,...
            'Branching is not supported for ''%s''.',...
            getfullname(hSrcBlock));
            assert(any(strcmp(dstBlkType,...
            {'ModelReference','Merge','Outport'})),...
            'Unsupported destination block type ''%s'' from ''%s''.',...
            dstBlkType,getfullname(hSrcBlock));


            if strcmp(dstBlkType,'Merge')
                pconn=autosar.composition.sl2mm.ModelBuilder...
                .findDestinationForMergeBlock(hDstBlock);
            end

        end


    end
end





