classdef SPCUniDTAutoscaler<dvautoscaler.SPCBlocksetAutoscaler





    methods
        comment=checkComments(h,blkObj,pathItem)
        pv=getSettingStrategies(h,blkObj,pathItem,proposedDT)
        onlyAutoSignedness=areOnlyAutoSignednessFIXDTTypesAllowed(h,blkObj,pathItem)
        [min,max]=gatherDesignMinMax(h,blkObj,pathItem)
        [DTConInfo,comments,paramNames]=gatherSpecifiedDT(h,blkObj,pathItem)
        signednessStr=getInportSignednessString(h,blkObj)
        pathItems=getPathItems(h,blkObj)
        prefixStr=getSPCUniDTParamPrefixStr(h,blkObj,pathItem)
        [specifiedDTStr,udtMaskParamStr]=getSpecifiedSPCUniDTString(h,blkObj,pathItem,varargin)
    end

end


