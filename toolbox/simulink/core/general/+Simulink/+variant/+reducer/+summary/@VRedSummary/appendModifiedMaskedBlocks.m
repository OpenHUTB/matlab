function appendModifiedMaskedBlocks(rpt)






    import mlreportgen.dom.*


    modContainer=Container();
    mskHeadMsg=message('Simulink:VariantReducer:MaskModified');
    modBlksHeading=Heading2(mskHeadMsg.getString());
    modBlksHeading.Style={Bold,Color('black'),BackgroundColor('white')};
    append(modContainer,modBlksHeading);


    modifiedBlocks=rpt.RepData.MaskedBlocksModified;


    idAttr=CustomAttribute('id','modifiedMasks');
    modContainer.CustomAttributes=idAttr;


    if isempty(modifiedBlocks)
        notapplicableMsg=message('Simulink:VariantReducer:NotApplicableFields');
        par=Paragraph(notapplicableMsg.getString());
        append(modContainer,par);
        append(rpt,modContainer);
        return;
    end


    modBlkAbstract=message('Simulink:VariantReducer:BlocksMaskModAbstract');
    abstract=Paragraph(modBlkAbstract.getString());
    abstract.Style={Color('black'),BackgroundColor('white'),FontSize('12pt')};
    idAttr=CustomAttribute('id','abstract');
    abstract.CustomAttributes=idAttr;
    append(modContainer,abstract);


    modTable=Table(2);


    blkHeading=message('Simulink:VariantReducer:BlockTableHeading');
    col1Heading=TableEntry(blkHeading.getString());
    delParamHeading=message('Simulink:VariantReducer:DeletedParams');
    col2Heading=TableEntry(delParamHeading.getString());

    tbHeaderRow=TableRow();
    append(tbHeaderRow,col1Heading);
    append(tbHeaderRow,col2Heading);

    tbHeaderRow.Style={Bold,FontSize('12pt')};

    idAttr=CustomAttribute('id','masktableHeaderRow');
    tbHeaderRow.CustomAttributes=idAttr;
    append(modTable,tbHeaderRow);


    for blkId=1:numel(modifiedBlocks)

        tableRowObj=TableRow();



        blockHandle=get_param(modifiedBlocks(blkId).BlockPath,'Handle');
        blockText=Text(modifiedBlocks(blkId).BlockPath);
        blockLink=createElementTwoWayLink(rpt,blockHandle,blockText,'model2');
        col1Entry=TableEntry(blockLink);

        idAttr=CustomAttribute('id',['maskrow',num2str(blkId),'col1']);
        col1Entry.CustomAttributes=idAttr;

        remParamList=UnorderedList(modifiedBlocks(blkId).DeletedParams);
        col2Entry=TableEntry(remParamList);

        idAttr=CustomAttribute('id',['maskrow',num2str(blkId),'col2']);
        col2Entry.CustomAttributes=idAttr;


        tableRowObj.Style={FontSize('12pt')};


        append(tableRowObj,col1Entry);
        append(tableRowObj,col2Entry);


        idAttr=CustomAttribute('id',['maskrow',num2str(blkId)]);
        tableRowObj.CustomAttributes=idAttr;


        append(modTable,tableRowObj);
    end



    modTable.Border='solid';
    modTable.BorderWidth='2px';
    modTable.ColSep='solid';
    modTable.ColSepWidth='1';
    modTable.RowSep='solid';
    modTable.RowSepWidth='1';
    modTable.TableEntriesHAlign='center';
    modTable.TableEntriesVAlign='middle';

    append(modContainer,modTable);

    append(rpt,modContainer);
end


