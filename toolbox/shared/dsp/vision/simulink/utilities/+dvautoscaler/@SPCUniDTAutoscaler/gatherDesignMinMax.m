function[min,max]=gatherDesignMinMax(h,blkObj,pathItem)





    min=[];
    max=[];

    prefixStr=getSPCUniDTParamPrefixStr(h,blkObj,pathItem);

    if~isempty(prefixStr)

        allBlkDialogParams=fieldnames(blkObj.DialogParameters);
        desMinimumParamStr=strcat(prefixStr,'Min');
        desMaximumParamStr=strcat(prefixStr,'Max');



        if ismember(desMinimumParamStr,allBlkDialogParams)&&~strcmpi(blkObj.(desMinimumParamStr),'[]')
            min=slResolve(blkObj.(desMinimumParamStr),blkObj.getFullName);
        end



        if ismember(desMaximumParamStr,allBlkDialogParams)&&~strcmpi(blkObj.(desMaximumParamStr),'[]')
            max=slResolve(blkObj.(desMaximumParamStr),blkObj.getFullName);
        end
    end


