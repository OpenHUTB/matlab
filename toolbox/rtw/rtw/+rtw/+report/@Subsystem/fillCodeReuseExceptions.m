function fillCodeReuseExceptions(obj,chapter)
    import mlreportgen.dom.*
    if~isempty(obj.ReuseDiag)
        obj.appendRptgenReuseExceptions(chapter);
    else
        aText=Text(DAStudio.message('RTW:report:ReuseExceptionNone'));
        aText.Style={Bold()};
        aParagraph=Paragraph;
        aParagraph.append(aText);
        chapter.append(aParagraph);
    end
end
