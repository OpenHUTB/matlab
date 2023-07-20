function result=isDataTypeFullyInherited(h,blkObj,pathItem)





    [~,~,~,specifiedDTStr]=h.getDataTypeInfoForPathItem(blkObj,pathItem);
    result=h.isDataTypeStrFullyInherited(specifiedDTStr);


