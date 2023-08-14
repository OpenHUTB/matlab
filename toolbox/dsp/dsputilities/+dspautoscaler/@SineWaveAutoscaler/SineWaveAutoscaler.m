


classdef SineWaveAutoscaler<dvautoscaler.SPCUniDTIndependentOutputAutoscaler










    methods
        [hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj)
        [DTConInfo,comments,paramNames]=gatherSpecifiedDT(~,blkObj,pathItem)
    end


    methods(Hidden)
        [outputPortIndices,outputInitValueMax,outputInitValueMin]=getModelRequiredMinMaxOutputValues(h,blkObj)
    end

end


