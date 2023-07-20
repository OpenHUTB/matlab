




function selChangedCallback(h,e)
    obj=e.EventData.getMCOSObjectReference();
    if~isempty(obj)&&~isempty(findstr(class(obj),'autosar.ui.configuration'))%#ok<*FSTR>
        if isa(obj.MObject,'Simulink.MappingManager')||...
            isa(obj.MObject,autosar.ui.configuration.PackageString.ModelMapClass)
            h.showDialogView(true);
            h.showListView(false);
        else
            h.showDialogView(false);
            h.showListView(true);
            h.setListMultiSelect(false);
        end
        addDeleteTb=h.EditToolbar;
        if~isempty(addDeleteTb)
            addDeleteTb.visible=~isempty(obj.getMObject)&&obj.isMultMapping;
        end

    else
        targetSelChanged(h,e);
    end
    explorer=h;
    if~isempty(findprop(explorer,'NavigateInValidation'))&&...
        explorer.NavigateInValidation
        explorer.NavigateInValidation=false;
        if~isempty(findprop(explorer,'TargetNode'))
            nodeName=explorer.TargetNode;

            imme=DAStudio.imExplorer(explorer);
            modelNode=explorer.getRoot.getHierarchicalChildren();
            imme.expandTreeNode(modelNode);
            inOutNodes=modelNode.getHierarchicalChildren();
            for inOutNodesIndex=1:length(inOutNodes)
                listNodes=inOutNodes(inOutNodesIndex).getChildren();
                for index=1:length(listNodes)
                    if strcmp(listNodes(index).getDisplayLabel(),nodeName)
                        imme.selectListViewNode(listNodes(index));
                        return;
                    end
                end
            end
        end
    end
end

function targetSelChanged(explorer,e)
    obj=e.EventData.getMCOSObjectReference();
    if~isempty(findstr(class(obj),'autosar.ui.metamodel'))
        m3iObj=obj.getM3iObject();
        if strcmp(obj.Name,autosar.ui.metamodel.PackageString.Preferences)||...
            (~isempty(m3iObj)&&(m3iObj==m3iObj.modelM3I)||...
            isa(m3iObj,autosar.ui.metamodel.PackageString.ComponentClass)||...
            isa(m3iObj,autosar.ui.metamodel.PackageString.InterfaceClass)||...
            isa(m3iObj,autosar.ui.configuration.PackageString.Operation)||...
            isa(m3iObj,autosar.ui.metamodel.PackageString.CompuMethodClass))
            explorer.showDialogView(true);
            explorer.showListView(false);
        else
            if strcmp(obj.Name,autosar.ui.metamodel.PackageString.runnableNode)
                explorer.showDialogView(false);
            else
                explorer.showDialogView(false);


                if~isempty(findprop(explorer,'EventData'))
                    explorer.EventData=[];
                end
                if~isempty(findprop(explorer,'SelectedEventName'))
                    explorer.SelectedEventName='';
                end
            end
            explorer.showListView(true);
        end
        imme=DAStudio.imExplorer(explorer);
        if strcmp(obj.Name,autosar.ui.metamodel.PackageString.argumentsNode)||...
            strcmp(obj.Name,autosar.ui.metamodel.PackageString.namespacesNodeName)
            imme.enableListSorting(false,'Name',false);
        else
            imme.enableListSorting(true,'Name',true);
        end
        if strcmp(obj.Name,autosar.ui.metamodel.PackageString.receiverPortsNode)||...
            strcmp(obj.Name,autosar.ui.metamodel.PackageString.senderPortsNode)||...
            strcmp(obj.Name,autosar.ui.metamodel.PackageString.senderReceiverPortsNode)||...
            strcmp(obj.Name,autosar.ui.metamodel.PackageString.nvReceiverPortsNode)||...
            strcmp(obj.Name,autosar.ui.metamodel.PackageString.nvSenderPortsNode)||...
            strcmp(obj.Name,autosar.ui.metamodel.PackageString.nvSenderReceiverPortsNode)||...
            strcmp(obj.Name,autosar.ui.metamodel.PackageString.requiredPortsNode)||...
            strcmp(obj.Name,autosar.ui.metamodel.PackageString.providedPortsNode)

            imme.showUnappliedChangesDialog=false;
            imme.applyChanges=true;
        else
            imme.showUnappliedChangesDialog=true;
            imme.applyChanges=false;
        end
    end
end















