function prefixStr=getSPCUniDTParamPrefixStr(h,blkObj,pathItem)%#ok




    switch pathItem
    case 'Product output'
        prefixStr='prodOutput';
    case 'Accumulator'
        prefixStr='accum';
    case 'A'
        prefixStr='firstCoeff';
    case 'K'
        prefixStr='secondCoeff';
    case 'P'
        prefixStr='output';
    otherwise
        prefixStr='';
    end
