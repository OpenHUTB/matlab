classdef MatrixProductAutoscaler<dvautoscaler.SPCUniDTAutoSignAutoscaler




    methods
        comments=checkComments(ea,blkObj,pathItem)
        pv=getSettingStrategies(h,blkObj,pathItem,proposedDT)
        pathItems=getPathItems(h,blkObj)
        prefixStr=getSPCUniDTParamPrefixStr(h,blkObj,pathItem)
        [hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj)

    end

end

