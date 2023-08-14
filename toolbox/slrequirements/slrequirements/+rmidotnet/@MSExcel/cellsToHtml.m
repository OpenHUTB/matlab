function html=cellsToHtml(this,rowRange,colRange)



    if rowRange(1)==rowRange(end)&&colRange(1)==colRange(end)

        html=rmiut.plainToHtml(this.getTextFromCell(rowRange(1),colRange(1)));
    else
        cellsText=this.getTextFromCells(rowRange,colRange);
        numRows=size(cellsText,1);
        numCols=size(cellsText,2);

        text=cell(numRows,numCols);
        isNotEmpty=false(numRows,numCols);
        for row=1:numRows
            for col=1:numCols
                oneText=strtrim(cellsText{row,col});
                if isempty(oneText)
                    text{row,col}='&nbsp;';
                else
                    text{row,col}=rmiut.plainToHtml(oneText);
                    isNotEmpty(row,col)=true;
                end
            end
        end
        switch sum(sum(isNotEmpty))
        case 0
            html='';
        case 1
            html=text{isNotEmpty};
        otherwise
            html=slreq.import.html.table([],text,'border=1 cellpadding="5"');
        end
    end
end
