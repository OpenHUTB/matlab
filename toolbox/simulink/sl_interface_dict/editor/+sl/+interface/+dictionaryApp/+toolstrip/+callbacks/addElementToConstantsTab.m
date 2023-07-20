function addElementToConstantsTab(cbinfo)




    destinationTabId='ConstantsTab';
    constantEntryType='Constant';
    sl.interface.dictionaryApp.toolstrip.callbacks.changeTab(destinationTabId,cbinfo);

    contextObj=cbinfo.Context.Object;
    guiObj=contextObj.GuiObj;
    guiObj.addElement(constantEntryType);
end
