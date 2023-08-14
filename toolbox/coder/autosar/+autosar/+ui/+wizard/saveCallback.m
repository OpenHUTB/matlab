




function saveCallback(obj)
    ret=obj.setData;
    if ret~=0
        return;
    end
    nodeNames={};

    if isequal(obj.Option,autosar.ui.wizard.WizardDialogState.Ports)
        interfaces=[];
        switch obj.SelectedNode.Name
        case{autosar.ui.metamodel.PackageString.receiverPortsNode,...
            autosar.ui.metamodel.PackageString.senderPortsNode,...
            autosar.ui.metamodel.PackageString.senderReceiverPortsNode}
            interfaceClass=autosar.ui.metamodel.PackageString.InterfacesCell{1};
            portList=obj.ComponentBuilder.Ports;
        case autosar.ui.metamodel.PackageString.ModeReceiverPortNodeName
            interfaceClass=autosar.ui.metamodel.PackageString.InterfacesCell{3};
            portList=obj.ComponentBuilder.Ports;
        case autosar.ui.metamodel.PackageString.ModeSenderPortNodeName
            interfaceClass=autosar.ui.metamodel.PackageString.InterfacesCell{3};
            portList=obj.ComponentBuilder.Ports;
        case{autosar.ui.metamodel.PackageString.serverPortsNode,...
            autosar.ui.metamodel.PackageString.clientPortsNode}
            interfaceClass=autosar.ui.metamodel.PackageString.InterfacesCell{2};
            portList=obj.ComponentBuilder.CSPorts;
        case{autosar.ui.metamodel.PackageString.nvReceiverPortsNode,...
            autosar.ui.metamodel.PackageString.nvSenderPortsNode,...
            autosar.ui.metamodel.PackageString.nvSenderReceiverPortsNode}
            interfaceClass=autosar.ui.metamodel.PackageString.InterfacesCell{6};
            portList=obj.ComponentBuilder.Ports;
        case autosar.ui.metamodel.PackageString.ParameterReceiverPortNodeName
            interfaceClass=autosar.ui.metamodel.PackageString.InterfacesCell{5};
            portList=obj.ComponentBuilder.Ports;
        case autosar.ui.metamodel.PackageString.TriggerReceiverPortNodeName
            interfaceClass=autosar.ui.metamodel.PackageString.InterfacesCell{4};
            portList=obj.ComponentBuilder.Ports;
        case autosar.ui.metamodel.PackageString.providedPortsNode
            interfaceClass=autosar.ui.metamodel.PackageString.InterfacesCell{7};
            portList=obj.ComponentBuilder.ServicePorts;
        case autosar.ui.metamodel.PackageString.requiredPortsNode
            interfaceClass=autosar.ui.metamodel.PackageString.InterfacesCell{7};
            portList=obj.ComponentBuilder.ServicePorts;
        case autosar.ui.metamodel.PackageString.persistencyRequiredPortsNode
            interfaceClass=autosar.ui.metamodel.PackageString.InterfacesCell{8};
            portList=obj.ComponentBuilder.PersistencyPorts;
        case autosar.ui.metamodel.PackageString.persistencyProvidedPortsNode
            interfaceClass=autosar.ui.metamodel.PackageString.InterfacesCell{8};
            portList=obj.ComponentBuilder.PersistencyPorts;
        case autosar.ui.metamodel.PackageString.persistencyProvidedRequiredPortsNode
            interfaceClass=autosar.ui.metamodel.PackageString.InterfacesCell{8};
            portList=obj.ComponentBuilder.PersistencyPorts;
        otherwise
            assert(false,'Unknown port type');
        end
        collectedInterfaces=autosar.ui.utils.collectObject(...
        obj.SelectedNode.ParentM3I.modelM3I,...
        interfaceClass);
        for i=1:length(portList)
            port=portList(i);
            nodeNames=[nodeNames,port.Name];%#ok<AGROW>
            for j=1:length(collectedInterfaces)
                if strcmp(collectedInterfaces(j).Name,port.Interface)
                    interfaces=[interfaces,collectedInterfaces(j)];%#ok<AGROW>
                    break;
                end
            end
        end
        if isempty(interfaces)
            errordlg(DAStudio.message('RTW:autosar:NoInterfaceError'),...
            autosar.ui.metamodel.PackageString.ErrorTitle,'replace');
            return;
        end
        option=interfaces;
        interfacePkgName=[];
    elseif isequal(obj.Option,autosar.ui.wizard.WizardDialogState.Interfaces)
        interfaceOption={};
        if strcmp(obj.SelectedNode.getDisplayLabel,...
            autosar.ui.metamodel.PackageString.ClientServerInterfacesNodeName)
            interfaceList=obj.ComponentBuilder.CSInterfaces;
            interfacePkgName=obj.ComponentBuilder.CSInterfacePackage;
        elseif strcmp(obj.SelectedNode.getDisplayLabel,...
            autosar.ui.metamodel.PackageString.ServiceInterfacesNodeName)
            interfaceList=obj.ComponentBuilder.ServiceInterfaces;
            interfacePkgName=obj.ComponentBuilder.InterfacePackage;
        elseif strcmp(obj.SelectedNode.getDisplayLabel,...
            autosar.ui.metamodel.PackageString.PersistencyKeyValueInterfacesNodeName)
            interfaceList=obj.ComponentBuilder.PersistencyKeyValueInterfaces;
            interfacePkgName=obj.ComponentBuilder.InterfacePackage;
        else
            interfaceList=obj.ComponentBuilder.Interfaces;
            interfacePkgName=obj.ComponentBuilder.InterfacePackage;
        end
        for i=1:length(interfaceList)
            interface=interfaceList(i);
            nodeNames=[nodeNames,interface.Name];%#ok<AGROW>
            if strcmp(interface.InterfaceType,...
                autosar.ui.wizard.PackageString.InterfaceTypes{2})
                interfaceType=true;
            else
                interfaceType=false;
            end
            switch obj.SelectedNode.getDisplayLabel
            case autosar.ui.metamodel.PackageString.InterfacesNodeName
                interfaceOption=[interfaceOption...
                ,{{interfaceType,interface.DataElementCount}}];%#ok<AGROW>
            case autosar.ui.metamodel.PackageString.ModeSwitchInterfacesNodeName
                interfaceOption=[interfaceOption...
                ,{{interfaceType,interface.ModeGroupName}}];%#ok<AGROW>
            case autosar.ui.metamodel.PackageString.ClientServerInterfacesNodeName
                interfaceOption=[interfaceOption...
                ,{{interfaceType,interface.OperationCount}}];%#ok<AGROW>
            case autosar.ui.metamodel.PackageString.NvDataInterfacesNodeName
                interfaceOption=[interfaceOption...
                ,{{interfaceType,interface.DataElementCount}}];%#ok<AGROW>
            case autosar.ui.metamodel.PackageString.ParameterInterfacesNodeName
                interfaceOption=[interfaceOption...
                ,{{interfaceType,interface.DataElementCount}}];%#ok<AGROW>
            case autosar.ui.metamodel.PackageString.TriggerInterfacesNodeName
                interfaceOption=[interfaceOption...
                ,{{interfaceType,interface.DataElementCount}}];%#ok<AGROW>
            case autosar.ui.metamodel.PackageString.ServiceInterfacesNodeName
                interfaceOption=[interfaceOption...
                ,{{interfaceType,interface.EventCount,interface.MethodCount}}];%#ok<AGROW>
            case autosar.ui.metamodel.PackageString.PersistencyKeyValueInterfacesNodeName
                interfaceOption=[interfaceOption...
                ,{{interfaceType,interface.DataElementCount}}];%#ok<AGROW>
            end
        end
        option=interfaceOption;
    end
    assert(length(nodeNames)==length(option));
    autosar.ui.utils.addNode(obj.SelectedNode,nodeNames,...
    option,interfacePkgName);
    obj.DialogH.delete;
end


