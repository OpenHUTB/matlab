classdef DspSubbandEntityAutoscaler<dvautoscaler.SPCUniDTAutoscaler




    methods
        comments=checkComments(ea,blkObj,pathItem)
        pv=getSettingStrategies(h,blkObj,pathItem,proposedDT)
        prefixStr=getSPCUniDTParamPrefixStr(h,blkObj,pathItem)
        [DTConInfo,comments,paramNames]=gatherSpecifiedDT(h,blkObj,pathItem)
        pathItems=getPathItems(h,blkObj)
        [hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj)
        sharedLists=gatherSharedDT(h,blkObj)
    end

end


