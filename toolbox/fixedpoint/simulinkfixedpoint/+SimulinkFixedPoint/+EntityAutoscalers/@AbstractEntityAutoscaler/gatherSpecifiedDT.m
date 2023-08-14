function[DTConInfo,comments,paramNames]=gatherSpecifiedDT(~,~,~)








    paramNames.modeStr='';
    paramNames.wlStr='';
    paramNames.flStr='';
    specifiedDTStr='';
    DTConInfo=SimulinkFixedPoint.DTContainerInfo(specifiedDTStr,[]);
    comments={};

end


