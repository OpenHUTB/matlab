function[DTConInfo,Comments,paramNames]=gatherSpecifiedDT(~,blkObj,pathItem)




    paramNames.modeStr='';
    paramNames.wlStr='';
    paramNames.flStr='';
    idx=blkObj.leafChildName2IndexMap(pathItem);
    DTStr=blkObj.specifiedDTs{idx};

    Comments={};

    specifiedDTStr=DTStr;

    context=blkObj.busObjContextModel;

    DTConInfo=SimulinkFixedPoint.DTContainerInfo(specifiedDTStr,context);

end
