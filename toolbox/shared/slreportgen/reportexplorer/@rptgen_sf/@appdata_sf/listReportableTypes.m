function rTypes=listReportableTypes(adSF)





    reportableList=[adSF.TypeTable.isReportable];
    rIdx=find(reportableList);
    rTypes={adSF.TypeTable(rIdx).Name}';
