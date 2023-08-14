function fillEntryPointFunctions(obj,chapter)
    import mlreportgen.dom.*
    if isfield(obj.CodeInfo,'expInports')
        expInports=obj.CodeInfo.expInports;
    else
        expInports='';
    end
    codeInfo=obj.CodeInfo;
    [functions,descriptions,semantics]=obj.getFunctions(codeInfo,expInports);
    for k=1:length(functions)
        f=functions(k);
        fcnName=getFcnName(f.Prototype);
        heading=Paragraph(DAStudio.message('RTW:codeInfo:reportFunctionHeading',fcnName));
        chapter.append(heading);
        table=FormalTable(2);

        aTableRow=TableRow();
        aTableRow.append(TableEntry(DAStudio.message('RTW:codeInfo:reportEntryPrototype')));
        fcnDecl=TableEntry(getFunctionDeclaration(f));
        fcnDecl.Style={Bold()};
        aTableRow.append(fcnDecl);
        table.Body.append(aTableRow);

        aTableRow=TableRow();
        aTableRow.append(TableEntry(DAStudio.message('RTW:codeInfo:reportEntryDescription')));
        aTableRow.append(TableEntry(descriptions{k}));
        table.Body.append(aTableRow);

        aTableRow=TableRow();
        aTableRow.append(TableEntry(DAStudio.message('RTW:codeInfo:reportEntryTiming')));
        aTableRow.append(TableEntry(semantics{k}));
        table.Body.append(aTableRow);

        aTableRow=TableRow();
        aTableRow.append(TableEntry(DAStudio.message('RTW:codeInfo:reportEntryArguments')));
        aTableRow.append(TableEntry(obj.getFunctionArguments(f)));
        table.Body.append(aTableRow);

        aTableRow=TableRow();
        aTableRow.append(TableEntry(DAStudio.message('RTW:codeInfo:reportEntryReturnValue')));
        aTableRow.append(TableEntry(obj.getFunctionReturnValue(f)));
        table.Body.append(aTableRow);

        aTableRow=TableRow();
        aTableRow.append(TableEntry(DAStudio.message('RTW:codeInfo:reportEntryHeaderFile')));
        headerFile=f.Prototype.HeaderFile;
        aTableRow.append(TableEntry(headerFile));
        table.Body.append(aTableRow);
        table.StyleName='TableStyleAltRowNormal';
        chapter.append(table);
        chapter.append(Paragraph);
    end
end
