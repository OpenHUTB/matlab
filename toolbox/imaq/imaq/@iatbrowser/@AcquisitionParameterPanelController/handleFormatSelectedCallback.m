function handleFormatSelectedCallback(~,~,event)


    browser=iatbrowser.Browser;
    deviceNode=browser.treePanel.currentNode;
    formatNode=deviceNode.getNode(char(event.javaEvent.selectedFormat));

    browser.treePanel.selectNode(formatNode,true);
    drawnow