function writeInputDataToExcel(datasetFilePath,spreadSheet,sheetName)




    vars=load(datasetFilePath);




    xls.internal.util.writeDatasetToSheet(vars.ds,spreadSheet,sheetName,'',xls.internal.SourceTypes.Input);
end
