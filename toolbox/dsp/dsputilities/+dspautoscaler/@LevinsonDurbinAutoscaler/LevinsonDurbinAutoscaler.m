


classdef LevinsonDurbinAutoscaler<dvautoscaler.SPCUniDTAutoscaler












    methods
        [min,max]=gatherDesignMinMax(h,blkObj,pathItem)
        pathItems=getPathItems(h,blkObj)
        pathItems=getPortMapping(h,blkObj,inportNum,outportNum)
        prefixStr=getSPCUniDTParamPrefixStr(h,blkObj,pathItem)
        [hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj);
    end

end

