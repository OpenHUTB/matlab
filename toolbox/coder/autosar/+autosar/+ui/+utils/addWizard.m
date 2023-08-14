




function addWizard(explorer)
    imme=DAStudio.imExplorer(explorer);
    selectedNode=imme.getCurrentTreeNode;
    metaClass=metaclass(selectedNode);
    index=-1;
    selectedListNode=imme.getSelectedListNodes();
    if~isempty(selectedListNode)

        selListNodeName=selectedListNode(end).getDisplayLabel;
        listNodes=selectedNode.getChildren();
        for ii=1:length(listNodes)
            if strcmp(listNodes(ii).getDisplayLabel,selListNodeName)
                index=ii+1;
                break;
            end
        end
    end

    if~isempty(selectedNode)...
        &&strcmp(metaClass.Name,'autosar.ui.metamodel.M3INode')
        nodeChildren=selectedNode.getChildren;


        protectedNames={};
        if any(strcmp(selectedNode.Name,autosar.ui.metamodel.PackageString.PortTypes))
            for ii=1:length(autosar.ui.configuration.PackageString.Ports)
                ports=autosar.ui.utils.collectObject(selectedNode.ParentM3I,...
                autosar.ui.configuration.PackageString.Ports{ii});
                for jj=1:length(ports)
                    protectedNames=[protectedNames,ports(jj).Name];%#ok<AGROW>
                end
            end
        elseif any(strcmp(selectedNode.Name,autosar.ui.metamodel.PackageString.InterfaceTypes))
            for ii=1:length(autosar.ui.metamodel.PackageString.InterfacesCell)
                interfaces=autosar.ui.utils.collectObject(selectedNode.ParentM3I.M3iObject,...
                autosar.ui.metamodel.PackageString.InterfacesCell{ii});
                for jj=1:length(interfaces)
                    protectedNames=[protectedNames,interfaces(jj).Name];%#ok<AGROW>
                end
            end
        else
            for i=1:length(nodeChildren)
                if nodeChildren(i).isvalid
                    protectedNames=[protectedNames...
                    ,nodeChildren(i).getDisplayLabel()];%#ok<AGROW>
                end
            end



            if strcmp(selectedNode.Name,...
                autosar.ui.metamodel.PackageString.runnableNode)||...
                strcmp(selectedNode.Name,...
                autosar.ui.metamodel.PackageString.irvNode)
                runnables=selectedNode.ParentM3I.Runnables;
                for jj=1:runnables.size()
                    protectedNames=[protectedNames,runnables.at(jj).Name,runnables.at(jj).symbol];%#ok<AGROW>
                end
                irvs=selectedNode.ParentM3I.IRV;
                for jj=1:irvs.size()
                    protectedNames=[protectedNames,irvs.at(jj).Name];%#ok<AGROW>
                end
                eventObjs=selectedNode.ParentM3I.Events;
                for jj=1:eventObjs.size()
                    protectedNames=[protectedNames,eventObjs.at(jj).Name];%#ok<AGROW>
                end
            end
        end
        if strcmp(selectedNode.Name,autosar.ui.metamodel.PackageString.CompuMethods)
            name=autosar.ui.metamodel.PackageString.CompuMethodName;
        else
            name=autosar.ui.wizard.PackageString.NewName;
        end
        newName=genvarname(name,protectedNames);

        modelName=explorer.closeListener.Source{1}.Name;
        if strcmp(selectedNode.Name,autosar.ui.metamodel.PackageString.operationsNode)
            opDlg=autosar.ui.metamodel.Operation(selectedNode,modelName,newName);
            DAStudio.Dialog(opDlg);
        elseif strcmp(selectedNode.Name,autosar.ui.metamodel.PackageString.CompuMethods)
            cmDlg=autosar.ui.metamodel.CompuMethod(selectedNode,modelName,newName);
            DAStudio.Dialog(cmDlg);
        elseif strcmp(selectedNode.Name,autosar.ui.metamodel.PackageString.SwAddrMethods)
            cmDlg=autosar.ui.metamodel.SwAddrMethod(selectedNode,modelName,newName,protectedNames);
            DAStudio.Dialog(cmDlg);
        elseif strcmp(selectedNode.Name,autosar.ui.wizard.PackageString.DataElements)||...
            strcmp(selectedNode.Name,autosar.ui.metamodel.PackageString.runnableNode)||...
            strcmp(selectedNode.Name,autosar.ui.metamodel.PackageString.irvNode)||...
            strcmp(selectedNode.Name,autosar.ui.metamodel.PackageString.argumentsNode)||...
            strcmp(selectedNode.Name,autosar.ui.metamodel.PackageString.parameterNode)||...
            strcmp(selectedNode.Name,autosar.ui.metamodel.PackageString.triggerNode)||...
            strcmp(selectedNode.Name,autosar.ui.metamodel.PackageString.eventsNodeName)||...
            strcmp(selectedNode.Name,autosar.ui.metamodel.PackageString.fieldsNodeName)||...
            strcmp(selectedNode.Name,autosar.ui.metamodel.PackageString.methodsNodeName)||...
            strcmp(selectedNode.Name,autosar.ui.metamodel.PackageString.namespacesNodeName)
            autosar.ui.utils.addNode(selectedNode,{newName},index);
        else
            if any(strcmp(selectedNode.Name,...
                autosar.ui.metamodel.PackageString.InterfaceTypes))
                option=autosar.ui.wizard.WizardDialogState.Interfaces;
            elseif any(strcmp(selectedNode.Name,...
                autosar.ui.metamodel.PackageString.PortTypes))
                option=autosar.ui.wizard.WizardDialogState.Ports;
            else
                assert(false,'Invalid selected object');
            end
            autosar.ui.wizard.launch(modelName,option,protectedNames,...
            selectedNode);
        end
    end
end

