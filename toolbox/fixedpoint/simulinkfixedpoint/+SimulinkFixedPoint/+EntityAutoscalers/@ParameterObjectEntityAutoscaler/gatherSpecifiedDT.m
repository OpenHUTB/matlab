function[DTConInfo,Comments,paramNames]=gatherSpecifiedDT(~,dataObjectWrapper,~)




    specifiedDTStr=dataObjectWrapper.Object.DataType;

    Comments={};
    paramNames.modeStr='';
    paramNames.wlStr='';
    paramNames.flStr='';

    DTConInfo=SimulinkFixedPoint.DTContainerInfo(specifiedDTStr,dataObjectWrapper.Context);

end

