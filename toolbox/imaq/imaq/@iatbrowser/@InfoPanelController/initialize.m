function initialize(this,rootNode)
    this.javaPeer=handle(com.mathworks.toolbox.imaq.browser.HardwareInfoPanel.getInstance());
    connect(this,this.javaPeer,'down');

    browser=iatbrowser.Browser;
    this.sourcePropertyChangedListener=event.listener(browser.messageBus,...
    'SourcePropertyChanged',@(obj,event)handleSourcePropertyChanged());

    this.videoinputPropertyChangedListener=event.listener(browser.messageBus,...
    'VideoinputPropertyChanged',@(obj,event)handleVideoinputPropertyChanged());

    addlisteners(rootNode);

    function handleSourcePropertyChanged()
        browser=iatbrowser.Browser;
        this.updateFormatNodeInfoDisplay();
    end

    function handleVideoinputPropertyChanged()
        browser=iatbrowser.Browser;
        this.updateFormatNodeInfoDisplay();
    end

    function addlisteners(node)
        [theEvent,nodeClass]=iatbrowser.generateNodeSelectedEventName(node);
        nodeHandler=eval(['@handle',nodeClass,'Selected']);
        if isempty(this.treeNodeListeners)
            this.treeNodeListeners=event.listener(node,theEvent,nodeHandler);
        else
            this.treeNodeListeners(end+1)=event.listener(node,theEvent,nodeHandler);
        end


        if isa(node,'iatbrowser.DeviceNode')
            this.treeNodeListeners(end+1)=event.listener(node,'formatNodeAdded',@handleFormatNodeAdded);
        end

        children=node.getChildren();
        for ii=1:length(children)
            curchild=children{ii};
            addlisteners(curchild);
        end
    end

    function handleRootNodeSelected(node,theEvent)%#ok<INUSL,DEFNU>
        formatter=iatbrowser.RootNodeInfoDisplay(theEvent.NewNode);
        this.javaPeer.updateLabelText(formatter.toString());
    end

    function handleDeviceNodeSelected(node,theEvent)%#ok<INUSL,DEFNU>
        formatter=iatbrowser.DeviceNodeInfoDisplay(theEvent.NewNode);
        this.javaPeer.updateLabelText(formatter.toString());
    end

    function handleFormatNodeSelected(node,theEvent)%#ok<INUSL>
        formatter=iatbrowser.FormatNodeInfoDisplay(theEvent.NewNode);
        this.javaPeer.updateLabelText(formatter.toString());
    end

    function handleSelectCameraFileNodeSelected(node,theEvent)%#ok<INUSD,DEFNU>

    end

    function handleFormatNodeAdded(node,theEvent)%#ok<INUSL>
        this.treeNodeListeners(end+1)=event.listener(theEvent.FormatNode,'formatNodeSelected',@handleFormatNodeSelected);
    end
end