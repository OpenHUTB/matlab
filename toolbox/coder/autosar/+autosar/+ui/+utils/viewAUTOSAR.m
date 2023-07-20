





function m3iTerminalNode=viewAUTOSAR(m3iModel,varargin)

    argParser=inputParser;
    argParser.addRequired('m3iModel',@(x)isa(x,'Simulink.metamodel.foundation.Domain'));
    argParser.addParameter('UIViewType',autosar.ui.utils.UIViewType.Logical,...
    @(x)isa(x,'autosar.ui.utils.UIViewType'));
    argParser.addParameter('ShowComponentWithName','',@(x)ischar(x));
    argParser.parse(m3iModel,varargin{:});

    m3iModel=argParser.Results.m3iModel;
    uiViewType=argParser.Results.UIViewType;
    showComponentWithName=argParser.Results.ShowComponentWithName;

    collectedAtomicComponents=Simulink.metamodel.arplatform.component.AtomicComponent.empty(1,0);
    collectedAdaptiveApplications=Simulink.metamodel.arplatform.component.AdaptiveApplication.empty(1,0);

    isAdaptiveModel=false;

    senderReceiverInterfaces=Simulink.metamodel.arplatform.interface.SenderReceiverInterface.empty(1,0);
    clientServerInterfaces=Simulink.metamodel.arplatform.interface.ClientServerInterface.empty(1,0);
    modeSwitchInterfaces=Simulink.metamodel.arplatform.interface.ModeSwitchInterface.empty(1,0);
    triggerInterfaces=Simulink.metamodel.arplatform.interface.TriggerInterface.empty(1,0);
    paramInterfaces=Simulink.metamodel.arplatform.interface.ParameterInterface.empty(1,0);
    nvDataInterfaces=Simulink.metamodel.arplatform.interface.NvDataInterface.empty(1,0);
    serviceInterfaces=Simulink.metamodel.arplatform.interface.ServiceInterface.empty(1,0);
    PersistencyKeyValueInterfaces=Simulink.metamodel.arplatform.interface.PersistencyKeyValueInterface.empty(1,0);
    compuMethods=Simulink.metamodel.types.CompuMethod.empty(1,0);
    swAddrMethods=Simulink.metamodel.arplatform.common.SwAddrMethod.empty(1,0);

    atomicComponentClass=autosar.ui.metamodel.PackageString.ComponentsCell{1};
    adaptiveApplicationClass=autosar.ui.metamodel.PackageString.ComponentsCell{4};

    senderReceiverInterfaceClass=autosar.ui.metamodel.PackageString.InterfacesCell{1};
    clientServerInterfaceClass=autosar.ui.metamodel.PackageString.InterfacesCell{2};
    modeSwitchInterfaceClass=autosar.ui.metamodel.PackageString.InterfacesCell{3};
    triggerInterfaceClass=autosar.ui.metamodel.PackageString.InterfacesCell{4};
    parameterInterfaceClass=autosar.ui.metamodel.PackageString.InterfacesCell{5};
    nvDataInterfaceClass=autosar.ui.metamodel.PackageString.InterfacesCell{6};
    serviceInterfaceClass=autosar.ui.metamodel.PackageString.InterfacesCell{7};
    PersistencyKeyValueInterfaceClass=autosar.ui.metamodel.PackageString.InterfacesCell{8};
    CompuMethodClass=autosar.ui.metamodel.PackageString.CompuMethodClass;
    swAddrMethodClass=autosar.ui.metamodel.PackageString.SwAddrMethodClass;

    function collect(m3iObj,compName)
        containees=[];
        containeesSize=0;
        if~isempty(m3iObj)
            containees=m3iObj.containeeM3I;
            containeesSize=containees.size;
        end
        for i=1:containeesSize
            item=containees.at(i);
            qName=item.MetaClass.qualifiedName;

            if strcmp(qName,atomicComponentClass)...
                &&strcmp(item.qualifiedName,compName)
                collectedAtomicComponents(end+1)=item;%#ok<AGROW>
            elseif strcmp(qName,adaptiveApplicationClass)...
                &&strcmp(item.qualifiedName,compName)
                collectedAdaptiveApplications(end+1)=item;%#ok<AGROW>
                isAdaptiveModel=true;
            elseif strcmp(qName,senderReceiverInterfaceClass)
                senderReceiverInterfaces(end+1)=item;%#ok<AGROW>
            elseif strcmp(qName,clientServerInterfaceClass)
                clientServerInterfaces(end+1)=item;%#ok<AGROW>
            elseif strcmp(qName,modeSwitchInterfaceClass)
                modeSwitchInterfaces(end+1)=item;%#ok<AGROW>
            elseif strcmp(qName,triggerInterfaceClass)
                triggerInterfaces(end+1)=item;%#ok<AGROW>
            elseif strcmp(qName,parameterInterfaceClass)
                paramInterfaces(end+1)=item;%#ok<AGROW>
            elseif strcmp(qName,nvDataInterfaceClass)
                nvDataInterfaces(end+1)=item;%#ok<AGROW>
            elseif strcmp(qName,serviceInterfaceClass)
                serviceInterfaces(end+1)=item;%#ok<AGROW>
            elseif strcmp(qName,PersistencyKeyValueInterfaceClass)
                PersistencyKeyValueInterfaces(end+1)=item;%#ok<AGROW>
            elseif strcmp(qName,CompuMethodClass)
                compuMethods(end+1)=item;%#ok<AGROW>
            elseif strcmp(qName,swAddrMethodClass)
                swAddrMethods(end+1)=item;%#ok<AGROW>
            end
            collect(item,compName);
        end
    end


    isRefSharedDict=autosar.dictionary.Utils.hasReferencedModels(m3iModel);
    isArchitectureModel=autosar.composition.Utils.isAUTOSARArchModel(m3iModel);
    isRefInterfaceDict=false;
    if isRefSharedDict&&~isArchitectureModel
        [sharedM3IModel,dictFile]=autosar.dictionary.Utils.getUniqueReferencedModel(m3iModel);
        isRefInterfaceDict=sl.interface.dict.api.isInterfaceDictionary(dictFile);
        isSharedAUTOSARProps=~isRefInterfaceDict;
    end


    if uiViewType==autosar.ui.utils.UIViewType.Package
        if isRefSharedDict
            m3iTerminalNode=traversePackages(sharedM3IModel.RootPackage.front(),[]);
        else
            m3iTerminalNode=traversePackages(m3iModel.RootPackage.front(),[]);
        end
    else
        assert(uiViewType==autosar.ui.utils.UIViewType.Logical);
        showInterfacesAndTypes=~isArchitectureModel;

        collect(m3iModel,showComponentWithName);
        if isRefSharedDict&&showInterfacesAndTypes

            collect(sharedM3IModel,'');
        end

        if isArchitectureModel


            showAtomicComponentsNode=false;
        else
            showAtomicComponentsNode=~isempty(collectedAtomicComponents);
        end

        m3iTerminalNode=autosar.ui.metamodel.M3ITerminalNode(m3iModel,'',false);

        adaptiveView=isAdaptiveModel;
        classicView=~isAdaptiveModel;


        if isRefSharedDict&&showInterfacesAndTypes
            [~,dictName,ext]=fileparts(dictFile);
            arDictNode=autosar.ui.metamodel.M3INode([dictName,ext],m3iTerminalNode);
            arDictNode.IsSharedAUTOSARDictNode=isSharedAUTOSARProps;
            interfacesParentNode=arDictNode;
        else
            interfacesParentNode=m3iTerminalNode;
        end

        if adaptiveView
            adaptiveAppNode=autosar.ui.metamodel.M3INode(autosar.ui.metamodel.PackageString.AdaptiveApplicationsNodeName,m3iTerminalNode);
            m3iTerminalNode.addHierarchicalChild(adaptiveAppNode);
            m3iTerminalNode.addChild(adaptiveAppNode);

            serviceInterfaceNode=autosar.ui.metamodel.M3INode(autosar.ui.metamodel.PackageString.ServiceInterfacesNodeName,interfacesParentNode);
            interfacesParentNode.addHierarchicalChild(serviceInterfaceNode);
            interfacesParentNode.addChild(serviceInterfaceNode);
            PersistencyKeyValueInterfaceNode=autosar.ui.metamodel.M3INode(autosar.ui.metamodel.PackageString.PersistencyKeyValueInterfacesNodeName,interfacesParentNode);
            interfacesParentNode.addHierarchicalChild(PersistencyKeyValueInterfaceNode);
            interfacesParentNode.addChild(PersistencyKeyValueInterfaceNode);
        end
        if classicView

            if showAtomicComponentsNode
                atomicCompNode=autosar.ui.metamodel.M3INode(autosar.ui.metamodel.PackageString.AtomicComponentsNodeName,m3iTerminalNode);
                m3iTerminalNode.addHierarchicalChild(atomicCompNode);
                m3iTerminalNode.addChild(atomicCompNode);
            end

            if showInterfacesAndTypes
                if~isRefInterfaceDict


                    interfacesNode=autosar.ui.metamodel.M3INode(autosar.ui.metamodel.PackageString.InterfacesNodeName,interfacesParentNode);
                    interfacesParentNode.addHierarchicalChild(interfacesNode);
                    interfacesParentNode.addChild(interfacesNode);

                    modeSwitchInterfaceNode=autosar.ui.metamodel.M3INode(autosar.ui.metamodel.PackageString.ModeSwitchInterfacesNodeName,interfacesParentNode);
                    interfacesParentNode.addHierarchicalChild(modeSwitchInterfaceNode);
                    interfacesParentNode.addChild(modeSwitchInterfaceNode);
                end

                csInterfaceNode=autosar.ui.metamodel.M3INode(autosar.ui.metamodel.PackageString.ClientServerInterfacesNodeName,interfacesParentNode);
                interfacesParentNode.addHierarchicalChild(csInterfaceNode);
                interfacesParentNode.addChild(csInterfaceNode);

                if~isRefInterfaceDict


                    nvDataInterfaceNode=autosar.ui.metamodel.M3INode(autosar.ui.metamodel.PackageString.NvDataInterfacesNodeName,interfacesParentNode);
                    interfacesParentNode.addHierarchicalChild(nvDataInterfaceNode);
                    interfacesParentNode.addChild(nvDataInterfaceNode);
                end

                paramInterfaceNode=autosar.ui.metamodel.M3INode(autosar.ui.metamodel.PackageString.ParameterInterfacesNodeName,interfacesParentNode);
                interfacesParentNode.addHierarchicalChild(paramInterfaceNode);
                interfacesParentNode.addChild(paramInterfaceNode);

                triggerInterfaceNode=autosar.ui.metamodel.M3INode(autosar.ui.metamodel.PackageString.TriggerInterfacesNodeName,interfacesParentNode);
                interfacesParentNode.addHierarchicalChild(triggerInterfaceNode);
                interfacesParentNode.addChild(triggerInterfaceNode);

                if~isRefInterfaceDict


                    compuMethodsNode=autosar.ui.metamodel.M3INode(autosar.ui.metamodel.PackageString.CompuMethods,interfacesParentNode);
                    interfacesParentNode.addHierarchicalChild(compuMethodsNode);
                    interfacesParentNode.addChild(compuMethodsNode);



                    swAddrMethodsNode=autosar.ui.metamodel.M3INode(autosar.ui.metamodel.PackageString.SwAddrMethods,interfacesParentNode);
                    interfacesParentNode.addHierarchicalChild(swAddrMethodsNode);
                    interfacesParentNode.addChild(swAddrMethodsNode);
                end
            end
        end

        if isRefSharedDict&&showInterfacesAndTypes


            m3iTerminalNode.addHierarchicalChild(arDictNode);
            m3iTerminalNode.addChild(arDictNode);
        end






        showXmlOptions=~isRefInterfaceDict||isArchitectureModel;
        if showXmlOptions
            xmlOptions=autosar.ui.metamodel.M3INode(autosar.ui.metamodel.PackageString.Preferences,interfacesParentNode);
            interfacesParentNode.addHierarchicalChild(xmlOptions);
            interfacesParentNode.addChild(xmlOptions);
        end

        viewableAttributes=[];
        if~isempty(showComponentWithName)
            assert((~isempty(collectedAtomicComponents)||~isempty(collectedAdaptiveApplications)||...
            isArchitectureModel),...
            'We should have at least one component to show');
        end

        if classicView
            if showAtomicComponentsNode
                for k=1:length(collectedAtomicComponents)
                    if k==1
                        viewableAttributes=Simulink.metamodel.arplatform.ModelFinder.findViewableAttributes(...
                        collectedAtomicComponents(k),true);
                    end
                    traverse(collectedAtomicComponents(k),atomicCompNode,collectedAtomicComponents(k).MetaClass.name,...
                    viewableAttributes,true);
                end
            end

            if showInterfacesAndTypes
                if~isRefInterfaceDict
                    for k=1:length(senderReceiverInterfaces)
                        if k==1
                            viewableAttributes=Simulink.metamodel.arplatform.ModelFinder.findViewableAttributes(...
                            senderReceiverInterfaces(k),true);
                        end
                        traverse(senderReceiverInterfaces(k),interfacesNode,senderReceiverInterfaces(k).MetaClass.name,...
                        viewableAttributes,true);
                    end

                    for k=1:length(modeSwitchInterfaces)
                        if k==1
                            viewableAttributes=Simulink.metamodel.arplatform.ModelFinder.findViewableAttributes(...
                            modeSwitchInterfaces(k),true);
                        end
                        traverse(modeSwitchInterfaces(k),modeSwitchInterfaceNode,modeSwitchInterfaces(k).MetaClass.name,...
                        viewableAttributes,true);
                    end

                    for k=1:length(nvDataInterfaces)
                        if k==1
                            viewableAttributes=Simulink.metamodel.arplatform.ModelFinder.findViewableAttributes(...
                            nvDataInterfaces(k),true);
                        end
                        traverse(nvDataInterfaces(k),nvDataInterfaceNode,nvDataInterfaces(k).MetaClass.name,...
                        viewableAttributes,true);
                    end

                    for k=1:length(compuMethods)
                        if k==1
                            viewableAttributes=Simulink.metamodel.arplatform.ModelFinder.findViewableAttributes(...
                            compuMethods(k),true);
                        end
                        traverse(compuMethods(k),compuMethodsNode,...
                        autosar.ui.metamodel.PackageString.CompuMethods,...
                        viewableAttributes,true);
                    end

                    for k=1:length(swAddrMethods)
                        if k==1
                            viewableAttributes=Simulink.metamodel.arplatform.ModelFinder.findViewableAttributes(...
                            swAddrMethods(k),true);
                        end
                        traverse(swAddrMethods(k),swAddrMethodsNode,...
                        autosar.ui.metamodel.PackageString.SwAddrMethods,...
                        viewableAttributes,true);
                    end
                end

                for k=1:length(clientServerInterfaces)
                    if k==1
                        viewableAttributes=Simulink.metamodel.arplatform.ModelFinder.findViewableAttributes(...
                        clientServerInterfaces(k),true);
                    end
                    traverse(clientServerInterfaces(k),csInterfaceNode,clientServerInterfaces(k).MetaClass.name,...
                    viewableAttributes,true);
                end

                for k=1:length(triggerInterfaces)
                    if k==1
                        viewableAttributes=Simulink.metamodel.arplatform.ModelFinder.findViewableAttributes(...
                        triggerInterfaces(k),true);
                    end
                    traverse(triggerInterfaces(k),triggerInterfaceNode,triggerInterfaces(k).MetaClass.name,...
                    viewableAttributes,true);
                end
                for k=1:length(paramInterfaces)
                    if k==1
                        viewableAttributes=Simulink.metamodel.arplatform.ModelFinder.findViewableAttributes(...
                        paramInterfaces(k),true);
                    end
                    traverse(paramInterfaces(k),paramInterfaceNode,paramInterfaces(k).MetaClass.name,...
                    viewableAttributes,true);
                end
            end


            if showAtomicComponentsNode
                if~isempty(atomicCompNode.Children)
                    atomicCompNode.Children=atomicCompNode.Children(1).Children;
                end

                if~isempty(atomicCompNode.HierarchicalChildren)
                    atomicCompNode.HierarchicalChildren=atomicCompNode.HierarchicalChildren(1).HierarchicalChildren;
                end

                for j=1:length(atomicCompNode.HierarchicalChildren)
                    runnablesNode=findNonTerminalNode(atomicCompNode.HierarchicalChildren(j),autosar.ui.metamodel.PackageString.runnableNode);
                    irvNode=findNonTerminalNode(atomicCompNode.HierarchicalChildren(j),autosar.ui.metamodel.PackageString.irvNode);
                    parameterNode=findNonTerminalNode(atomicCompNode.HierarchicalChildren(j),autosar.ui.metamodel.PackageString.parameterNode);
                    behaviorNode=findNonTerminalNode(atomicCompNode.HierarchicalChildren(j),autosar.ui.metamodel.PackageString.behaviorNode);

                    if isempty(runnablesNode)
                        runnablesNode=autosar.ui.metamodel.M3INode(autosar.ui.metamodel.PackageString.runnableNode,...
                        behaviorNode(1).ParentM3I.Behavior);
                    end

                    if isempty(irvNode)
                        irvNode=autosar.ui.metamodel.M3INode(autosar.ui.metamodel.PackageString.irvNode,...
                        behaviorNode(1).ParentM3I.Behavior);
                    end

                    if isempty(parameterNode)
                        parameterNode=autosar.ui.metamodel.M3INode(autosar.ui.metamodel.PackageString.parameterNode,...
                        behaviorNode(1).ParentM3I.Behavior);
                    end
                    for k=1:length(atomicCompNode.HierarchicalChildren(j).HierarchicalChildren)
                        if behaviorNode==atomicCompNode.HierarchicalChildren(j).HierarchicalChildren(k)
                            atomicCompNode.HierarchicalChildren(j).removeHierarchicalChild(k);
                            atomicCompNode.HierarchicalChildren(j).removeChild(k);
                            break
                        end
                    end
                    if~isempty(runnablesNode)&&runnablesNode(1).isvalid
                        runnablesNode(1).HierarchicalChildren=[];

                        atomicCompNode.HierarchicalChildren(j).addHierarchicalChild(runnablesNode(1));
                        atomicCompNode.HierarchicalChildren(j).addChild(runnablesNode(1));
                    end
                    if~isempty(irvNode)&&irvNode(1).isvalid
                        irvNode(1).HierarchicalChildren=[];

                        atomicCompNode.HierarchicalChildren(j).addHierarchicalChild(irvNode(1));
                        atomicCompNode.HierarchicalChildren(j).addChild(irvNode(1));
                    end
                    if~isempty(parameterNode)&&parameterNode(1).isvalid
                        parameterNode(1).HierarchicalChildren=[];

                        atomicCompNode.HierarchicalChildren(j).addHierarchicalChild(parameterNode(1));
                        atomicCompNode.HierarchicalChildren(j).addChild(parameterNode(1));
                    end
                end
            end

            if showInterfacesAndTypes
                if~isRefInterfaceDict
                    if~isempty(interfacesNode.Children)
                        interfacesNode.Children=interfacesNode.Children(1).Children;
                    end
                    if~isempty(interfacesNode.HierarchicalChildren)
                        interfacesNode.HierarchicalChildren=interfacesNode.HierarchicalChildren(1).HierarchicalChildren;
                    end

                    for ii=1:length(interfacesNode.HierarchicalChildren)
                        if isempty(interfacesNode.HierarchicalChildren(ii).HierarchicalChildren)
                            newNode=autosar.ui.metamodel.M3INode(autosar.ui.metamodel.PackageString.dataElementsNode,...
                            interfacesNode.HierarchicalChildren(ii).getM3iObject);
                            interfacesNode.HierarchicalChildren(ii).addHierarchicalChild(newNode);
                            interfacesNode.HierarchicalChildren(ii).addChild(newNode);
                        end
                    end

                    if~isempty(nvDataInterfaceNode.Children)
                        nvDataInterfaceNode.Children=nvDataInterfaceNode.Children(1).Children;
                    end
                    if~isempty(nvDataInterfaceNode.HierarchicalChildren)
                        nvDataInterfaceNode.HierarchicalChildren=nvDataInterfaceNode.HierarchicalChildren(1).HierarchicalChildren;
                    end

                    for ii=1:length(nvDataInterfaceNode.HierarchicalChildren)
                        if isempty(nvDataInterfaceNode.HierarchicalChildren(ii).HierarchicalChildren)
                            newNode=autosar.ui.metamodel.M3INode(autosar.ui.metamodel.PackageString.dataElementsNode,...
                            nvDataInterfaceNode.HierarchicalChildren(ii).getM3iObject);
                            nvDataInterfaceNode.HierarchicalChildren(ii).addHierarchicalChild(newNode);
                            nvDataInterfaceNode.HierarchicalChildren(ii).addChild(newNode);
                        end
                    end

                    if~isempty(modeSwitchInterfaceNode.Children)
                        modeSwitchInterfaceNode.Children=modeSwitchInterfaceNode.Children(1).Children;
                    end
                    if~isempty(modeSwitchInterfaceNode.HierarchicalChildren)
                        for index=1:length(modeSwitchInterfaceNode.HierarchicalChildren(1).HierarchicalChildren)
                            if~isempty(modeSwitchInterfaceNode.HierarchicalChildren(1).HierarchicalChildren(index).HierarchicalChildren)
                                modeSwitchInterfaceNode.HierarchicalChildren(1).HierarchicalChildren(index).Children=...
                                modeSwitchInterfaceNode.HierarchicalChildren(1).HierarchicalChildren(index).HierarchicalChildren(1).Children;
                                modeSwitchInterfaceNode.HierarchicalChildren(1).HierarchicalChildren(index).HierarchicalChildren=[];
                            end
                        end
                        modeSwitchInterfaceNode.HierarchicalChildren=modeSwitchInterfaceNode.HierarchicalChildren(1).HierarchicalChildren;
                    end

                    if~isempty(compuMethodsNode.Children)
                        compuMethodsNode.Children=compuMethodsNode.Children(1).Children;
                    end
                    if~isempty(compuMethodsNode.HierarchicalChildren)
                        for ii=1:numel(compuMethodsNode.HierarchicalChildren)
                            compuMethodsNode.HierarchicalChildren(ii).HierarchicalChildren=[];
                        end
                        compuMethodsNode.HierarchicalChildren=[];
                    end

                    if~isempty(swAddrMethodsNode.Children)
                        swAddrMethodsNode.Children=swAddrMethodsNode.Children(1).Children;
                    end
                    if~isempty(swAddrMethodsNode.HierarchicalChildren)
                        for ii=1:numel(swAddrMethodsNode.HierarchicalChildren)
                            swAddrMethodsNode.HierarchicalChildren(ii).HierarchicalChildren=[];
                        end
                        swAddrMethodsNode.HierarchicalChildren=[];
                    end
                end

                if~isempty(paramInterfaceNode.Children)
                    paramInterfaceNode.Children=paramInterfaceNode.Children(1).Children;
                end
                if~isempty(paramInterfaceNode.HierarchicalChildren)
                    paramInterfaceNode.HierarchicalChildren=paramInterfaceNode.HierarchicalChildren(1).HierarchicalChildren;
                end

                for ii=1:length(paramInterfaceNode.HierarchicalChildren)
                    if isempty(paramInterfaceNode.HierarchicalChildren(ii).HierarchicalChildren)
                        newNode=autosar.ui.metamodel.M3INode(autosar.ui.metamodel.PackageString.dataElementsNode,...
                        paramInterfaceNode.HierarchicalChildren(ii).getM3iObject);
                        paramInterfaceNode.HierarchicalChildren(ii).addHierarchicalChild(newNode);
                        paramInterfaceNode.HierarchicalChildren(ii).addChild(newNode);
                    end
                end

                if~isempty(triggerInterfaceNode.Children)
                    triggerInterfaceNode.Children=triggerInterfaceNode.Children(1).Children;
                end
                if~isempty(triggerInterfaceNode.HierarchicalChildren)
                    triggerInterfaceNode.HierarchicalChildren=triggerInterfaceNode.HierarchicalChildren(1).HierarchicalChildren;
                end

                for ii=1:length(triggerInterfaceNode.HierarchicalChildren)
                    if isempty(triggerInterfaceNode.HierarchicalChildren(ii).HierarchicalChildren)
                        newNode=autosar.ui.metamodel.M3INode(autosar.ui.metamodel.PackageString.triggerNode,...
                        triggerInterfaceNode.HierarchicalChildren(ii).getM3iObject);
                        triggerInterfaceNode.HierarchicalChildren(ii).addHierarchicalChild(newNode);
                        triggerInterfaceNode.HierarchicalChildren(ii).addChild(newNode);
                    end
                end

                if~isempty(csInterfaceNode.Children)
                    csInterfaceNode.Children=csInterfaceNode.Children(1).Children;
                end
                if~isempty(csInterfaceNode.HierarchicalChildren)
                    csInterfaceNode.HierarchicalChildren=csInterfaceNode.HierarchicalChildren(1).HierarchicalChildren;
                end
                for ii=1:length(csInterfaceNode.HierarchicalChildren)
                    if isempty(csInterfaceNode.HierarchicalChildren(ii).HierarchicalChildren)

                        newNode=autosar.ui.metamodel.M3INode(autosar.ui.metamodel.PackageString.operationsNode,...
                        csInterfaceNode.HierarchicalChildren(ii).getM3iObject);
                        csInterfaceNode.HierarchicalChildren(ii).addHierarchicalChild(newNode);
                        csInterfaceNode.HierarchicalChildren(ii).addChild(newNode);
                    end
                    for jj=1:length(csInterfaceNode.HierarchicalChildren(ii).HierarchicalChildren(1).HierarchicalChildren)
                        opNode=csInterfaceNode.HierarchicalChildren(ii).HierarchicalChildren(1).HierarchicalChildren(jj);
                        if isempty(opNode.HierarchicalChildren)
                            newArgumentsNode=autosar.ui.metamodel.M3INode(...
                            autosar.ui.metamodel.PackageString.argumentsNode,opNode.getM3iObject);
                            opNode.addHierarchicalChild(newArgumentsNode);
                            opNode.addChild(newArgumentsNode);
                        end
                    end
                    if length(csInterfaceNode.HierarchicalChildren(ii).HierarchicalChildren)>1

                        csInterfaceNode.HierarchicalChildren(ii).HierarchicalChildren=...
                        csInterfaceNode.HierarchicalChildren(ii).HierarchicalChildren(1);
                    end
                end
            end
        end

        if adaptiveView
            for k=1:length(collectedAdaptiveApplications)
                if k==1
                    viewableAttributes=Simulink.metamodel.arplatform.ModelFinder.findViewableAttributes(...
                    collectedAdaptiveApplications(k),true);
                end
                traverse(collectedAdaptiveApplications(k),adaptiveAppNode,collectedAdaptiveApplications(k).MetaClass.name,...
                viewableAttributes,true);
            end

            for k=1:length(serviceInterfaces)
                if k==1
                    viewableAttributes=Simulink.metamodel.arplatform.ModelFinder.findViewableAttributes(...
                    serviceInterfaces(k),true);
                end
                traverse(serviceInterfaces(k),serviceInterfaceNode,serviceInterfaces(k).MetaClass.name,...
                viewableAttributes,true);
            end

            for k=1:length(PersistencyKeyValueInterfaces)
                if k==1
                    viewableAttributes=Simulink.metamodel.arplatform.ModelFinder.findViewableAttributes(...
                    PersistencyKeyValueInterfaces(k),true);
                end
                traverse(PersistencyKeyValueInterfaces(k),PersistencyKeyValueInterfaceNode,PersistencyKeyValueInterfaces(k).MetaClass.name,...
                viewableAttributes,true);
            end


            if~isempty(adaptiveAppNode.Children)
                adaptiveAppNode.Children=adaptiveAppNode.Children(1).Children;
            end

            if~isempty(adaptiveAppNode.HierarchicalChildren)
                adaptiveAppNode.HierarchicalChildren=adaptiveAppNode.HierarchicalChildren(1).HierarchicalChildren;
            end

            for j=1:length(adaptiveAppNode.HierarchicalChildren)
                behaviorNode=findNonTerminalNode(adaptiveAppNode.HierarchicalChildren(j),autosar.ui.metamodel.PackageString.behaviorNode);

                for k=1:length(adaptiveAppNode.HierarchicalChildren(j).HierarchicalChildren)
                    if behaviorNode==adaptiveAppNode.HierarchicalChildren(j).HierarchicalChildren(k)
                        adaptiveAppNode.HierarchicalChildren(j).removeHierarchicalChild(k);
                        adaptiveAppNode.HierarchicalChildren(j).removeChild(k);
                        break
                    end
                end
            end

            if~isempty(serviceInterfaceNode.Children)
                serviceInterfaceNode.Children=serviceInterfaceNode.Children(1).Children;
            end
            if~isempty(serviceInterfaceNode.HierarchicalChildren)
                serviceInterfaceNode.HierarchicalChildren=serviceInterfaceNode.HierarchicalChildren(1).HierarchicalChildren;
            end
            if~isempty(PersistencyKeyValueInterfaceNode.Children)
                PersistencyKeyValueInterfaceNode.Children=PersistencyKeyValueInterfaceNode.Children(1).Children;
            end
            if~isempty(PersistencyKeyValueInterfaceNode.HierarchicalChildren)
                PersistencyKeyValueInterfaceNode.HierarchicalChildren=PersistencyKeyValueInterfaceNode.HierarchicalChildren(1).HierarchicalChildren;
            end
        end
    end
