function res=selectionHasBlocks(cbinfo)




    res=cbinfo.studio.App.getActiveEditor.getDocument.getSelectionObject.hasType(SLM3I.Block.MetaClass);
end
