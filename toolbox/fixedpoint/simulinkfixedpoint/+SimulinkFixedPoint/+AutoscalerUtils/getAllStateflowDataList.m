function[activeSFDataList,inactiveSFDataList]=getAllStateflowDataList(bd)





    inactiveSFDataList=[];

    activeSFDataList=SimulinkFixedPoint.AutoscalerUtils.getStateflowDataListForVariant(bd,'ActiveVariants','off');
    if isempty(activeSFDataList);return;end;


    allSFDataList=SimulinkFixedPoint.AutoscalerUtils.getStateflowDataListForVariant(bd,'AllVariants','on');


    inactiveSFDataList=setdiff(allSFDataList,activeSFDataList);
end

