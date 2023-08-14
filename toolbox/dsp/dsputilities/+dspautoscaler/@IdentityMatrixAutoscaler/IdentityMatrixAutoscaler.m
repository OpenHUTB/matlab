


classdef IdentityMatrixAutoscaler<dvautoscaler.SPCUniDTIndependentOutputAutoscaler










    methods
        [DTConInfo,comments,paramNames]=gatherSpecifiedDT(~,blkObj,pathItem)
        result=isDataTypeFullyInherited(h,blkObj,pathItem)
    end


    methods(Hidden)
        [outputPortIndices,outputInitValueMax,outputInitValueMin]=getModelRequiredMinMaxOutputValues(h,blkObj)
    end

end


