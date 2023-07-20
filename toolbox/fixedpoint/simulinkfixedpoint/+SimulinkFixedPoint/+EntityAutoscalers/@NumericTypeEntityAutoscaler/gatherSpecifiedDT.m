function[DTContInfo,comments,paramNames]=gatherSpecifiedDT(~,dataObjectWrapper,~)









    comments={};
    paramNames.modeStr='';
    paramNames.wlStr='';
    paramNames.flStr='';

    DTContInfo=SimulinkFixedPoint.DTContainerInfo(dataObjectWrapper.Object.tostring,dataObjectWrapper.Context);
end


