function[DTConInfo,Comments,paramNames]=gatherSpecifiedDT(~,dataObjectWrapper,~)




    paramNames.modeStr='DataType';
    paramNames.wlStr='';
    paramNames.flStr='';
    specifiedDTStr=dataObjectWrapper.Object.DataType;
    Comments={};

    DTConInfo=SimulinkFixedPoint.DTContainerInfo(specifiedDTStr,dataObjectWrapper.Context);
end