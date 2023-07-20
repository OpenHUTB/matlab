function fillInterfaceParameters(obj,chapter)
    import mlreportgen.dom.*
    col1Heading=DAStudio.message('RTW:codeInfo:reportParameterSource');
    params=obj.getDataInterface(obj.CodeInfo.Parameters,col1Heading);
    if isempty(params)
        params=Paragraph(DAStudio.message('RTW:codeInfo:reportNoInterfaceParameters'));
    end
    chapter.append(params);
end
