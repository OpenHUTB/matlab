function[signValStr,wlValueStr,flValueStr,specifiedDTStr,flDlgStr,...
    modeDlgStr,wlDlgStr]=getDataTypeInfoForPathItem(h,blkObj,pathItem)%#ok




    signValStr='Signed';
    prefixStr=getMaskParamPrefixStrFromPathItem(pathItem);
    modeDlgStr=[prefixStr,'Mode'];
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
        case 'Accumulator'
            prefixStr='accum';
        case{'Output','1'}
            prefixStr='output';
        otherwise
            prefixStr='';
        end
