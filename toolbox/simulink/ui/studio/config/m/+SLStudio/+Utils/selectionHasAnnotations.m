function res=selectionHasAnnotations(cbinfo)




    res=cbinfo.studio.App.getActiveEditor.getDocument.getSelectionObject.hasType(SLM3I.Annotation.MetaClass);
end
