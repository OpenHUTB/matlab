function handleSelectCameraFileCallback(this,obj,event)%#ok<INUSD,INUSD>





    browser=iatbrowser.Browser;
    deviceNode=browser.treePanel.currentNode;

    iatbrowser.handleSelectCameraFileDialog(deviceNode,deviceNode);