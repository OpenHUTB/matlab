function[min,max]=gatherDesignMinMax(h,blkObj,pathItem)





    switch pathItem
    case{'A','K','P'}
        prefixStr=getSPCUniDTParamPrefixStr(h,blkObj,pathItem);
        minStr=strcat(prefixStr,'Min');
        maxStr=strcat(prefixStr,'Max');



        min=[];
        if~strcmpi(blkObj.(minStr),'[]')
            min=slResolve(blkObj.(minStr),blkObj.getFullName);
        end



        max=[];
        if~strcmpi(blkObj.(maxStr),'[]')
            max=slResolve(blkObj.(maxStr),blkObj.getFullName);
        end

    otherwise
        min=[];
        max=[];
    end


