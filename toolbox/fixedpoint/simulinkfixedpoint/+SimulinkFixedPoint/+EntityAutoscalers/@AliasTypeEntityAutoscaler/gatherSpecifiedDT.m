function[DTContInfo,comments,paramNames]=gatherSpecifiedDT(~,dataObjectWrapper,~)









    comments={};
    paramNames.modeStr='';
    paramNames.wlStr='';
    paramNames.flStr='';

    DTContInfo=SimulinkFixedPoint.DTContainerInfo(dataObjectWrapper.Object.BaseType,dataObjectWrapper.Context);
end


