classdef LDLFactorizationAutoscaler<dvautoscaler.SPCUniDTAutoscaler











    methods
        pathItems=getPathItems(h,blkObj)
        prefixStr=getSPCUniDTParamPrefixStr(h,blkObj,pathItem)
        [hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj)
    end

end
