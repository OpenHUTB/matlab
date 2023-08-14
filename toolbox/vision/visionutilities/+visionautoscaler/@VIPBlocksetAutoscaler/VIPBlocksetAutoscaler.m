classdef VIPBlocksetAutoscaler<dvautoscaler.SPCBlocksetAutoscaler











    methods
        [wlValueStr,flValueStr,specifiedDTStr,flDlgStr,modeDlgStr,wlDlgStr]=getDTypeInfoForPathItem(~,blkObj,paramPrefixStr,fixdtSignValStr)
        signedValStr=getFirstInportSignedValString(~,blkObj)
        fixdtSignValStr=getInportFixdtSignValStr(h,blkObj,inportIdxList)
    end


    methods(Hidden)
        maskSignValStr=fixdtSignValStr2maskSignValStr(h,fixdtSignValStr)
        fixdtSignValStr=maskSignValStr2fixdtSignValStr(~,maskSignValStr)
        signValStr=valueStr2DescriptionStr(~,fidxtSgValStr)
    end

end

