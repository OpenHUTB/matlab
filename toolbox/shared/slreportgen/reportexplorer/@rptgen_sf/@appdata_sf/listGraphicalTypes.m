function tTypes=listGraphicalTypes(adSF)





    reportableList=[adSF.TypeTable.isReportable];
    graphicalList=[adSF.TypeTable.isGraphical];

    gIdx=find(reportableList&graphicalList);
    tTypes={adSF.TypeTable(gIdx).Name}';
