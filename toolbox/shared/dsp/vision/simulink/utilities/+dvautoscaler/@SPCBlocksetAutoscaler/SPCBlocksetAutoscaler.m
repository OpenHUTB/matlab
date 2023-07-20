classdef SPCBlocksetAutoscaler<SimulinkFixedPoint.EntityAutoscalers.AbstractEntityAutoscaler




    methods
        comment=checkComments(h,blkObj,pathItem)
        pv=getSettingStrategies(h,blkObj,pathItem,proposedDT)
        [levelsUpToTopMask,comment]=checkMaskLinkLevels(h,blkObj)
        records=gatherAssociatedParam(h,blkObj)
        [DTConInfo,comments,paramNames]=gatherSpecifiedDT(h,blkObj,pathItem)
        actualSrcIDs=getActualSrcIDs(h,blkObj)
        [blkObjToBeSet,paramNameToBeSet,comments]=getActualToSetInfo(h,blkObj,levelsUpToTopMask,paramNameOrig)
        comments=getCommentsFromSpecifiedDTStr(h,blkObj,specifiedDTStr,signValueStr,wlValueStr,flValueStr,pathItem)
        [signValStr,wlValueStr,flValueStr,specifiedDTStr,flDlgStr,modeDlgStr,wlDlgStr]=getDataTypeInfoForPathItem(h,blkObj,pathItem)
        [designMin,designMax,compiledDT,removeResult]=getModelCompiledDesignRange(h,blkObj,blkPathItem)
        [outputPortIndices,outputMaxValues,outputMinValues]=getModelRequiredMinMaxOutputValues(h,blkObj)
        pathItems=getPathItems(h,blkObj)
        pathItems=getPortMapping(h,blkObj,inportNum,outportNum)
        [signValStr,wlValueStr,flValueStr,specifiedDTStr,flDlgStr]=getSPCIndependentOutportDataTypeInfo(h,blkObj,supportsUnsigned,maxValue)
        outDataTypeStr=getUDTStrFromFixPtInfo(h,blkObj,signValStr,wlValueStr,varargin)
        result=isDataTypeFracLengthOnlyInherited(h,blkObj,pathItem)
        result=isDataTypeFullyInherited(h,blkObj,pathItem)
        result=isDataTypeStrFracLengthOnlyInherited(h,specifiedDTStr)
        result=isDataTypeStrFullyInherited(h,specifiedDTStr)
    end


    methods(Hidden)
        sharedLists=gatherSharedDT(h,blkObj)
        actualSrcBlkObj=getActualSrcBlkObj(h,blkObj)
    end

end


