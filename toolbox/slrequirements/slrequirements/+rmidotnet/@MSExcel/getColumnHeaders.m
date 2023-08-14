function[headersRow,headersText]=getColumnHeaders(docPath,sheetNameOrIdx)






    docObj=rmidotnet.docUtilObj(docPath);

    if nargin<2
        sheetNameOrIdx=rmidotnet.MSExcel.getActiveSheetInWorkbook(docObj);
    end

    if ischar(sheetNameOrIdx)
        sheetNames=docObj.getSheetNames();
        isMatchedSheetName=strcmp(sheetNames,sheetNameOrIdx);
        if any(isMatchedSheetName)
            docObj.iSheet=find(isMatchedSheetName);
        else
            error(['Sheet name ',sheetNameOrIdx,' not found in ',docPath]);
        end
    else
        docObj.iSheet=sheetNameOrIdx;
    end


    mySheet=Microsoft.Office.Interop.Excel.Worksheet(docObj.hDoc.Worksheets.Item(docObj.iSheet));

    doShowProgress=~isempty(slreq.import.ui.dlg_mgr('get'));
    if doShowProgress
        showProgress(0,mySheet.Name.char);
    end

    usedRows=mySheet.UsedRange.Rows;
    totalRows=usedRows.Count;
    headersRow=-1;

    usedCols=mySheet.UsedRange.Columns;
    totalCols=usedCols.Count;

    headersText=cell(1,totalCols);
    lastRow=30;
    row=1;
    rowCounts=zeros(1,lastRow);

    docObj.cacheTextContents(1,lastRow,doShowProgress);
    lastNonEmptyCol=zeros(lastRow,1);
    while row<totalRows&&row<lastRow
        isNotEmpty=true(1,totalCols);
        for col=1:totalCols
            oneCellText=docObj.cachedText{row,col};
            if isempty(oneCellText)
                isNotEmpty(col)=false;
            else
                lastNonEmptyCol(row)=col;
            end
        end

        rowCounts(row)=getSolidLength(isNotEmpty);
        if rowCounts(row)==totalCols
            break;
        end
        row=row+1;
        if doShowProgress&&mod(row,5)==0
            showProgress(double(row)/lastRow,mySheet.Name.char);
        end
    end




    if totalCols>max(lastNonEmptyCol)
        totalCols=max(lastNonEmptyCol);
    end


    bestCount=max(rowCounts);
    if bestCount>=totalCols-1
        bestIdx=find(rowCounts==bestCount);
        headersRow=bestIdx(1);
        headersText=docObj.cachedText(headersRow,1:totalCols);
    end

    if doShowProgress
        rmiut.progressBarFcn('delete');
    end
end

function count=getSolidLength(isNotEmpty)
    idx=find(isNotEmpty);
    if isempty(idx)
        count=0;
    else
        check=isNotEmpty(idx(1):idx(end));
        if all(check)
            count=length(idx);
        else
            count=0;
        end
    end
end

function showProgress(fraction,sheetName)
    rmiut.progressBarFcn('set',0.3+fraction/2,...
    getString(message('Slvnv:slreq_import:ProcessingContentOf',sheetName)));
end
