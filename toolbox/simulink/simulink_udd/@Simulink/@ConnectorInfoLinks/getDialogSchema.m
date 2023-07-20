function dlgstruct=getDialogSchema(this,~)

    rowTotal=0;
    dlgstruct.Items=cell(1,0);

    singlePanel=createNonTogglePanel(this);
    rowTotal=rowTotal+length(singlePanel.Items);
    dlgstruct.Items=[dlgstruct.Items,singlePanel.Items];


    dlgstruct.LayoutGrid=[rowTotal,3];
    dlgstruct.DialogTitle='Connector Info';
    dlgstruct.StandaloneButtonSet={''};
    if rowTotal<10
        dlgstruct.IsScrollable=false;
    else
        dlgstruct.IsScrollable=true;
    end
    dlgstruct.Transient=true;
    dlgstruct.DialogStyle='frameless';
    dlgstruct.MinimalApply=true;
    dlgstruct.ExplicitShow=true;
    dlgstruct.Spacing=10;
end



function singlePanel=createNonTogglePanel(infoObj)

    numInnerRows=0;
    singlePanel.Items=cell(1,0);
    [singlePanel,numInnerRows]=addBlockListsToPanel(singlePanel,numInnerRows,infoObj);
    singlePanel.ContentsMargins=[2,2,2,2];
    singlePanel.Spacing=10;

end



function heading=createHeadingRow(headingStr,row)


    heading=cell(1,3);

    heading{1}.Type='text';
    heading{1}.Name=' ';
    heading{1}.RowSpan=[row,row];
    heading{1}.ColSpan=[1,1];


    heading{2}.Name=headingStr;
    heading{2}.Type='text';
    heading{2}.RowSpan=[row,row];
    heading{2}.ColSpan=[2,2];
    heading{2}.Alignment=1;
    heading{2}.Bold=true;

    heading{3}.Type='text';
    heading{3}.Name=' ';
    heading{3}.RowSpan=[row,row];
    heading{3}.ColSpan=[3,3];

end



function blockLink=createBlockLinkRow(blkHandle,row)


    blockLink=cell(1,3);

    blockLink{1}.Type='text';
    blockLink{1}.Name=' ';
    blockLink{1}.RowSpan=[row,row];
    blockLink{1}.ColSpan=[1,1];


    blockLink{2}.Name=getfullname(blkHandle);
    blockLink{2}.Type='hyperlink';
    blockLink{2}.ObjectMethod='hiliteBlockCB';
    blockLink{2}.MethodArgs={blkHandle};
    blockLink{2}.ArgDataTypes={'double'};
    blockLink{2}.RowSpan=[row,row];
    blockLink{2}.ColSpan=[2,2];
    blockLink{2}.Alignment=1;

    blockLink{3}.Type='text';
    blockLink{3}.Name=' ';
    blockLink{3}.RowSpan=[row,row];
    blockLink{3}.ColSpan=[3,3];

end



function[blockList,innerRow]=addToBlockList(headingStr,blocks,innerRow)



    innerRow=innerRow+1;
    blockList={};
    blockList=[blockList,createHeadingRow(headingStr,innerRow)];

    for k=1:length(blocks)
        innerRow=innerRow+1;
        blkHandle=blocks(k);
        blockList=[blockList,createBlockLinkRow(blkHandle,innerRow)];%#ok
    end
end



function[blockList,innerRow]=addBlankRow(innerRow)

    innerRow=innerRow+1;
    blockList={};

    blankRow.Type='text';
    blankRow.Name=' ';
    blankRow.ColSpan=[1,3];
    blankRow.RowSpan=[innerRow,innerRow];
    blockList=[blockList,blankRow];
end


function[retPanel,numInnerRows]=addBlockListsToPanel(singlePanel,numInnerRows,infoObj)


    fieldNames={'OriginalOwners',...
    'OriginalReaders',...
    'OriginalWriters',...
    'OriginalReaderWriters'};

    headingStrs={'',...
    'Reader Blocks',...
    'Writer Blocks',...
    'Reader & Writer Blocks'};

    switch infoObj.ConnectorType
    case 'State'
        headingStrs{1}='State Owner Blocks';
    case 'Parameter'
        headingStrs{1}='Parameter Owner Blocks';
    case 'DataStore'
        headingStrs{1}='Data Store Memory Blocks';
    end

    [moreList,numInnerRows]=addBlankRow(numInnerRows);
    singlePanel.Items=[singlePanel.Items,moreList];

    for k=1:length(fieldNames)
        blocks=infoObj.(fieldNames{k});
        if~isempty(blocks)
            [moreList,numInnerRows]=...
            addToBlockList(headingStrs{k},blocks,numInnerRows);
            singlePanel.Items=[singlePanel.Items,moreList];
        end
    end

    [moreList,numInnerRows]=addBlankRow(numInnerRows);
    singlePanel.Items=[singlePanel.Items,moreList];

    retPanel=singlePanel;
end
