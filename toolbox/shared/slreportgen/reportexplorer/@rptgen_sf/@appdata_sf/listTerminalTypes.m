function tTypes=listTerminalTypes(adSF)





    reportableList=[adSF.TypeTable.isReportable];
    terminalList=~[adSF.TypeTable.isParentable];

    termIdx=find(reportableList&terminalList);
    tTypes={adSF.TypeTable(termIdx).Name}';
