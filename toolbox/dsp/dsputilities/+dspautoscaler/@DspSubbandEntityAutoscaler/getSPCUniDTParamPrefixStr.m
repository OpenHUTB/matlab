function prefixStr=getSPCUniDTParamPrefixStr(h,blkObj,pathItem)%#ok




    switch pathItem
    case 'Output'
        prefixStr='output';
    case 'Accumulator'
        prefixStr='accum';
    case 'Product output'
        prefixStr='prodOutput';
    case 'FirstCoeff'
        prefixStr='firstCoeff';
    otherwise
        prefixStr='';
    end


