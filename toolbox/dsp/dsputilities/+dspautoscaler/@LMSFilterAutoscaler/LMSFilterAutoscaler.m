classdef LMSFilterAutoscaler<dvautoscaler.DspEntityAutoscaler





    methods
        sharedLists=gatherSharedDT(h,blkObj)
        [DTConInfo,comments,paramNames]=gatherSpecifiedDT(h,blkObj,pathItem)
        [signValStr,wlValueStr,flValueStr,specifiedDTStr,flDlgStr,modeDlgStr,wlDlgStr]=getDataTypeInfoForPathItem(h,blkObj,pathItem)
        pathItems=getPathItems(h,blkObj)
        pathItems=getPortMapping(h,blkObj,inportNum,outportNum)
        [hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj)
    end

    methods(Hidden)
        [modeDlgStr,wlDlgStr,flDlgStr,skipThisSignal,unknownParam]=...
        getLMSFltMdWLFLDlgPrmInfo(h,pathItem,stepflag,blockAlgorithm)
    end

end


