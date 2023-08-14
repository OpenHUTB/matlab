function resultArray=getSelectedNoteAnnotationHandles(cbinfo)




    resultArray=SLStudio.Utils.partitionSelectionHandlesOf(cbinfo,'notes');



    resultArray=find_system(resultArray,'SearchDepth',0,'annotationType','note_annotation');

end
