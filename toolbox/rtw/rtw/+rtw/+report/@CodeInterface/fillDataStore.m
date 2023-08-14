function fillDataStore(obj,chapter)
    import mlreportgen.dom.*
    col1Heading=DAStudio.message('RTW:codeInfo:reportDataStoreSource');
    dStores=obj.getDataInterface(obj.CodeInfo.DataStores,col1Heading);
    if isempty(dStores)
        dStores=Paragraph(DAStudio.message('RTW:codeInfo:reportNoDataStores'));
    end
    chapter.append(dStores);
end
