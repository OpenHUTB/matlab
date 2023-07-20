function[DTConInfo,comments,paramNames]=gatherSpecifiedDT(h,blkObj,pathItem)












    if strcmpi(pathItem,'Denominator coefficients')
        paramNames.wlStr='secondCoeffWordLength';
        paramNames.flStr='secondCoeffFracLength';
        paramNames.modeStr='secondCoeffMode';
        specifiedDTStr=sprintf('fixdt(1, %s, %s)',blkObj.(paramNames.wlStr),blkObj.(paramNames.flStr));
        DTConInfo=SimulinkFixedPoint.DTContainerInfo(specifiedDTStr,blkObj);
        comments={};
    else

        [DTConInfo,comments,paramNames]=gatherSpecifiedDT@dvautoscaler.DspEntityAutoscaler(h,blkObj,pathItem);
    end
end


