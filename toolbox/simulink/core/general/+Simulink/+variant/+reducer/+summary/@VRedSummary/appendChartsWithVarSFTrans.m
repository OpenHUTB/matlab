function appendChartsWithVarSFTrans(rpt)





    import mlreportgen.dom.*


    sfHeadMsg=message('Simulink:VariantReducer:VariantSFTransitions');
    sfHead=Heading2(sfHeadMsg.getString());
    sfHead.Style={Bold,Color('black'),BackgroundColor('white')};
    append(rpt,sfHead);


    sfAbstractMsg=message('Simulink:VariantReducer:VarSFTransNotSupported');
    sfAbstract=Paragraph(sfAbstractMsg.getString());
    sfAbstract.Style={Color('black'),BackgroundColor('white'),FontSize('12pt')};
    idAttr=CustomAttribute('id','varsftransabstract');
    sfAbstract.CustomAttributes=idAttr;
    append(rpt,sfAbstract);

    sfChartContainer=Container();
    idAttr=CustomAttribute('id','sfchartblocks');
    sfChartContainer.CustomAttributes=idAttr;


    sfBlksHeadMsg=message('Simulink:VariantReducer:StateflowChartBlocks');
    sfBlksHead=Heading3(sfBlksHeadMsg.getString());
    sfBlksHead.Style={Color('black'),BackgroundColor('white')};
    idAttr=CustomAttribute('id','sfchartlimitationabstract');
    sfBlksHead.CustomAttributes=idAttr;
    append(sfChartContainer,sfBlksHead);



    sfChartsWithVarTrans=rpt.RepData.SFChartContainingVariantTrans;
    if isempty(sfChartsWithVarTrans)
        notApplicableMsg=message('Simulink:VariantReducer:NotApplicableFields');
        notApplicable=Paragraph(notApplicableMsg.getString());
        append(sfChartContainer,notApplicable);
    else
        fillSFCharts(rpt,sfChartContainer,sfChartsWithVarTrans);
    end

    append(rpt,sfChartContainer);

end

function fillSFCharts(rpt,sfChartContainer,sfChartsWithVarTrans)

    import mlreportgen.dom.*


    sfChartList=UnorderedList();
    for blockId=1:numel(sfChartsWithVarTrans)

        blockH=sfChartsWithVarTrans(blockId);
        blockText=mlreportgen.dom.Text(getfullname(blockH));
        blockLink=createElementTwoWayLink(rpt,blockH,blockText,'model2');
        append(sfChartList,blockLink);
    end


    idAttr=CustomAttribute('id','sfchartlist');
    sfChartList.CustomAttributes=idAttr;

    append(sfChartContainer,sfChartList);

end


