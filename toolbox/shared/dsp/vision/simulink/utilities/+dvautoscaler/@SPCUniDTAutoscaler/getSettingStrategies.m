function pv=getSettingStrategies(h,blkObj,pathItem,~)




    pv={};
    udtMaskParamStr=strcat(getSPCUniDTParamPrefixStr(h,blkObj,pathItem),'DataTypeStr');

    if h.isUnderMaskWorkspace(blkObj)||SimulinkFixedPoint.TracingUtils.IsUnderLibraryLink(blkObj)
        levelsUpToTopMask=checkMaskLinkLevels(h,blkObj);
        blkObjToBeSet=getActualToSetInfo(h,blkObj,levelsUpToTopMask,udtMaskParamStr);
    else
        blkObjToBeSet=blkObj;
    end

    isAutoSignedness=areOnlyAutoSignednessFIXDTTypesAllowed(h,blkObjToBeSet,pathItem);
    blockPath=blkObjToBeSet.getFullName;
    if isAutoSignedness
        pv{1,1}={'AutoSignednessDataTypeStrategy',blockPath,udtMaskParamStr};
    else
        pv{1,1}={'FullDataTypeStrategy',blockPath,udtMaskParamStr};
    end

end


