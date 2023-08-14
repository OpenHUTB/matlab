classdef WindowFunctionAutoscaler<dvautoscaler.SPCBlocksetAutoscaler





    methods
        comments=checkComments(ea,blkObj,pathItem)
        pv=getSettingStrategies(h,blkObj,pathItem,proposedDT)
        [DTConInfo,comments,paramNames]=gatherSpecifiedDT(h,blkObj,pathItem)
        [outputPortIndices,outputMaxValues,outputMinValues]=getModelRequiredMinMaxOutputValues(h,blkObj)
        pathItems=getPathItems(h,blkObj)
        pathItems=getPortMapping(h,blkObj,inportNum,outportNum)
        [hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj)
        [signValStr,wlValueStr,flValueStr,specifiedDTStr,flDlgStr,modeDlgStr,wlDlgStr]=getDataTypeInfoForPathItem(h,blkObj,pathItem)
    end

end


