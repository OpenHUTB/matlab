function appendReducedVariantVariables(rpt)







    import mlreportgen.dom.*


    redContainer=Container();

    redVariantVarsMsg=message('Simulink:VariantReducer:ReducedVariantVars');

    redVariantVarsHeading=Heading2(redVariantVarsMsg.getString());
    redVariantVarsHeading.Style={Bold,Color('black'),BackgroundColor('white')};
    append(redContainer,redVariantVarsHeading);

    reducedVariantVars=rpt.RepData.VariantVariablesReduced;


    idAttr=CustomAttribute('id','reducedVariantVars');
    redContainer.CustomAttributes=idAttr;

    if isempty(reducedVariantVars)
        notapplicableMsg=message('Simulink:VariantReducer:NotApplicableFields');
        par=Paragraph(notapplicableMsg.getString());
        append(redContainer,par);
        append(rpt,redContainer);
        return;
    end


    redVariantVarsAbstract=message('Simulink:VariantReducer:ReducedVariantVarsAbstract');
    abstract=Paragraph(redVariantVarsAbstract.getString());
    abstract.Style={Color('black'),BackgroundColor('white'),FontSize('12pt')};
    idAttr=CustomAttribute('id','reducedvariantvarsabstract');
    abstract.CustomAttributes=idAttr;
    append(redContainer,abstract);


    reducedVariantVarsList=UnorderedList(reducedVariantVars);


    idAttr=CustomAttribute('id','reducedvariantvarslist');
    reducedVariantVarsList.CustomAttributes=idAttr;

    append(redContainer,reducedVariantVarsList);


    append(rpt,redContainer);
end
