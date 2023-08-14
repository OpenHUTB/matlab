function varsLoaded=loadExcelFile(inputFilePath,excelSheets)



    if(nargin<2)
        excelSheets={};
    end
    varsLoaded={};

    exl=iofile.ExcelFile(inputFilePath);
    if~isempty(excelSheets)
        for i=1:length(excelSheets)
            exl.loadAVariable(excelSheets{i});
            varsLoaded{end+1}=excelSheets{i};%#ok<AGROW>
        end
    else
        exl.load();
        sheets=exl.whos();
        for i=1:length(sheets)
            varsLoaded{end+1}=sheets(i).name;%#ok<AGROW>
        end
    end
end