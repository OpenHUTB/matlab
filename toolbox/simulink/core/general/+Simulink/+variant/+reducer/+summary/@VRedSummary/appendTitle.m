function appendTitle(rpt)








    import mlreportgen.dom.*




    model=getExportModels(rpt,'model2');



    model=model{1};



    titleMsg=message('Simulink:VariantReducer:SummaryTitle',model);
    title=Paragraph(titleMsg.getString());
    title.Style={Bold,Color('black'),BackgroundColor('white'),FontSize('30pt')};
    idAttr=CustomAttribute('id','title');
    title.CustomAttributes=idAttr;
    append(rpt,title);



    abstractMsg=message('Simulink:VariantReducer:Abstract');
    abstract=Paragraph(abstractMsg.getString());
    abstract.Style={Color('black'),BackgroundColor('white'),FontSize('12pt')};
    idAttr=CustomAttribute('id','abstract');
    abstract.CustomAttributes=idAttr;
    append(rpt,abstract);

    origMdlMsg=message('Simulink:VariantReducer:OrigModelTitle',rpt.RepData.OrigTopModelName);
    origMdlNamePar=Paragraph(origMdlMsg.getString());
    origMdlNamePar.Style={Color('black'),BackgroundColor('white'),FontSize('12pt')};
    idAttr=CustomAttribute('id','origModelName');
    origMdlNamePar.CustomAttributes=idAttr;
    append(rpt,origMdlNamePar);

    redMdlMsg=message('Simulink:VariantReducer:ReducedModelTitle',model);
    redMdlNamePar=Paragraph(redMdlMsg.getString());
    redMdlNamePar.Style={Color('black'),BackgroundColor('white'),FontSize('12pt')};
    idAttr=CustomAttribute('id','redModelName');
    redMdlNamePar.CustomAttributes=idAttr;
    append(rpt,redMdlNamePar);
end


