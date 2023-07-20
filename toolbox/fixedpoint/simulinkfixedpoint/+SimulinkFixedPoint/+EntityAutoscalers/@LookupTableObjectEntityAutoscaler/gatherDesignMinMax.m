function[minV,maxV]=gatherDesignMinMax(h,blkObj,pathItem)




    if strcmp(pathItem,'Table')
        minV=blkObj.Object.Table.Min;
        maxV=blkObj.Object.Table.Max;
    else


        index=h.getIndexFromBreakpointPathitem(pathItem);
        minV=blkObj.Object.Breakpoints(index).Min;
        maxV=blkObj.Object.Breakpoints(index).Max;
    end
end


