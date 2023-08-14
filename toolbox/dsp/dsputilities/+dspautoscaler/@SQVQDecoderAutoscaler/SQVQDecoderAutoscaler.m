


classdef SQVQDecoderAutoscaler<dvautoscaler.SPCUniDTIndependentOutputAutoscaler









    methods
        [DTConInfo,comments,paramNames]=gatherSpecifiedDT(h,blkObj,pathItem)
        [hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj);
    end


    methods(Hidden)
        [outputPortIndices,outputInitValueMax,outputInitValueMin]=getModelRequiredMinMaxOutputValues(h,blkObj)
    end

end


