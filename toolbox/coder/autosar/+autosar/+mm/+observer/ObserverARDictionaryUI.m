classdef ObserverARDictionaryUI<autosar.mm.observer.Observer





    properties(SetAccess=immutable,GetAccess=private)
        ExplorerUI;
    end

    methods

        function this=ObserverARDictionaryUI(explorerUI)
            assert(~isempty(explorerUI),'explorerUI should not be empty!');
            this.ExplorerUI=explorerUI;
        end

        function observeChanges(this,changesReport)
            this.observeDeleted(changesReport);
            this.observeAdded(changesReport);
            this.observeChanged(changesReport);
        end
    end

    methods(Access=private)
        function observeDeleted(this,changesReport)
            deleted=changesReport.getRemoved();
            for i=1:deleted.size
                cur=deleted.at(i);
                if autosar.ui.utils.isaValidUIObject(cur)
                    old=changesReport.getOldState(cur);

                    autosar.ui.utils.updateEventsForAddRemove(this.ExplorerUI,cur,old);
                    autosar.mm.observer.ObserverARDictionaryUI.updateEventData(this.ExplorerUI,cur,old);



                    newQName='';
                    foundObjects=autosar.ui.metamodel.M3IToGUIMappingUtil.findMCOSObjInTree(...
                    this.ExplorerUI.TraversedRoot,old.asMutable,newQName);
                    if~isempty(foundObjects)
                        for j=1:length(foundObjects)
                            if foundObjects(j).isvalid
                                autosar.mm.observer.ObserverARDictionaryUI.deleteObjectFullHierachy(foundObjects(j));
                            end
                        end
                    end
                end
            end

            if deleted.size>0

                ed=DAStudio.EventDispatcher;
                ed.broadcastEvent('HierarchyChangedEvent',this.ExplorerUI.getRoot());
            end
        end

        function observeAdded(this,changesReport)
            import autosar.ui.codemapping.PortCalibrationAttributeHandler;

            added=changesReport.getAdded();
            for i=1:added.size
                cur=added.at(i);
                if autosar.ui.utils.isaValidUIObject(cur)


                    if isa(cur,'Simulink.metamodel.arplatform.documentation.ImmutableLLongName')

                        cur=PortCalibrationAttributeHandler.getParentM3iObjFromLLongName(cur.asMutable);
                    end

                    parentMCOS=...
                    autosar.ui.metamodel.M3IToGUIMappingUtil.findParentMCOSObjInTree(...
                    this.ExplorerUI.TraversedRoot,cur.asMutable);

                    parent=cur.containerM3I;
                    isPort=isa(cur.asMutable,'Simulink.metamodel.arplatform.port.Port');
                    isInServiceInterface=...
                    isa(cur.containerM3I,'Simulink.metamodel.arplatform.interface.ServiceInterface');
                    isInPersistencyKeyValueInterface=...
                    isa(cur.containerM3I,'Simulink.metamodel.arplatform.interface.PersistencyKeyValueInterface');

                    autosar.ui.utils.updateEventsForAddRemove(this.ExplorerUI,cur,[]);
                    autosar.mm.observer.ObserverARDictionaryUI.updateEventData(this.ExplorerUI,cur,[]);



                    isInterface=isa(cur.asMutable,'Simulink.metamodel.arplatform.interface.PortInterface');

                    if~isempty(parentMCOS)




                        if isInterface
                            newNodeHierarchical=autosar.ui.metamodel.M3ITerminalNode(...
                            cur.asMutable,cur.MetaClass.name,false);
                            newNodeList=autosar.ui.metamodel.M3ITerminalNode(...
                            cur.asMutable,cur.MetaClass.name,true);
                            if isa(cur.asMutable,...
                                autosar.ui.metamodel.PackageString.InterfacesCell{2})
                                operationsNode=autosar.ui.metamodel.M3INode(...
                                autosar.ui.metamodel.PackageString.operationsNode,...
                                cur.asMutable);
                                newNodeHierarchical.addHierarchicalChild(operationsNode);
                                newNodeHierarchical.addChild(operationsNode);
                            elseif isa(cur.asMutable,...
                                autosar.ui.metamodel.PackageString.InterfacesCell{1})
                                dataElementsNode=autosar.ui.metamodel.M3INode(...
                                autosar.ui.wizard.PackageString.DataElements,...
                                cur.asMutable);
                                newNodeHierarchical.addHierarchicalChild(dataElementsNode);
                                newNodeHierarchical.addChild(dataElementsNode);
                            elseif isa(cur.asMutable,...
                                autosar.ui.metamodel.PackageString.InterfacesCell{3})
                            elseif isa(cur.asMutable,...
                                autosar.ui.metamodel.PackageString.InterfacesCell{4})
                                triggerNode=autosar.ui.metamodel.M3INode(...
                                autosar.ui.wizard.PackageString.Triggers,...
                                cur.asMutable);
                                newNodeHierarchical.addHierarchicalChild(triggerNode);
                                newNodeHierarchical.addChild(triggerNode);
                            elseif isa(cur.asMutable,...
                                autosar.ui.metamodel.PackageString.InterfacesCell{6})
                                dataElementsNode=autosar.ui.metamodel.M3INode(...
                                autosar.ui.wizard.PackageString.DataElements,...
                                cur.asMutable);
                                newNodeHierarchical.addHierarchicalChild(dataElementsNode);
                                newNodeHierarchical.addChild(dataElementsNode);
                            elseif isa(cur.asMutable,...
                                autosar.ui.metamodel.PackageString.InterfacesCell{5})
                                dataElementsNode=autosar.ui.metamodel.M3INode(...
                                autosar.ui.wizard.PackageString.DataElements,...
                                cur.asMutable);
                                newNodeHierarchical.addHierarchicalChild(dataElementsNode);
                                newNodeHierarchical.addChild(dataElementsNode);
                            elseif isa(cur.asMutable,...
                                autosar.ui.metamodel.PackageString.InterfacesCell{7})

                                eventsNode=autosar.ui.metamodel.M3INode(...
                                autosar.ui.metamodel.PackageString.eventsNodeName,...
                                cur.asMutable);
                                newNodeHierarchical.addHierarchicalChild(eventsNode);
                                newNodeHierarchical.addChild(eventsNode);

                                methodsNode=autosar.ui.metamodel.M3INode(...
                                autosar.ui.metamodel.PackageString.methodsNodeName,...
                                cur.asMutable);
                                newNodeHierarchical.addHierarchicalChild(methodsNode);

                                namespacesNode=autosar.ui.metamodel.M3INode(...
                                autosar.ui.metamodel.PackageString.namespacesNodeName,...
                                cur.asMutable);
                                newNodeHierarchical.addHierarchicalChild(namespacesNode);
                                newNodeHierarchical.addChild(namespacesNode);

                            elseif isa(cur.asMutable,...
                                autosar.ui.metamodel.PackageString.InterfacesCell{8})

                                DataElementsNode=autosar.ui.metamodel.M3INode(...
                                autosar.ui.metamodel.PackageString.dataElementsNode,...
                                cur.asMutable);
                                newNodeHierarchical.addHierarchicalChild(DataElementsNode);
                                newNodeHierarchical.addChild(DataElementsNode);
                            else
                                assert(false,'Invalid Interface');
                            end
                            parentMCOS.addHierarchicalChild(newNodeHierarchical);
                            parentMCOS.addChild(newNodeList);
                        elseif isa(cur.asMutable,...
                            autosar.ui.metamodel.PackageString.CompuMethodClass)
                            newNode=autosar.ui.metamodel.M3ITerminalNode(...
                            cur.asMutable,cur.MetaClass.name,true);
                            parentMCOS.addChild(newNode);
                        elseif isa(cur.asMutable,...
                            autosar.ui.metamodel.PackageString.SwAddrMethodClass)
                            newNode=autosar.ui.metamodel.M3ITerminalNode(...
                            cur.asMutable,cur.MetaClass.name,true);
                            parentMCOS.addChild(newNode);
                        elseif isa(cur.asMutable,...
                            autosar.ui.configuration.PackageString.Runnables)
                            newNode=autosar.ui.metamodel.M3ITerminalNode(...
                            cur.asMutable,parent.Name,true);
                            parentMCOS.addChild(newNode);
                        elseif isa(cur.asMutable,...
                            autosar.ui.configuration.PackageString.IRV)
                            newNode=autosar.ui.metamodel.M3ITerminalNode(...
                            cur.asMutable,parent.Name,true);
                            parentMCOS.addChild(newNode);
                        elseif isa(cur.asMutable,...
                            autosar.ui.configuration.PackageString.ParameterData)...
                            &&~isa(parent,'Simulink.metamodel.arplatform.interface.ParameterInterface')
                            newNode=autosar.ui.metamodel.M3ITerminalNode(...
                            cur.asMutable,parent.Name,true);
                            parentMCOS.addChild(newNode);
                        elseif isa(cur.asMutable,...
                            autosar.ui.configuration.PackageString.Operation)
                            newNodeHierarchical=autosar.ui.metamodel.M3ITerminalNode(...
                            cur.asMutable,autosar.ui.metamodel.PackageString.operationsNode,false);
                            newNodeList=autosar.ui.metamodel.M3ITerminalNode(...
                            cur.asMutable,autosar.ui.metamodel.PackageString.operationsNode,true);

                            newArgumentsNode=autosar.ui.metamodel.M3INode(...
                            autosar.ui.metamodel.PackageString.argumentsNode,cur.asMutable);
                            newNodeHierarchical.addHierarchicalChild(newArgumentsNode);
                            newNodeHierarchical.addChild(newArgumentsNode);
                            parentMCOS.addHierarchicalChild(newNodeHierarchical);
                            parentMCOS.addChild(newNodeList);
                        elseif isPort||...
                            isa(cur.asMutable,...
                            autosar.ui.configuration.PackageString.ParameterData)||...
                            (isa(cur.asMutable,...
                            autosar.ui.configuration.PackageString.DataElement)&&...
                            ~isInServiceInterface)||...
                            isa(cur.asMutable,...
                            autosar.ui.configuration.PackageString.ArgumentData)||...
                            isa(cur.asMutable,...
                            autosar.ui.configuration.PackageString.Triggers)

                            if~isempty(parentMCOS)
                                if isa(cur.asMutable,...
                                    autosar.ui.configuration.PackageString.ArgumentData)

                                    index=cur.containerM3I.Arguments.size();
                                    for argIndex=1:cur.containerM3I.Arguments.size()
                                        if cur.containerM3I.Arguments.at(argIndex)==cur.asMutable
                                            index=argIndex;
                                            break;
                                        end
                                    end
                                    if index==length(parentMCOS.Children)+1
                                        parentMCOS.addChild(autosar.ui.metamodel.M3ITerminalNode(...
                                        cur.asMutable,parentMCOS.Name));
                                    else
                                        parentMCOS.addChildAtIndex(autosar.ui.metamodel.M3ITerminalNode(...
                                        cur.asMutable,parentMCOS.Name),index);
                                    end
                                else
                                    parentMCOS.addChild(autosar.ui.metamodel.M3ITerminalNode(...
                                    cur.asMutable,parentMCOS.Name));
                                end
                            end
                        elseif isInServiceInterface&&...
                            (isa(cur.asMutable,'Simulink.metamodel.arplatform.interface.FlowData')||...
                            isa(cur.asMutable,'Simulink.metamodel.arplatform.interface.FieldData')||...
                            isa(cur.asMutable,autosar.ui.configuration.PackageString.SymbolProps))
                            parentMCOS.addChild(autosar.ui.metamodel.M3ITerminalNode(...
                            cur.asMutable,parentMCOS.Name));
                        elseif isInPersistencyKeyValueInterface&&...
                            isa(cur.asMutable,'Simulink.metamodel.arplatform.interface.PersistencyData')
                            parentMCOS.addChild(autosar.ui.metamodel.M3ITerminalNode(...
                            cur.asMutable,parentMCOS.Name));
                        end
                    end
                end

                ed=DAStudio.EventDispatcher;
                ed.broadcastEvent('HierarchyChangedEvent',this.ExplorerUI.getRoot());
            end
        end

        function observeChanged(this,changesReport)
            import autosar.ui.codemapping.PortCalibrationAttributeHandler;
            changed=changesReport.getChanged();
            for i=1:changed.size
                cur=changed.at(i);
                metaPkgPort='Simulink.metamodel.arplatform.port';
                if autosar.ui.utils.isaValidUIObject(cur)
                    old=changesReport.getOldState(cur);
                    autosar.ui.utils.updateEvents(this.ExplorerUI,cur,old);

                    if isa(cur,'Simulink.metamodel.arplatform.documentation.ImmutableLLongName')

                        cur=PortCalibrationAttributeHandler.getParentM3iObjFromLLongName(cur.asMutable);
                        old=PortCalibrationAttributeHandler.getParentM3iObjFromLLongName(old.asMutable);
                    end



                    if~strcmp(cur.Name,old.Name)
                        newQName=autosar.api.Utils.getQualifiedName(cur);
                        foundObjects=autosar.ui.metamodel.M3IToGUIMappingUtil.findMCOSObjInTree(...
                        this.ExplorerUI.TraversedRoot,old.asMutable,newQName);
                        if~isempty(foundObjects)
                            for k=1:length(foundObjects)
                                m3iObj=foundObjects(k).getM3iObject();
                                if~isempty(findprop(m3iObj,...
                                    autosar.ui.metamodel.PackageString.NamedProperty))
                                    foundObjects(k).Name=m3iObj.Name;
                                end
                            end
                        end
                    end
                    autosar.mm.observer.ObserverARDictionaryUI.updateEventData(this.ExplorerUI,cur,old);


                    ed=DAStudio.EventDispatcher;
                    imme=DAStudio.imExplorer(this.ExplorerUI);


                    selTreeNode=imme.getCurrentTreeNode();
                    if strcmp(selTreeNode.getDisplayLabel,...
                        autosar.ui.metamodel.PackageString.AtomicComponentsNodeName)||...
                        strcmp(selTreeNode.getDisplayLabel,...
                        autosar.ui.metamodel.PackageString.InterfacesNodeName)||...
                        strcmp(selTreeNode.getDisplayLabel,...
                        autosar.ui.metamodel.PackageString.ModeSwitchInterfacesNodeName)||...
                        strcmp(selTreeNode.getDisplayLabel,...
                        autosar.ui.metamodel.PackageString.ClientServerInterfacesNodeName)||...
                        strcmp(selTreeNode.getDisplayLabel,...
                        autosar.ui.metamodel.PackageString.operationsNode)||...
                        strcmp(selTreeNode.getDisplayLabel,...
                        autosar.ui.metamodel.PackageString.ParameterInterfacesNodeName)||...
                        strcmp(selTreeNode.getDisplayLabel,...
                        autosar.ui.metamodel.PackageString.TriggerInterfacesNodeName)||...
                        strcmp(selTreeNode.getDisplayLabel,...
                        autosar.ui.metamodel.PackageString.ServiceInterfacesNodeName)
                        ed.broadcastEvent('HierarchyChangedEvent',selTreeNode);
                    end
                    ed.broadcastEvent('ListChangedEvent',selTreeNode);
                    ed.broadcastEvent('PropertyChangedEvent',selTreeNode);
                    imme=DAStudio.imExplorer(this.ExplorerUI);
                    dlg=imme.getDialogHandle;
                    if~isempty(dlg)
                        ss=dlg.getWidgetInterface('AutosarComSpecSpreadsheet');
                        if~isempty(ss)
                            ss.update();
                        else
                            dlg.refresh();
                        end
                    end
                elseif isa(cur.asMutable,[metaPkgPort,'.DataReceiverNonqueuedPortComSpec'])||...
                    isa(cur.asMutable,[metaPkgPort,'.DataSenderNonqueuedPortComSpec'])||...
                    isa(cur.asMutable,[metaPkgPort,'.DataReceiverQueuedPortComSpec'])||...
                    isa(cur.asMutable,[metaPkgPort,'.DataSenderQueuedPortComSpec'])||...
                    isa(cur.asMutable,[metaPkgPort,'.NvDataReceiverPortComSpec'])||...
                    isa(cur.asMutable,[metaPkgPort,'.NvDataSenderPortComSpec'])

                    if~isempty(this.ExplorerUI.getDialog)



                        stack=dbstack;
                        if isempty(stack)||...
                            (~strcmp(stack(end).name,'SpreadsheetRow.setPropValue')&&...
                            ~strcmp(stack(end).name,'getDlgSchemaElementsView'))
                            this.ExplorerUI.getDialog.refresh();
                        end
                    end
                elseif isa(cur.asMutable,[metaPkgPort,'.DataReceiverPortInfo'])||...
                    isa(cur.asMutable,[metaPkgPort,'.SenderPortInfo'])

                    imme=DAStudio.imExplorer(this.ExplorerUI);
                    dlg=imme.getDialogHandle;
                    if~isempty(dlg)
                        dlg.refresh();
                    end
                end
            end
        end
    end

    methods(Static,Access=private)

        function updateEventData(explorer,cur,old)
            if~isempty(findprop(explorer,'EventData'))&&cur.isvalid&&...
                isa(cur.asMutable,'Simulink.metamodel.arplatform.behavior.Event')
                autosar.ui.utils.buildOrUpdateEventData(explorer,cur.asMutable,old);
                imme=DAStudio.imExplorer(explorer);
                dlg=imme.getDialogHandle;
                if~isempty(dlg)
                    dlg.refresh();
                end
            end
        end

        function deleteObjectFullHierachy(node)


            hChildren=[node.Children,node.HierarchicalChildren];
            for k=1:length(hChildren)
                if hChildren(k).isvalid
                    hChildren(k).delete;
                end
            end
            node.delete;
        end
    end
end



