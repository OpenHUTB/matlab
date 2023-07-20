function[maskSignValStr,wlValueStr,flValueStr,specifiedDTStr,flDlgStr,...
    modeDlgStr,wlDlgStr]=getDataTypeInfoForPathItem(h,blkObj,pathItem)




    maskSignValStr='Signed';
    fixdtSignValStr='1';


    switch pathItem
    case 'Product output'
        paramPrefixStr='prodOutput';

    case 'Accumulator'
        paramPrefixStr='accum';

    case 'Centroid output'
        paramPrefixStr='output';

    case 'Equiv Diam^2 output'
        paramPrefixStr='memory';

    case 'Extent output'
        paramPrefixStr='firstCoeff';

    case 'Perimeter output'
        paramPrefixStr='secondCoeff';

    otherwise





        wlValueStr='';
        flValueStr='';
        flDlgStr='';
        specifiedDTStr='';
        modeDlgStr='';
        wlDlgStr='';
        return;

    end

    [wlValueStr,flValueStr,specifiedDTStr,flDlgStr,modeDlgStr,wlDlgStr]=...
    getDTypeInfoForPathItem(h,blkObj,paramPrefixStr,fixdtSignValStr);


