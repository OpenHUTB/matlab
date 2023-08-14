


classdef SPCUniDTAutoSignAutoscaler<dvautoscaler.SPCUniDTAutoscaler








    methods(Hidden)
        onlyAutoSignedness=areOnlyAutoSignednessFIXDTTypesAllowed(h,blkObj,pathItem)
        [hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj)
    end

end

