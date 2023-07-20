function result=setDesignMinMaxAndSpecifiedDT(~,EA,result)

    uniqueID=result.UniqueIdentifier;
    pathItem=uniqueID.getElementName;
    obj=uniqueID.getObject;

    [dMin,dMax]=EA.gatherDesignMinMax(obj,pathItem);
    result.setDesignRange(dMin,dMax);

    [DTContInfo,comments]=EA.gatherSpecifiedDT(obj,pathItem);
    specifiedDT=DTContInfo.evaluatedDTString;
    result.setSpecifiedDataType(specifiedDT);
    result.setIsLocked(false);
    result.addComment(comments);
    result.SpecifiedDTContainerInfo=DTContInfo;
end