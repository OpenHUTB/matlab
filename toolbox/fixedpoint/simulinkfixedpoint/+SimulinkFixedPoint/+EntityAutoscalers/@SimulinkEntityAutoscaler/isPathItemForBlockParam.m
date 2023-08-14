function[isForBlkParam,blkParamName]=isPathItemForBlockParam(~,blkObj,pathItem)







    isForBlkParam=false;
    blkParamName='';

    clz=class(blkObj);
    switch clz
    case{'Simulink.Gain'}
        if strcmp(pathItem,'Gain')
            isForBlkParam=true;
            blkParamName=pathItem;
        end
    end
