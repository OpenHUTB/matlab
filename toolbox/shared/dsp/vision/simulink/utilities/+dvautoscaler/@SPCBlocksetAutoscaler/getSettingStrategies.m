function pv=getSettingStrategies(h,blkObj,pathItem,proposedDT)




    pv={};

    [~,~,~,~,...
    flDlgStr,modeDlgStr,wlDlgStr]=h.getDataTypeInfoForPathItem(blkObj,pathItem);

    levelsUpToTopMask=0;
    if h.isUnderMaskWorkspace(blkObj)||SimulinkFixedPoint.TracingUtils.IsUnderLibraryLink(blkObj)
        levelsUpToTopMask=h.checkMaskLinkLevels(blkObj);
    end

    proposedDTNumType=SimulinkFixedPoint.DTContainerInfo(proposedDT,[]);

    if proposedDTNumType.isFloat
        [blkObjToBeSet,paramNameToBeSet]=h.getActualToSetInfo(blkObj,levelsUpToTopMask,modeDlgStr);
        pv{1,1}={'FullDataTypeStrategy',blkObjToBeSet.getFullName,paramNameToBeSet};


    elseif proposedDTNumType.isFixed

        [blkObjToBeSetFl,paramNameToBeSetFl]=h.getActualToSetInfo(blkObj,levelsUpToTopMask,flDlgStr);


        [blkObjToBeSetWl,paramNameToBeSetWl]=h.getActualToSetInfo(blkObj,levelsUpToTopMask,wlDlgStr);

        allowDtSet=blkObj.getPropAllowedValues(modeDlgStr);


        blockPathFL=blkObjToBeSetFl.getFullName;
        pv{1,1}={'FractionLengthStrategy',blockPathFL,paramNameToBeSetFl};

        blockPathWL=blkObjToBeSetWl.getFullName;
        pv{end+1,1}={'WordLengthStrategy',blockPathWL,paramNameToBeSetWl};

        if any(strcmpi('Binary point scaling',allowDtSet))

            pv{end+1,1}={'GenericPropertyStrategy',blockPathFL,modeDlgStr,'Binary point scaling'};

        elseif any(strcmpi('Fixed-point',allowDtSet))

            blockPath=blkObj.getFullName;
            pv{end+1,1}={'GenericPropertyStrategy',blockPath,modeDlgStr,'Fixed-point'};

        end

    end

end

