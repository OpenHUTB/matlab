function result=isDataTypeFracLengthOnlyInherited(h,blkObj,pathItem)





    [~,~,~,specifiedDTStr]=h.getDataTypeInfoForPathItem(blkObj,pathItem);
    result=h.isDataTypeStrFracLengthOnlyInherited(specifiedDTStr);


