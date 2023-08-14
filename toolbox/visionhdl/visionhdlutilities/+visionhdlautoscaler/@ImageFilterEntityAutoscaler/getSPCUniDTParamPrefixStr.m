function prefixStr=getSPCUniDTParamPrefixStr(h,blkObj,pathItem)%#ok







    switch pathItem
    case 'dataOut'
        prefixStr='Output';
    case 'Coefficients'
        prefixStr='Coeff';
    otherwise
        prefixStr='';
    end