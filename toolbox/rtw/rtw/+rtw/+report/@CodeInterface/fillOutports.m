function fillOutports(obj,chapter)
    import mlreportgen.dom.*
    col1Heading=DAStudio.message('RTW:codeInfo:reportBlockName');
    outports=obj.getDataInterface(obj.CodeInfo.Outports,col1Heading);
    if isempty(outports)
        outports=Paragraph(DAStudio.message('RTW:codeInfo:reportNoOutports'));
    end
    chapter.append(outports);
end
