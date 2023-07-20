function[isForBlkParam,blkParamName]=isPathItemForBlockParam(~,~,pathItem)








    isForBlkParam=false;
    blkParamName='';

    if strcmp(pathItem,'Breakpoint')
        isForBlkParam=true;
        blkParamName='BreakpointsData';
    end
end




