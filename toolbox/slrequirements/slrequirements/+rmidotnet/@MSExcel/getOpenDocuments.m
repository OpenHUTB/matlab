function currentlyOpenDocuments=getOpenDocuments(counter)



    currentlyOpenDocuments=cell(0,2);
    excelApp=rmidotnet.MSExcel.application('current');
    if~isempty(excelApp)
        excelDocs=excelApp.Workbooks;
        for i=1:excelDocs.Count
            if nargin==0||i==counter
                activeSheet=Microsoft.Office.Interop.Excel.Worksheet(excelDocs.Item(i).ActiveSheet);
                activeSheetName=activeSheet.Name.char;
                docAndSheetName=[excelDocs.Item(i).Name.char,'|',activeSheetName];
                currentlyOpenDocuments(end+1,:)={docAndSheetName,excelDocs.Item(i).Path.char};%#ok<AGROW>
            end
        end
    end
end
