function setResultProperties(~,result,info)





    result.setSpecifiedDataType(info.specDTConInfo.evaluatedDTString);





    result.SpecifiedDTContainerInfo=info.specDTConInfo;


    result.setIsLocked(SimulinkFixedPoint.AutoscalerUtils.IsLocked(result.UniqueIdentifier.getObject));


    result.setDesignRange(info.dMin,info.dMax);



    result.computeIfInheritanceReplaceable;


    result.updateVisibility;

end