end


function traverse(m3iObj,parent,propName,viewableAttributes,hasHierarchicalChildrenValue)
    foundMatch=false;
    if~isempty(parent.HierarchicalChildren)
        for i=1:length(parent.HierarchicalChildren)
            hierarchicalChild=parent.HierarchicalChildren(i);
            if strcmp(hierarchicalChild.getDisplayLabel,propName)
                parent=hierarchicalChild;
                foundMatch=true;
                break;
            end
        end
    end
    if foundMatch
        wrapper=autosar.ui.metamodel.M3ITerminalNode(m3iObj,parent.Name);
        if hasHierarchicalChildrenValue
            wrapperH=autosar.ui.metamodel.M3ITerminalNode(m3iObj,parent.Name,false);
            parent.addHierarchicalChild(wrapperH);
        end
        parent.addChild(wrapper);
    else
        newNode=autosar.ui.metamodel.M3INode(propName,parent.getM3iObject);
        parent.addHierarchicalChild(newNode);
        parent.addChild(newNode);
        parent=newNode;

        if~isempty(m3iObj)
            wrapper=autosar.ui.metamodel.M3ITerminalNode(m3iObj,parent.Name);
            if hasHierarchicalChildrenValue
                wrapperH=autosar.ui.metamodel.M3ITerminalNode(m3iObj,parent.Name,false);
                parent.addHierarchicalChild(wrapperH);
            end
            parent.addChild(wrapper);
        end
    end

    if isempty(m3iObj)
        return;
    end



    isComposite=true;
    if~isempty(viewableAttributes)
        viewableAttributesSize=viewableAttributes.size;
    else
        viewableAttributesSize=0;
    end

    for i=1:viewableAttributesSize
        oAttrName=viewableAttributes.at(i).name;
        item=m3iObj.get(oAttrName);
        if item.isEmpty
            if any(strcmp(oAttrName,autosar.ui.metamodel.PackageString.PortTypes))||...
                (isa(m3iObj,autosar.ui.metamodel.PackageString.InterfacesCell{7})&&...
                any(strcmp(oAttrName,autosar.ui.metamodel.PackageString.ServiceInterfaceChildrenNames)))||...
                (isa(m3iObj,autosar.ui.metamodel.PackageString.InterfacesCell{8})&&...
                any(strcmp(oAttrName,autosar.ui.metamodel.PackageString.PersistencyKeyValueInterfaceChildrenNames)))||...
                (isa(m3iObj,autosar.ui.configuration.PackageString.Operation)&&...
                strcmp(oAttrName,autosar.ui.metamodel.PackageString.argumentsNode))
                traverse([],wrapperH,oAttrName,[],false);
            end
        end
        itemViewableAttributes=[];
        for j=1:item.size
            if j==1
                if isa(item.at(j),'Simulink.metamodel.arplatform.interface.FlowData')||...
                    isa(item.at(j),autosar.ui.configuration.PackageString.SymbolProps)
                    itemViewableAttributes=[];
                else
                    itemViewableAttributes=...
                    Simulink.metamodel.arplatform.ModelFinder.findViewableAttributes(...
                    item.at(j),isComposite);
                end
            end
            hasHierarchicalChildrenForObj=hasHierarchicalChildren(item.at(j));
            if~isempty(wrapperH)
                traverse(item.at(j),wrapperH,oAttrName,itemViewableAttributes,hasHierarchicalChildrenForObj);
            elseif~isempty(root)
                traverse(item.at(j),root,oAttrName,itemViewableAttributes,hasHierarchicalChildrenForObj);
            else
                traverse(item.at(j),parent,oAttrName,itemViewableAttributes,hasHierarchicalChildrenForObj);
            end
        end
    end

