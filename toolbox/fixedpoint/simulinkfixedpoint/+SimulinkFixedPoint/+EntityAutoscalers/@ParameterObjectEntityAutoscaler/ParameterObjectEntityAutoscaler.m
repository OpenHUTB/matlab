classdef ParameterObjectEntityAutoscaler<SimulinkFixedPoint.EntityAutoscalers.AbstractEntityAutoscaler




    methods
        pv=getSettingStrategies(ea,blkObj,pathItem,proposedDT)
        associateRecords=gatherAssociatedParam(h,blkObj)
        [hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj)
    end


    methods(Hidden)
        [min,max]=gatherDesignMinMax(h,blkObj,pathItem)
        [DTConInfo,Comments,paramNames]=gatherSpecifiedDT(h,blkObj,pathItem)
        busObjHandleAndICList=getAssociatedBusObjectHandleAndIC(h,blkObj,pathItem,busObjHandleMap)
    end

    methods(Static)
        value=resolveParameterObjectValue(parameterObject,parameterName,context)
    end

end


