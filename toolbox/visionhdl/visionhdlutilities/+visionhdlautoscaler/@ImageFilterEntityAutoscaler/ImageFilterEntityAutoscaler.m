classdef ImageFilterEntityAutoscaler<SimulinkFixedPoint.EntityAutoscalers.SimulinkEntityAutoscaler






    methods
        pv=getSettingStrategies(ea,blkObj,pathItem,proposedDT)
        comment=checkComments(h,blkObj,pathItem)
        [min,max]=gatherDesignMinMax(this,blkObj,pathItem)
        sharedLists=gatherSharedDT(this,blkObj)
        [DTConInfo,comments,paramNames]=gatherSpecifiedDT(this,blkObj,pathItem)
        actualSrcBlkObj=getActualSrcBlkObj(this,blkObj)
        actualSrcIDs=getActualSrcIDs(this,blkObj)
        signednessStr=getInportSignednessString(this,blkObj)
        [designMin,designMax,compiledDT,removeResult]=getModelCompiledDesignRange(this,blkObj,blkPathItem)
        pathItems=getPathItems(this,blkObj)
        pathItems=getPortMapping(this,blkObj,inportNum,outportNum)
        prefixStr=getSPCUniDTParamPrefixStr(this,blkObj,pathItem)
        [specifiedDTStr,udtMaskParamStr]=getSpecifiedSPCUniDTString(this,blkObj,pathItem,varargin)
        isFirstInOut=isBlocksRequireSameDtFirstInputOutput(this,blk)
        sharedListPorts=shareDataForSpecificPorts(this,blk,inportSet,outportSet)
        coefficientsSharing=areCoefficientsSharing(~,blkObj)
    end

end

