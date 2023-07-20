function[signValStr,wlValueStr,flValueStr,specifiedDTStr,flDlgStr,...
    modeDlgStr,wlDlgStr]=getDataTypeInfoForPathItem(h,blkObj,pathItem)





    allBlkDialogParams=fieldnames(blkObj.DialogParameters);

    switch pathItem
    case 'Input-squared product'
        if ismember('prodOutputMode',allBlkDialogParams)
            prefixStr='prodOutput';
        end
    case 'Input-sum-squared product'
        if ismember('memoryMode',allBlkDialogParams)
            prefixStr='memory';
        end
    case 'Accumulator'
        if ismember('accumMode',allBlkDialogParams)
            prefixStr='accum';
        end
    case 'Output'
        if ismember('outputMode',allBlkDialogParams)
            prefixStr='output';
        end
    otherwise
        prefixStr='';
    end

    signValStr='';
    wlValueStr='';
    flValueStr='';
    specifiedDTStr='';
    flDlgStr='';
    wlDlgStr='';
    modeDlgStr='';

    if~isempty(prefixStr)
        modeDlgStr=strcat(prefixStr,'Mode');
        wlDlgStr=strcat(prefixStr,'WordLength');
        flDlgStr=strcat(prefixStr,'FracLength');
        specifiedDTStr=blkObj.(modeDlgStr);

        if isempty(regexp(specifiedDTStr,'^(Inherit |Inherit:|Same as|Same word|Smallest )','ONCE'))

            wlValueStr=blkObj.(wlDlgStr);
            flValueStr=blkObj.(flDlgStr);

            signValStr=h.getInportSignednessString(blkObj);

            if strcmpi(signValStr,'Unsigned')
                specifiedDTStr=sprintf('fixdt(0,%s,%s)',wlValueStr,flValueStr);
            elseif strcmpi(signValStr,'Signed')
                specifiedDTStr=sprintf('fixdt(1,%s,%s)',wlValueStr,flValueStr);
            else
                specifiedDTStr=sprintf('fixdt([],%s,%s)',wlValueStr,flValueStr);
            end
        end
    end




