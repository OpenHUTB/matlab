function[signValStr,wlValueStr,flValueStr,specifiedDTStr,flDlgStr,...
    modeDlgStr,wlDlgStr]=getDataTypeInfoForPathItem(h,blkObj,pathItem)%#ok




    signValStr='Signed';
    prefixStr=getMaskParamPrefixStrFromPathItem(pathItem);
    if~isempty(prefixStr)
        modeDlgStr=[prefixStr,'Mode'];
    else
        modeDlgStr='mode';
    end
    specifiedDTStr=blkObj.(modeDlgStr);
    wlDlgStr=[prefixStr,'WordLength'];
    flDlgStr=[prefixStr,'FracLength'];

    if(strcmp(specifiedDTStr,'Binary point scaling')||strcmp(specifiedDTStr,'Slope and bias scaling'))
        wlValueStr=blkObj.(wlDlgStr);
        flValueStr=blkObj.(flDlgStr);
    else
        wlValueStr='';
        flValueStr='';
    end

    function prefixStr=getMaskParamPrefixStrFromPathItem(pathItem)
        switch pathItem
        case 'Coefficients'
            prefixStr='firstCoeff';
        case 'Product output'
            prefixStr='prodOutput';
        case 'Accumulator'
            prefixStr='accum';
        case{'Output','1'}
            prefixStr='output';
        case 'Product output polyval'
            prefixStr='interProd';
        case 'Accumulator polyval'
            prefixStr='secondCoeff';
        case 'Multiplicand polyval'
            prefixStr='memory';
        otherwise
            prefixStr='';
        end



