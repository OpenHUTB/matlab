function docPath=currentDocPath()

    docPath='';

    excelApp=rmidotnet.MSExcel.application('current');

    if~isempty(excelApp)
        hDoc=excelApp.ActiveWorkbook;

        if~isempty(hDoc)
            docPath=hDoc.FullName.char;
        end



        [~,~,ext]=fileparts(docPath);
        if isempty(ext)
            docPath='';
        end

    end
end