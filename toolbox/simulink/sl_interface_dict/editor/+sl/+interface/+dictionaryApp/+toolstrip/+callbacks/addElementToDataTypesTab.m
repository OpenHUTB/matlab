function addElementToDataTypesTab(entryType,cbinfo)




    destinationTabId='DataTypesTab';
    sl.interface.dictionaryApp.toolstrip.callbacks.changeTab(destinationTabId,cbinfo);

    contextObj=cbinfo.Context.Object;
    guiObj=contextObj.GuiObj;
    guiObj.addElement(entryType);
end
