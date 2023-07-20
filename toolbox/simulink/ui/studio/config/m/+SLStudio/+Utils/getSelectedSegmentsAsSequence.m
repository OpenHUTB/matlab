function resultSequence=getSelectedSegmentsAsSequence(cbinfo)








    resultSequence=cbinfo.studio.App.getActiveEditor.getDocument.getSelectionObject.getElementsByClass(SLM3I.Segment.MetaClass);
end