end


function root=traversePackages(m3iObj,parent)
    root=[];
    wrapper=[];

    if isempty(parent)
        root=autosar.ui.metamodel.M3ITerminalNode(m3iObj,'');
    else
        wrapper=autosar.ui.metamodel.M3ITerminalNode(m3iObj,parent.Name);
        parent.addHierarchicalChild(wrapper);
        parent.addChild(wrapper);
    end

    containees=[];
    containeesSize=0;
    if~isempty(m3iObj)
        containees=m3iObj.containeeM3I;
        containeesSize=containees.size;
    end
    for i=1:containeesSize
        item=containees.at(i);
        if item.isvalid&&item.has(autosar.ui.metamodel.PackageString.NamedProperty)&&...
            (isa(item,autosar.ui.metamodel.PackageString.packageClass))

            if~isempty(wrapper)
                traversePackages(item,wrapper);
            elseif~isempty(root)
                traversePackages(item,root);
            end
        end
    end
end



function ret=hasHierarchicalChildren(m3iObj)
    ret=false;

    if isa(m3iObj,autosar.ui.configuration.PackageString.Operation)

        ret=true;
        return;
    elseif isa(m3iObj,autosar.ui.configuration.PackageString.DataElement)


        ret=false;
        return;
    end
    m3iContaineeSeq=m3iObj.containeeM3I;
    for k=1:m3iContaineeSeq.size
        m3iContainee=m3iContaineeSeq.at(k);
        if m3iContainee.isvalid&&m3iContainee.has(autosar.ui.metamodel.PackageString.NamedProperty)
            ret=true;
            return;
        end
    end
end

function foundObjects=findNonTerminalNode(root,name)
    function find(m3iObj,name,isHierarchical)
        if~isvalid(m3iObj)
            return
        end
        if~isempty(m3iObj)&&strcmp(m3iObj.Name,name)...
            &&isa(m3iObj,'autosar.ui.metamodel.M3INode')
            foundObjects(end+1)=m3iObj;
        end

        containees=[];
        containeesSize=0;
        if~isempty(m3iObj)
            if isHierarchical
                containees=m3iObj.getHierarchicalChildren;
            else
                containees=m3iObj.getChildren;
            end
            containeesSize=length(containees);
        end
        for i=1:containeesSize
            find(containees(i),name,isHierarchical);
        end
    end
    foundObjects=autosar.ui.metamodel.M3INode.empty(1,0);
    find(root,name,true);
    find(root,name,false);
end



