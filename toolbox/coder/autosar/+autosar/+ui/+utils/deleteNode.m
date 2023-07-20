




function deleteNode(explorer)
    imme=DAStudio.imExplorer(explorer);
    selectedNode=imme.getCurrentTreeNode;
    metaClass=metaclass(selectedNode);
    selListNodes=imme.getSelectedListNodes;
    if iscell(selListNodes)
        selListNodes=[selListNodes{:}]';
    end
    if isempty(selListNodes)
        return;
    end

    if~isempty(selectedNode)&&strcmp(metaClass.Name,'autosar.ui.metamodel.M3INode')
        modelM3I=selListNodes(1).getM3iObject.modelM3I;

        t=M3I.Transaction(modelM3I);
        for k=1:length(selListNodes)
            selNode=selListNodes(k).getM3iObject;
            selNode=selNode.asMutable;
            usedInterface=false;

            if isa(selNode,...
                autosar.ui.metamodel.PackageString.InterfacesCell{1})||...
                isa(selNode,...
                autosar.ui.metamodel.PackageString.InterfacesCell{2})||...
                isa(selNode,...
                autosar.ui.metamodel.PackageString.InterfacesCell{3})||...
                isa(selNode,...
                autosar.ui.metamodel.PackageString.InterfacesCell{4})||...
                isa(selNode,...
                autosar.ui.metamodel.PackageString.InterfacesCell{5})||...
                isa(selNode,...
                autosar.ui.metamodel.PackageString.InterfacesCell{6})||...
                isa(selNode,...
                autosar.ui.metamodel.PackageString.InterfacesCell{7})

                m3iPorts=autosar.mm.Model.findPortsUsingInterface(selNode);
                if~m3iPorts.isEmpty()
                    usedInterface=true;
                    errordlg(sprintf(...
                    autosar.ui.wizard.PackageString.RemoveInterfaceError,...
                    selNode.Name),...
                    autosar.ui.wizard.PackageString.RemoveInterfaceDlgTitle,...
                    'replace');
                end
            end

            deletedEvents=Simulink.metamodel.arplatform.behavior.Event.empty(1,0);
            if isa(selNode,autosar.ui.configuration.PackageString.Runnables)
                eventsObj=selNode.containerM3I.Events;
                for eventIndex=1:eventsObj.size()
                    if~isempty(eventsObj.at(eventIndex).StartOnEvent)&&...
                        strcmp(eventsObj.at(eventIndex).StartOnEvent.Name,selNode.Name)
                        deletedEvents{end+1}=eventsObj.at(eventIndex);%#ok<AGROW>
                    end
                end
            end
            if~usedInterface
                selNode.destroy;

                if~isempty(deletedEvents)
                    for ii=length(deletedEvents):-1:1
                        deletedEvents{ii}.destroy;
                    end
                end
            end
        end
        t.commit;


        imme=DAStudio.imExplorer(explorer);
        if strcmp(selectedNode.Name,autosar.ui.metamodel.PackageString.argumentsNode)||...
            strcmp(selectedNode.Name,autosar.ui.metamodel.PackageString.namespacesNodeName)
            imme.enableListSorting(false,'Name',false);
        end
    end
end

