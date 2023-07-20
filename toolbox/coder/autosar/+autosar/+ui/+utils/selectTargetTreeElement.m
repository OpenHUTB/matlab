




function selectTargetTreeElement(obj,nodeType)

    m3iObject=obj.getM3iObject();
    arExplorer=autosar.ui.utils.findExplorer(m3iObject.modelM3I);
    assert(~isempty(arExplorer),'Did not find explorer');

    imme=DAStudio.imExplorer(arExplorer);
    treeRoot=arExplorer.getRoot();
    treeChildren=treeRoot.getHierarchicalChildren();
    componentNodeIdx=1;
    hChildren=treeChildren(componentNodeIdx).getHierarchicalChildren();
    treeGrandChildren=[];
    if~isempty(hChildren)
        treeGrandChildren=hChildren(1).getHierarchicalChildren();
    end
    foundElement=false;
    for ii=1:length(treeChildren)

        children=treeChildren(ii).getHierarchicalChildren();
        for jj=1:length(children)
            if children(jj)==obj
                foundElement=true;
                treeGrandChildren=children(jj).getHierarchicalChildren();
                break;
            end
        end
        if foundElement
            break;
        end
    end

    selectedNode=[];
    switch nodeType
    case{autosar.ui.metamodel.PackageString.AtomicComponentsNodeName,...
        autosar.ui.metamodel.PackageString.InterfacesNodeName,...
        autosar.ui.metamodel.PackageString.ModeSwitchInterfacesNodeName,...
        autosar.ui.metamodel.PackageString.NvDataInterfacesNodeName,...
        autosar.ui.metamodel.PackageString.SwAddrMethods,...
        autosar.ui.metamodel.PackageString.ClientServerInterfacesNodeName,...
        autosar.ui.metamodel.PackageString.ParameterInterfacesNodeName,...
        autosar.ui.metamodel.PackageString.TriggerInterfacesNodeName,...
        autosar.ui.metamodel.PackageString.Preferences}
        for ii=1:length(treeChildren)
            if strcmp(treeChildren(ii).getDisplayLabel,nodeType)
                selectedNode=treeChildren(ii);
                break;
            end
        end
    case autosar.ui.metamodel.PackageString.CompuMethods
        selectedNode=treeChildren(8);
    case autosar.ui.metamodel.PackageString.clientPortsNode
        for ii=1:length(treeGrandChildren)
            if strcmp(treeGrandChildren(ii).getDisplayLabel,autosar.ui.metamodel.PackageString.clientPortsNode)
                selectedNode=treeGrandChildren(ii);
                break;
            end
        end
    case autosar.ui.metamodel.PackageString.ModeReceiverPortNodeName
        if~isempty(treeGrandChildren)
            selectedNode=treeGrandChildren(4);
        end
    case autosar.ui.metamodel.PackageString.ModeSenderPortNodeName
        if~isempty(treeGrandChildren)
            selectedNode=treeGrandChildren(5);
        end
    case autosar.ui.metamodel.PackageString.receiverPortsNode
        if~isempty(treeGrandChildren)
            selectedNode=treeGrandChildren(1);
        end
    case autosar.ui.metamodel.PackageString.serverPortsNode
        if~isempty(treeGrandChildren)
            selectedNode=treeGrandChildren(7);
        end
    case autosar.ui.metamodel.PackageString.senderPortsNode
        if~isempty(treeGrandChildren)
            selectedNode=treeGrandChildren(2);
        end
    case autosar.ui.metamodel.PackageString.senderReceiverPortsNode
        if~isempty(treeGrandChildren)
            selectedNode=treeGrandChildren(3);
        end
    case autosar.ui.metamodel.PackageString.nvReceiverPortsNode
        if~isempty(treeGrandChildren)
            selectedNode=treeGrandChildren(8);
        end
    case autosar.ui.metamodel.PackageString.nvSenderPortsNode
        if~isempty(treeGrandChildren)
            selectedNode=treeGrandChildren(9);
        end
    case autosar.ui.metamodel.PackageString.nvSenderReceiverPortsNode
        if~isempty(treeGrandChildren)
            selectedNode=treeGrandChildren(10);
        end
    case autosar.ui.metamodel.PackageString.ParameterReceiverPortNodeName
        if~isempty(treeGrandChildren)
            selectedNode=treeGrandChildren(11);
        end
    case autosar.ui.metamodel.PackageString.TriggerReceiverPortNodeName
        if~isempty(treeGrandChildren)
            selectedNode=treeGrandChildren(12);
        end
    case autosar.ui.metamodel.PackageString.runnableNode
        if~isempty(treeGrandChildren)
            selectedNode=treeGrandChildren(13);
        end
    case autosar.ui.metamodel.PackageString.irvNode
        if~isempty(treeGrandChildren)
            selectedNode=treeGrandChildren(14);
        end
    case autosar.ui.metamodel.PackageString.parameterNode
        if~isempty(treeGrandChildren)
            selectedNode=treeGrandChildren(15);
        end
    case autosar.ui.metamodel.PackageString.AdaptiveApplicationsNodeName
        for ii=1:length(treeChildren)
            if strcmp(treeChildren(ii).getDisplayLabel,autosar.ui.metamodel.PackageString.AdaptiveApplicationsNodeName)
                selectedNode=treeChildren(ii);
                break;
            end
        end
    case autosar.ui.metamodel.PackageString.ServiceInterfacesNodeName
        for ii=1:length(treeChildren)
            if strcmp(treeChildren(ii).getDisplayLabel,autosar.ui.metamodel.PackageString.ServiceInterfacesNodeName)
                selectedNode=treeChildren(ii);
                break;
            end
        end
    case autosar.ui.metamodel.PackageString.PersistencyKeyValueInterfacesNodeName
        for ii=1:length(treeChildren)
            if strcmp(treeChildren(ii).getDisplayLabel,autosar.ui.metamodel.PackageString.PersistencyKeyValueInterfacesNodeName)
                selectedNode=treeChildren(ii);
                break;
            end
        end
    case autosar.ui.metamodel.PackageString.providedPortsNode
        for ii=1:length(treeGrandChildren)
            if strcmp(treeGrandChildren(ii).getDisplayLabel,autosar.ui.metamodel.PackageString.providedPortsNode)
                selectedNode=treeGrandChildren(ii);
                break;
            end
        end
    case autosar.ui.metamodel.PackageString.requiredPortsNode
        for ii=1:length(treeGrandChildren)
            if strcmp(treeGrandChildren(ii).getDisplayLabel,autosar.ui.metamodel.PackageString.requiredPortsNode)
                selectedNode=treeGrandChildren(ii);
                break;
            end
        end
    case{autosar.ui.metamodel.PackageString.dataElementsNode,...
        autosar.ui.metamodel.PackageString.operationsNode,...
        autosar.ui.metamodel.PackageString.triggerNode}
        if strcmp(nodeType,autosar.ui.metamodel.PackageString.dataElementsNode)
            treeNodeIndex=2;
        else
            treeNodeIndex=4;
        end
        interfaceNodes=treeChildren(treeNodeIndex).getHierarchicalChildren();
        for index=1:length(interfaceNodes)
            if strcmp(interfaceNodes(index).getM3iObject.qualifiedName,...
                obj.getM3iObject.qualifiedName)
                selectedNode=interfaceNodes(index).getHierarchicalChildren();
                break;
            end
        end


        treeNodeIndex=5;
        interfaceNodes=treeChildren(treeNodeIndex).getHierarchicalChildren();
        for index=1:length(interfaceNodes)
            if strcmp(interfaceNodes(index).getM3iObject.qualifiedName,...
                obj.getM3iObject.qualifiedName)
                selectedNode=interfaceNodes(index).getHierarchicalChildren();
                break;
            end
        end

        treeNodeIndex=6;
        interfaceNodes=treeChildren(treeNodeIndex).getHierarchicalChildren();
        for index=1:length(interfaceNodes)
            if strcmp(interfaceNodes(index).getM3iObject.qualifiedName,...
                obj.getM3iObject.qualifiedName)
                selectedNode=interfaceNodes(index).getHierarchicalChildren();
                break;
            end
        end

        treeNodeIndex=7;
        interfaceNodes=treeChildren(treeNodeIndex).getHierarchicalChildren();
        for index=1:length(interfaceNodes)
            if strcmp(interfaceNodes(index).getM3iObject.qualifiedName,...
                obj.getM3iObject.qualifiedName)
                selectedNode=interfaceNodes(index).getHierarchicalChildren();
                break;
            end
        end
    case{autosar.ui.metamodel.PackageString.methodsNodeName,...
        autosar.ui.metamodel.PackageString.eventsNodeName,...
        autosar.ui.metamodel.PackageString.fieldsNodeName,...
        autosar.ui.metamodel.PackageString.namespacesNodeName}

        interfaceNode=[];
        for ii=1:length(treeChildren)
            if strcmp(treeChildren(ii).getDisplayLabel,autosar.ui.metamodel.PackageString.ServiceInterfacesNodeName)
                interfaceNode=treeChildren(ii);
                break;
            end
        end
        assert(~isempty(interfaceNode),'Could not find service interfaces');
        serviceInterfaces=interfaceNode.getHierarchicalChildren();
        selectedNode=[];

        for ii=1:length(serviceInterfaces)

            if strcmp(serviceInterfaces(ii).getM3iObject.qualifiedName,...
                obj.getM3iObject.qualifiedName)
                childNodes=serviceInterfaces(ii).getHierarchicalChildren();
                for jj=1:length(childNodes)
                    if strcmp(childNodes(jj).getDisplayLabel(),nodeType)


                        selectedNode=childNodes(jj);
                        break;
                    end
                end
                if~isempty(selectedNode)
                    break;
                end
                break;
            end
        end
        assert(~isempty(selectedNode),'Could not find selected node');
    case autosar.ui.metamodel.PackageString.argumentsNode
        selectedNode=obj.HierarchicalChildren(1);
    otherwise
        assert(false,'Unknown type for target element');
    end
    assert(~isempty(selectedNode))
    imme.selectTreeViewNode(selectedNode);

end


