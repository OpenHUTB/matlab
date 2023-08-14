function addTreeNodeListeners(this,node)








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
        this.addTreeNodeListeners(curchild);
    end

    function handleRootNodeSelected(node,theEvent)%#ok<INUSD,INUSD,DEFNU>
        prevPanelButtonPanel=java(this.prevPanel.prevPanelButtonPanel);
        prevPanelButtonPanel.disableButtons();


        this.prevPanel.clearWindow(class(node),iatbrowser.getResourceString('RES_DESKTOP','PreviewPanel.SelectFormat'));

        if this.isPreviewing()
            this.stopPreview(true);
        end

        this.prevPanel.clearFrames();
        pfig=get(this.prevPanel,'fig');
        set(pfig,'Name',imaqgate('privateGetJavaResourceString',...
        'com.mathworks.toolbox.imaq.browser.resources.RES_DESKTOP',...
        'PreviewPanel.SelectFormat'));
        set(this.prevPanel.statLabel,'String','');
        drawnow;
    end

    function handleDeviceNodeSelected(node,theEvent)%#ok<INUSD,INUSD,DEFNU>
        prevPanelButtonPanel=java(this.prevPanel.prevPanelButtonPanel);
        prevPanelButtonPanel.disableButtons();

        this.prevPanel.clearWindow(class(node),iatbrowser.getResourceString('RES_DESKTOP','PreviewPanel.SelectFormat'));

        this.prevPanel.clearFrames();
        pfig=get(this.prevPanel,'fig');
        set(pfig,'Name',imaqgate('privateGetJavaResourceString',...
        'com.mathworks.toolbox.imaq.browser.resources.RES_DESKTOP',...
        'PreviewPanel.SelectFormat'));
        set(this.prevPanel.statLabel,'String','');

        drawnow;
    end

    function handleSelectCameraFileNodeSelected(node,theEvent)%#ok<INUSD,INUSD,DEFNU>
    end

    function handleFormatNodeAdded(node,theEvent)%#ok<INUSL>
        this.treeNodeListeners(end+1)=event.listener(theEvent.FormatNode,'formatNodeSelected',@handleFormatNodeSelected);
    end

    function handleFormatNodeSelected(node,theEvent)
        formatNode=theEvent.NewNode;
        deviceName=formatNode.Parent.DisplayName;
        formatName=formatNode.DisplayName;

        pfig=get(this.prevPanel,'fig');
        set(pfig,'Name',[deviceName,': ',formatName]);

        this.prevPanel.clearFrames;

        set(this.prevPanel.statLabel,'String',...
        imaqgate('privateGetJavaResourceString',...
        'com.mathworks.toolbox.imaq.browser.resources.RES_DESKTOP',...
        'PreviewPanel.waiting'));

        this.prevPanel.hideRuntimeLabels();



        prevPanelButtonPanel=java(this.prevPanel.prevPanelButtonPanel);
        if this.restartPreview
            this.startPreview(false);
            prevPanelButtonPanel.setButtonsForPreviewStartOrStop(true);
        else
            this.prevPanel.clearWindow(class(node));
            prevPanelButtonPanel.setButtonsForStart();
        end
    end
end

