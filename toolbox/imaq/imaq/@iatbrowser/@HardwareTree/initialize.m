function initialize(this)
    this.rootNode=iatbrowser.RootNode('Image Acquisition Toolbox');

    this.refreshing=false;

    this.abortNodeSelectionChange=false;
    localConstructJavaTreeStructure(this.rootNode,this.rootNode.JavaPeer);
    localAddDeviceNodeListeners(this.rootNode);
    javaTreeModel=javaObjectEDT('javax.swing.tree.DefaultTreeModel',this.rootNode.JavaPeer);
    javaTree=javaObjectEDT('com.mathworks.mwswing.MJTree',javaTreeModel);
    javaTree.setName('hardwareTree');
    javaTree.setCellRenderer(javaObjectEDT('com.mathworks.toolbox.testmeas.desktopbrowser.BrowserTreeCellRenderer'));

    toolTipManager=javaMethodEDT('sharedInstance','javax.swing.ToolTipManager');
    javaObjectEDT(toolTipManager);
    toolTipManager.registerComponent(javaTree);

    this.javaTreePeer=handle(javaTree);
    connect(this,this.javaTreePeer,'down');

    javaPeer=com.mathworks.toolbox.imaq.browser.TreeViewPanel.getInstance();
    javaPeer.setTreeView(javaTree);
    javaPeer.setName('hardwareTreePanel');
    this.javaPeer=handle(javaPeer);
    connect(this,this.javaPeer,'down');


    nodeSelectedCallbackObject=handle(this.javaPeer.getNodeSelectedCallback);
    this.treeNodeSelectedListener=handle.listener(nodeSelectedCallbackObject,'delayed',@treeNodeSelectedCallback);
    this.treeNodeSelectedListener.RecursionLimit=1;

    desk=iatbrowser.getDesktop();

    desk.disableExport();

    exportHWConfigCallback=handle(desk.getExportHWConfigCallback());
    this.exportHWConfigListener=handle.listener(exportHWConfigCallback,'delayed',@handleExportHWConfig);

    exportSelectedHWConfigCallback=handle(javaPeer.getExportHWConfigCallback());
    this.exportSelectedHWConfigListener=handle.listener(exportSelectedHWConfigCallback,'delayed',@handleExportSelectedHWConfig);

    saveConfigCallback=handle(desk.getSaveConfigCallback());
    this.saveConfigListener=handle.listener(saveConfigCallback,'delayed',@handleSaveConfig);

    openConfigCallback=handle(desk.getOpenConfigCallback());
    this.openConfigListener=handle.listener(openConfigCallback,'delayed',@handleOpenConfig);

    preferencesCallback=handle(desk.getPreferencesCallback());
    this.preferencesListener=handle.listener(preferencesCallback,'delayed',@handlePreferences);

    exportMFileCallback=handle(desk.getExportMFileCallback());
    this.exportMFileListener=handle.listener(exportMFileCallback,'delayed',@handleExportMFile);

    addlistener(iatbrowser.Browser().messageBus,'DiskParametersUpdated',@handleDiskParametersUpdated);

    function handleDiskParametersUpdated(obj,theEvent)%#ok<INUSL>
        this.abortNodeSelectionChange=~theEvent.Status;
    end
    function handleExportHWConfig(obj,theEvent)
        this.handleExportHWConfig(obj,theEvent,'OTHER');
    end

    function handleExportSelectedHWConfig(obj,theEvent)
        this.handleExportHWConfig(obj,theEvent,'SELECTED');
    end

    function handleExportMFile(obj,theEvent)
        this.handleExportHWConfig(obj,theEvent,'CODEFILE');
    end

    function handleSaveConfig(obj,theEvent)
        this.handleSaveConfig(obj,theEvent);
    end

    function handleOpenConfig(obj,theEvent)
        this.handleOpenConfig(obj,theEvent);
    end

    function handlePreferences(~,~)
        preferences('Image Acquisition Toolbox');
    end

    function localConstructJavaTreeStructure(topNode,javaPeer)

        children=topNode.getChildren();
        for ii=1:length(children)
            currentNode=children{ii};

            javaPeer.add(currentNode.JavaPeer);
            localConstructJavaTreeStructure(currentNode,currentNode.JavaPeer);
        end
    end

    function localAddDeviceNodeListeners(topNode)



        children=topNode.getChildren();
        for ii=1:length(children)
            currentNode=children{ii};

            if isa(currentNode,'iatbrowser.DeviceNode')
                if isempty(this.formatNodeAddedListener)
                    this.formatNodeAddedListener=event.listener(currentNode,'formatNodeAdded',@formatNodeAddedCallback);
                else
                    this.formatNodeAddedListener(end+1)=event.listener(currentNode,'formatNodeAdded',@formatNodeAddedCallback);
                end
            end

            localAddDeviceNodeListeners(currentNode);
        end
    end

    function treeNodeSelectedCallback(obj,eventdata)
        this.hardwareTreeNodeSelectedCallback(obj,eventdata)
    end

    function formatNodeAddedCallback(obj,eventdata)
        this.hardwareFormatNodeAddedCallback(obj,eventdata)
    end
end
