


classdef DCT_FFT_Autoscaler<dvautoscaler.SPCUniDTAutoscaler









    methods
        pathItems=getPathItems(h,blkObj)
        [hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj)
    end


    methods(Hidden)
        sharedLists=gatherSharedDT(h,blkObj)
    end

end

