classdef AbstractEntityAutoscaler<handle





    methods
        comments=checkComments(ea,blkObj,pathItem)
        associateRecords=gatherAssociatedParam(h,blkObj)
        [hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj)
        [min,max]=gatherDesignMinMax(h,blkObj,pathItem)
        sharedList=gatherSharedDT(h,blkObj)
        sharedLists=gatherSharedDTWithBusObj(h,blkObj,pathItem,busObjHandleMap)
        [DTConInfo,comments,paramNames]=gatherSpecifiedDT(h,blkObj,pathItem)
        actualSrcBlkObj=getActualSrcBlkObj(h,blkObj)
        srcSigIDs=getAllSourceSignal(h,portObj,includeEmpty)
        busObjHandleAndICList=getAssociatedBusObjectHandleAndIC(h,blkObj,pathItem,busObjHandleMap)
        [designMin,designMax,compiledDT,removeResult]=getCompiledRangeInfo(h,blkObj,blkPathItem)
        [designMin,designMax,compiledDT,removeResult]=getModelCompiledDesignRange(h,~,~)
        pathItems=getPathItems(h,blkObj)
        pathItems=getPortMapping(h,blkObj,inportNum,outportNum)
        [isResolved,slSignalInfo]=getResolvedSLSignal(h,blkObj)
        [srcBlkObj,srcPathItem,srcInfo]=getSourceSignal(h,portObj,isAlreadySrcPort)
        list=hAppendList(h,list,newList)
        sharedLists=hAppendToSharedLists(h,sharedLists,newList)
        cleanBusName=hCleanBusName(h,busName)
        cleanBusName=hCleanDTOPrefix(h,busName)
        sigH=hConstructSigHForBusObject(h,busObjName,busObjHandleMap)
        [busObjHandleAndICList,busObjNameSet]=hGetAllBusObjHandleAndICListFromSigH(h,sigH,ICValue,isNonVirtualBus,busObjHandleMap,busObjNameSet)
        nonVirBus=hIsNonVirtualBus(h,hPort)
        virBus=hIsVirtualBus(h,hPort)
        sharedDTLists=hShareSrcAtSamePort(h,blkObj)
        [sigH,isBus]=hGetBusSignalHierarchy(h,portHandle)
        busObjHandle=hGetBusObjHandleFromMap(h,busObjName,busObjHandleMap)
        hidSrc=hGetHiddenNonVirBusSrc(h,portObj,isAlreadySrcPort)
        [isForBlkParam,blkParamName]=isPathItemForBlockParam(h,srcBlk,pathItem);
        pv=getSettingStrategies(ea,blkObj,pathItem,proposedDT)
    end


    methods(Hidden)
        portsRec=gatherMdlRefBoundarySharedDT(h,blkObj,PathItem)
        actualSrcIDs=getActualSrcIDs(h,blkObj)
        isUnder=isUnderMaskWorkspace(h,blkObj)
        busObjID=hGetAssociatedBusObjElementForLeafSigName(h,busSigHier,busLeafSigName,busObjHandleMap)
        sigH=hGetSigHFromBusObject(this,busName,busObjHandleMap,leafElement)
    end

    methods(Sealed)
        applyProposedScaling(h,blkObj,pathItem,proposedDT)
    end

end



