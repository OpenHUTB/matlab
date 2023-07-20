function[isForBlkParam,blkParamName]=isPathItemForBlockParam(~,~,pathItem)








    isForBlkParam=false;
    blkParamName='';

    if strcmp(pathItem,'Table')
        isForBlkParam=true;
        blkParamName=pathItem;
    end
end




