function[minV,maxV]=gatherDesignMinMax(~,blkObj,~)



    minV=blkObj.Object.Breakpoints.Min;
    maxV=blkObj.Object.Breakpoints.Max;
end