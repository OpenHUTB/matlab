function prefixStr=getSPCUniDTParamPrefixStr(h,blkObj,pathItem)%#ok









    switch pathItem
    case{'Output','1'}
        prefixStr='output';

    case{'Accumulator','Numerator accumulator'}
        prefixStr='accum';

    case{'Product output','Numerator product output'}
        prefixStr='prodOutput';

    case{'State','Memory'}
        prefixStr='memory';

    case{'FirstCoeff','Numerator coefficients','Coefficients'}
        prefixStr='firstCoeff';

    case{'SecondCoeff','Denominator coefficients'}
        prefixStr='secondCoeff';

    case 'Intermediate product'
        prefixStr='interProd';

    case 'Multiplicand'
        prefixStr='multiplicand';

    otherwise
        prefixStr='';
    end



    if~isempty(prefixStr)
        fullMaskParamStr=strcat(prefixStr,'DataTypeStr');
        allBlkDialogParams=fieldnames(blkObj.DialogParameters);
        if~ismember(fullMaskParamStr,allBlkDialogParams)
            prefixStr='';
        end
    end


