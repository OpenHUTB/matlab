function res=selectionHasConnectors(cbinfo)




    res=cbinfo.studio.App.getActiveEditor.getDocument.getSelectionObject.hasType(SLM3I.Connector.MetaClass);
end
