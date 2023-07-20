function busObjEleID=hGetLeafBusObjElementID(h,busElementPath,busObjHandle,busObjHandleMap)





























    busObjEleID=[];
    hierLevels=regexp(busElementPath,'\.','split');

    L=length(hierLevels);

    if~(L>1)
        return;
    end

    for iLevel=2:L-1

        nonLeafElementName=regexprep(hierLevels{iLevel},'\(.+\)$','');
        eleIndex=busObjHandle.nonLeafChildName2IndexMap(nonLeafElementName);
        busObjName=h.hCleanBusName(busObjHandle.specifiedDTs{eleIndex});
        if~busObjHandleMap.isKey(busObjName)
            DAStudio.error('SimulinkFixedPoint:autoscaling:UnRecognizedBusEleName',busElementPath);
        end
        busObjHandle=busObjHandleMap.getDataByKey(busObjName);

    end

    busObjEleID.blkObj=busObjHandle;
    busObjEleID.pathItem=regexprep(hierLevels{L},'\(.+\)$','');


