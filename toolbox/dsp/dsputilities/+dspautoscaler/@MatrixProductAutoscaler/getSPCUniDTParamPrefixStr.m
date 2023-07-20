function prefixStr=getSPCUniDTParamPrefixStr(h,blkObj,pathItem)%#ok




    switch pathItem
    case{'Output','1'}
        prefixStr='output';

    case 'Accumulator'
        prefixStr='accum';

    case 'Product output'
        prefixStr='prodOutput';

    case 'Intermediate product'
        prefixStr='interProd';

    otherwise
        prefixStr='';
    end
