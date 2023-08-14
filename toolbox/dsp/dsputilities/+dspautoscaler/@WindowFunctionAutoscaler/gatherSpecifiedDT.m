function[DTConInfo,comments,paramNames]=gatherSpecifiedDT(h,blkObj,pathItem)




    [~,~,~,specifiedDTStr,flDlgStr,...
    modeDlgStr,wlDlgStr]=getDataTypeInfoForPathItem(h,blkObj,pathItem);

    comments={};

    paramNames.wlStr=wlDlgStr;
    paramNames.flStr=flDlgStr;
    paramNames.modeStr=modeDlgStr;

    DTConInfo=SimulinkFixedPoint.DTContainerInfo(specifiedDTStr,blkObj);
end


