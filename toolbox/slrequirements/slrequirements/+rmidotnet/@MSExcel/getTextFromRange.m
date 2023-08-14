function textFromCells=getTextFromRange(docObj,rowRange,colRange)







    if ischar(docObj)
        docObj=rmidotnet.docUtilObj(docObj);
    end

    if isempty(docObj)


        textFromCells={};
        return;
    end

    isUI=length(rowRange)>1&&rowRange(end)>10&&~isempty(slreq.import.ui.dlg_mgr('get'));
    if isUI
        progressMessage=getString(message('Slvnv:slreq_import:GeneratingHeaderPreview',docObj.sName));
        rmiut.progressBarFcn('set',0.1,progressMessage);
    end

    if isempty(docObj.iSheet)
        sheetIdx=docObj.getActiveSheet();
    else
        sheetIdx=docObj.iSheet;
    end
    mySheet=Microsoft.Office.Interop.Excel.Worksheet(docObj.hDoc.Worksheets.Item(sheetIdx));
    textFromCells=cell(rowRange(end)-rowRange(1)+1,colRange(end)-colRange(1)+1);
    for row=rowRange(1):rowRange(end)
        localRow=row-rowRange(1)+1;
        oneRow=Microsoft.Office.Interop.Excel.Range(mySheet.Rows.Item(row));
        for col=colRange(1):colRange(end)
            oneCell=Microsoft.Office.Interop.Excel.Range(oneRow.Cells.Item(col));
            localCol=col-colRange(1)+1;
            textFromCells{localRow,localCol}=strtrim(oneCell.Text.char);
        end
        if isUI&&mod(localRow,5)==0
            fraction=localRow/(rowRange(end)-rowRange(1));
            rmiut.progressBarFcn('set',fraction,progressMessage);
        end
    end

    if isUI
        rmiut.progressBarFcn('delete');
    end
end
