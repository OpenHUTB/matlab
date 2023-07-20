function[maskSignValStr,wlValueStr,flValueStr,specifiedDTStr,flDlgStr,...
    modeDlgStr,wlDlgStr]=getDataTypeInfoForPathItem(h,blkObj,pathItem)













    fixdtSignValStr='1';
    maskSignValStr='Signed';


    switch pathItem
    case 'Product 1'
        paramPrefixStr='prod1';

    case 'Product 2'
        paramPrefixStr='prod2';

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


