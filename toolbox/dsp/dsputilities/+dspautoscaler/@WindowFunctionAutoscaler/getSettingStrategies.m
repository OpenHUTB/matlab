function pv=getSettingStrategies(h,blkObj,pathItem,proposedDT)




    pv={};

    proposedDTNumType=SimulinkFixedPoint.DTContainerInfo(proposedDT,[]);

    if strcmpi(blkObj.winmode,'Generate window')
        if proposedDTNumType.isFloat
            [blkObjToBeSet,paramNameToBeSet]=h.getActualToSetInfo(blkObj,0,'dataType');
            pv{1,1}={'FullDataTypeStrategy',blkObjToBeSet.getFullName,paramNameToBeSet};

        elseif proposedDTNumType.isFixed

            [blkObjToBeSetFl,paramNameToBeSetFl]=h.getActualToSetInfo(blkObj,0,'numFracBits');


            [blkObjToBeSetWl,paramNameToBeSetWl]=h.getActualToSetInfo(blkObj,0,'wordLen');


            blockPathWL=blkObjToBeSetWl.getFullName;
            pv{1,1}={'SignednessStrategy',blockPathWL,'isSigned'};

            blockPathFL=blkObjToBeSetFl.getFullName;
            pv{end+1,1}={'FractionLengthStrategy',blockPathFL,paramNameToBeSetFl};
            pv{end+1,1}={'WordLengthStrategy',blockPathWL,paramNameToBeSetWl};

            blkName=blkObj.getFullName;
            pv{end+1,1}={'GenericPropertyStrategy',blkName,'dataType','Fixed-point'};
            pv{end+1,1}={'GenericPropertyStrategy',blkName,'fracBitsMode','User-defined'};
        end

    else
        [~,~,~,~,flDlgStr,modeDlgStr,wlDlgStr]=h.getDataTypeInfoForPathItem(blkObj,pathItem);


        [blkObjToBeSetFl,paramNameToBeSetFl]=h.getActualToSetInfo(blkObj,0,flDlgStr);


        [blkObjToBeSetWl,paramNameToBeSetWl]=h.getActualToSetInfo(blkObj,0,wlDlgStr);
        blockPathFL=blkObjToBeSetFl.getFullName;
        pv{end+1,1}={'FractionLengthStrategy',blockPathFL,paramNameToBeSetFl};
        blockPathWL=blkObjToBeSetWl.getFullName;
        pv{end+1,1}={'WordLengthStrategy',blockPathWL,paramNameToBeSetWl};


        blockPath=blkObj.getFullName;
        pv{end+1,1}={'GenericPropertyStrategy',blockPath,modeDlgStr,'Binary point scaling'};
    end
end



