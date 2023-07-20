function res=selectionHasSegments(cbinfo)




    res=cbinfo.studio.App.getActiveEditor.getDocument.getSelectionObject.hasType(SLM3I.Segment.MetaClass);
end
