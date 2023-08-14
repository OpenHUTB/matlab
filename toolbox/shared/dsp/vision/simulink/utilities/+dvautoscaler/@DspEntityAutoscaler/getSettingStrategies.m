function pv=getSettingStrategies(h,blkObj,pathItem,proposedDT)




    pv={};




    [~,~,paramNames]=gatherSpecifiedDT(h,blkObj,pathItem);

    flDlgStr=paramNames.flStr;
    modeDlgStr=paramNames.modeStr;
    wlDlgStr=paramNames.wlStr;

    proposedDTNumType=SimulinkFixedPoint.DTContainerInfo(proposedDT,[]);

    if proposedDTNumType.isFloat
        pv{1,1}={'FullDataTypeStrategy',blkObj.getFullName,modeDlgStr};


    elseif proposedDTNumType.isFixed

        [blkObjToBeSetFl,paramNameToBeSetFl]=h.getActualToSetInfo(blkObj,0,flDlgStr);


        [blkObjToBeSetWl,paramNameToBeSetWl]=h.getActualToSetInfo(blkObj,0,wlDlgStr);


        blockPathFL=blkObjToBeSetFl.getFullName;
        pv{1,1}={'FractionLengthStrategy',blockPathFL,paramNameToBeSetFl};

        blockPathWL=blkObjToBeSetWl.getFullName;
        pv{end+1,1}={'WordLengthStrategy',blockPathWL,paramNameToBeSetWl};


        pv{end+1,1}={'GenericPropertyStrategy',blockPathFL,modeDlgStr,'Binary point scaling'};

    end
end


