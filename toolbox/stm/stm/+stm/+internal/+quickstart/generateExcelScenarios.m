function generateExcelScenarios(spreadSheet,sheetArray)






    fmt=matlab.io.spreadsheet.internal.getExtension(spreadSheet);
    wkbk=matlab.io.spreadsheet.internal.createWorkbook(fmt,spreadSheet);

    for indx=2:length(sheetArray)
        wkbk.addSheet(sheetArray{indx},indx-1,sheetArray{1});
    end

    wkbk.save(spreadSheet);
end
