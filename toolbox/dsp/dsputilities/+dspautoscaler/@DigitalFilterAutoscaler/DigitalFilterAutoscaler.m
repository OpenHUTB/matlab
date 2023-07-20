classdef DigitalFilterAutoscaler<dvautoscaler.DspEntityAutoscaler




    methods
        comments=checkComments(h,blkObj,pathItem)
        [DTConInfo,comments,paramNames]=gatherSpecifiedDT(h,blkObj,pathItem)
        result=showState(h,blkObj)
        associateRecords=gatherAssociatedParam(h,blkObj)
        coeffSourceNames=getCoefficientPropertyNames(h,blkObj)
        pathItems=getPathItems(h,blkObj)
        [hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj)
    end

end


