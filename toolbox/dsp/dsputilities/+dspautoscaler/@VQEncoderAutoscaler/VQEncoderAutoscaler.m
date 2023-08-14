classdef VQEncoderAutoscaler<dvautoscaler.DspEntityAutoscaler













    methods
        pathItems=getPathItems(h,blkObj)
        pathItems=getPortMapping(h,blkObj,inportNum,outportNum)
        [hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj)
        [DTConInfo,comments,paramNames]=gatherSpecifiedDT(h,blkObj,pathItem)
    end

end


