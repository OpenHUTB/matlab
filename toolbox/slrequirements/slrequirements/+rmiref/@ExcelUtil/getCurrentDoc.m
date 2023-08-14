function[currentDocName,hExcel,hDoc]=getCurrentDoc()




    hExcel=rmiref.ExcelUtil.getApplication(true);
    hDoc=hExcel.ActiveWorkbook;
    if~isempty(hDoc)
        currentDocName=hDoc.FullName;
    else
        error(message('Slvnv:rmiref:DocCheckExcel:NoCurrentDocument'));
    end
end
