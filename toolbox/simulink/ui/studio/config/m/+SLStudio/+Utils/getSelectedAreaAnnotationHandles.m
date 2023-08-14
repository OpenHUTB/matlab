function resultArray=getSelectedAreaAnnotationHandles(cbinfo)




    resultArray=SLStudio.Utils.partitionSelectionHandlesOf(cbinfo,'notes');


    resultArray=find_system(resultArray,'SearchDepth',0,'annotationType','area_annotation');
    resultArray=reshape(resultArray,1,[]);
end
