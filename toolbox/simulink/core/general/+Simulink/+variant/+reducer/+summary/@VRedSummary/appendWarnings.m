function appendWarnings(rpt)




    import mlreportgen.dom.*



    warnMsg=message('Simulink:VariantReducer:ReducerWarnings');
    warnHead=Heading1(warnMsg.getString());
    warnHead.Style={Bold,Color('black'),BackgroundColor('white')};
    append(rpt,warnHead);




    warnContainer=Container();


    idAttr=CustomAttribute('id','warnings');
    warnContainer.CustomAttributes=idAttr;


    warnings=rpt.RepData.Warnings;

    if isempty(warnings)
        notapplicableMsg=message('Simulink:VariantReducer:NotApplicableFields');
        par=Paragraph(notapplicableMsg.getString());
        append(warnContainer,par);
        append(rpt,warnContainer);
        return;
    end

    warnList=UnorderedList();

    for warnId=1:numel(warnings)
        warnMsg=regexprep(warnings{warnId}.message,'<a\s+href\s*=\s*"[^"]*"[^>]*>(.*?)</a>','$1');
        warnText=Text(warnMsg);
        warnText.Style={Color('darkorange')};
        append(warnList,warnText);
    end

    append(warnContainer,warnList);

    append(rpt,warnContainer);
end


