function addElementToSwAddrMethodsTab(cbinfo)




    destinationTabId='SwAddrMethodsTab';
    swAddrMethodEntryType='SwAddrMethod';
    sl.interface.dictionaryApp.toolstrip.callbacks.changeTab(destinationTabId,cbinfo);

    contextObj=cbinfo.Context.Object;
    guiObj=contextObj.GuiObj;
    guiObj.addElement(swAddrMethodEntryType);
end


