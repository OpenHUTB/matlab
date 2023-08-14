function appendConvertedVariantVariables(rpt)







    import mlreportgen.dom.*


    conContainer=Container();

    conVariantVarsMsg=message('Simulink:VariantReducer:ConvertedVariantVars');

    conVariantVarsHeading=Heading2(conVariantVarsMsg.getString());
    conVariantVarsHeading.Style={Bold,Color('black'),BackgroundColor('white')};
    append(conContainer,conVariantVarsHeading);

    convertedVariantVars=rpt.RepData.VariantVariablesConverted;


    idAttr=CustomAttribute('id','convertedVariantVars');
    conContainer.CustomAttributes=idAttr;

    if isempty(convertedVariantVars)
        notapplicableMsg=message('Simulink:VariantReducer:NotApplicableFields');
        par=Paragraph(notapplicableMsg.getString());
        append(conContainer,par);
        append(rpt,conContainer);
        return;
    end


    conVariantVarsAbstract=message('Simulink:VariantReducer:ConvertedVariantVarsAbstract');
    abstract=Paragraph(conVariantVarsAbstract.getString());
    abstract.Style={Color('black'),BackgroundColor('white'),FontSize('12pt')};
    idAttr=CustomAttribute('id','convertedvariantvarsabstract');
    abstract.CustomAttributes=idAttr;
    append(conContainer,abstract);


    convertedVariantVarsList=UnorderedList(convertedVariantVars);


    idAttr=CustomAttribute('id','convertedvariantvarslist');
    convertedVariantVarsList.CustomAttributes=idAttr;

    append(conContainer,convertedVariantVarsList);


    append(rpt,conContainer);
end
