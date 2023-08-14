function fillInports(obj,chapter)
    import mlreportgen.dom.*
    col1Heading=DAStudio.message('RTW:codeInfo:reportBlockName');

    inports=obj.getDataInterface(obj.CodeInfo.Inports,col1Heading);
    if isempty(inports)
        inports=Paragraph(DAStudio.message('RTW:codeInfo:reportNoInports'));
    end
    chapter.append(inports);
end
