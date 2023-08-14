function prefixStr=getSPCUniDTParamPrefixStr(h,blkObj,pathItem)%#ok




    switch pathItem
    case{'Output','1'}
        prefixStr='output';

    case 'Accumulator'
        prefixStr='accum';

    otherwise
        prefixStr='';
    end
