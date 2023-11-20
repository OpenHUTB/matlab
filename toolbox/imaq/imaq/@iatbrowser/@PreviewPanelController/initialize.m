function initialize(this,rootNode)

    desk=iatbrowser.getDesktop();

    this.stopping=false;
    this.restartPreview=false;
    this.prevPanel=iatbrowser.PreviewPanel;
    this.diskLoggingValidState=true;
    connect(this,this.prevPanel,'down');

    browser=iatbrowser.Browser;

    pfig=get(this.prevPanel,'fig');
    set(pfig,'Name',imaqgate('privateGetJavaResourceString',...
    'com.mathworks.toolbox.imaq.browser.resources.RES_DESKTOP',...
    'PreviewPanel.SelectFormat'));


    [lastWarnMsg,lastWarnId]=lastwarn;
    oldstate=warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');

    jf=matlab.ui.internal.JavaMigrationTools.suppressedJavaFrame(pfig);
    warning(oldstate.state,'MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');

    lastwarn(lastWarnMsg,lastWarnId);


    jf.setDesktopGroup(desk,'Preview');

    set(pfig,'windowstyle','docked');
    this.prevPanel.setVisible(true);
    drawnow;
    clientTitles=desk.getClientTitles();
    for ii=1:length(clientTitles)
        if clientTitles(ii).contains(java.lang.String(imaqgate('privateGetJavaResourceString',...
            'com.mathworks.toolbox.imaq.browser.resources.RES_DESKTOP',...
            'PreviewPanel.SelectFormat')))
            pfigClient=desk.getClient(clientTitles(ii));
            break;
        end
    end
    pfigClient.putClientProperty(com.mathworks.widgets.desk.DTClientProperty.PERMIT_USER_CLOSE,java.lang.Boolean.FALSE);
    pfigClient.putClientProperty(com.mathworks.widgets.desk.DTClientProperty.PERMIT_USER_UNDOCK,java.lang.Boolean.FALSE);
    drawnow;


    desk.setupHelpListeners();
    drawnow;

    addPrevPanelWidgetListeners;

    this.treeNodeListeners=[];
    this.addTreeNodeListeners(rootNode);

    this.acquisitionParameterListeners=[];
    addAcquisitionParameterListeners;

    browser.treePanel.refreshing=false;
    drawnow;

    function addPrevPanelWidgetListeners
        prevPanelButtonPanel=java(this.prevPanel.prevPanelButtonPanel);
        exportCallback=handle(prevPanelButtonPanel.getExportCallback());
        this.widgetListeners=handle.listener(exportCallback,'delayed',@handleExport);

        this.widgetListeners.RecursionLimit=1000;

        startAcqCallback=handle(prevPanelButtonPanel.getStartAcqCallback());
        this.startAcquisitionBtnListener=handle.listener(startAcqCallback,'delayed',@handleStartAcqClicked);

        stopAcqCallback=handle(prevPanelButtonPanel.getStopAcqCallback());
        this.widgetListeners(end+1)=handle.listener(stopAcqCallback,'delayed',@handleStopAcqClicked);

        startPrevCallback=handle(prevPanelButtonPanel.getStartPrevCallback());
        this.widgetListeners(end+1)=handle.listener(startPrevCallback,'delayed',@handleStartPrevClicked);

        stopPrevCallback=handle(prevPanelButtonPanel.getStopPrevCallback());
        this.widgetListeners(end+1)=handle.listener(stopPrevCallback,'delayed',@handleStopPrevClicked);

        trigCallback=handle(prevPanelButtonPanel.getTrigCallback());
        this.widgetListeners(end+1)=handle.listener(trigCallback,'delayed',@handleTriggerClicked);
    end

    function addAcquisitionParameterListeners
        browser=iatbrowser.Browser;

        this.acquisitionParameterListeners=event.listener(browser.messageBus,...
        'DiskParametersUpdated',@handleDiskParametersUpdated);
    end

    function handleExport(obj,event)
        this.handleExportCallback(obj,event);
    end

    function handleStartAcqClicked(obj,event)
        this.handleStartAcqClickedCallback(obj,event);
    end

    function handleStopAcqClicked(obj,event)
        this.handleStopAcqClickedCallback(obj,event);
    end

    function handleStartPrevClicked(obj,event)
        this.handleStartPrevClickedCallback(obj,event);
    end

    function handleStopPrevClicked(obj,event)
        this.handleStopPrevClickedCallback(obj,event);
    end

    function handleTriggerClicked(obj,event)
        this.handleTriggerClickedCallback(obj,event);
    end

    function handleDiskParametersUpdated(obj,event)
        this.diskLoggingValidState=event.Status;
        if(ishandle(this.prevPanel.prevPanelButtonPanel))
            prevPanelButtonPanel=java(this.prevPanel.prevPanelButtonPanel);
            prevPanelButtonPanel.setStartButtonEnabled(event.Status);
        end
    end
end
