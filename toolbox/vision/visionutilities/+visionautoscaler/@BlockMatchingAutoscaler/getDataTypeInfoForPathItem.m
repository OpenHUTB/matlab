function[signValStr,wlValueStr,flValueStr,specifiedDTStr,flDlgStr,...
    modeDlgStr,wlDlgStr]=getDataTypeInfoForPathItem(h,blkObj,pathItem)%#ok





    allBlkDialogParams=fieldnames(blkObj.DialogParameters);

    switch pathItem
    case{'Output','Gradients'}
        if ismember('outputMode',allBlkDialogParams)
            prefixStr='output';
        end

    case 'Accumulator'
        if ismember('accumMode',allBlkDialogParams)
            prefixStr='accum';
        end

    case 'Product output'
        if ismember('prodOutputMode',allBlkDialogParams)
            prefixStr='prodOutput';
        end
    end

    signValStr='Signed';
    wlValueStr='';
    flValueStr='';
    specifiedDTStr='';
    flDlgStr='';
    wlDlgStr='';
    modeDlgStr='';

    if~isempty(prefixStr)
        modeDlgStr=strcat(prefixStr,'Mode');
        specifiedDTStr=blkObj.(modeDlgStr);
        wlDlgStr=strcat(prefixStr,'WordLength');


        if strcmpi(modeDlgStr,'stageIOMode')
            if strcmpi(pathItem,'Section input')
                flDlgStr='stageInFracLength';
            else
                flDlgStr='stageOutFracLength';
            end
        else

            flDlgStr=strcat(prefixStr,'FracLength');
        end

        if isempty(regexp(specifiedDTStr,'^(Inherit |Inherit:|Same as|Same word|Smallest )','ONCE'))

            wlValueStr=blkObj.(wlDlgStr);

            if strcmpi(specifiedDTStr,'Specify word length')

                flValueStr='Best precision';
                specifiedDTStr=sprintf('fixdt(1,%s)',wlValueStr);
            else

                flValueStr=blkObj.(flDlgStr);
                specifiedDTStr=sprintf('fixdt(1,%s,%s)',wlValueStr,flValueStr);
            end
        end
    end


