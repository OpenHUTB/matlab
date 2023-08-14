function cacheTextContents(this,firstRow,lastRow,showProgress)
    if showProgress
        progressMessage=getString(message('Slvnv:slreq_import:CachingContentsOf',this.sName));
        rmiut.progressBarFcn('set',0.2,progressMessage);
    end

    sheetIdx=this.iSheet;
    colCount=rmidotnet.MSExcel.countColsInSheet(this.hDoc,sheetIdx);
    rangeString=sprintf('%s%d:%s%d','A',firstRow,rmiut.xlsColNumToName(colCount),lastRow);

    if isempty(this.cachedText)
        this.cachedText=cell(lastRow,colCount);
    end

    [~,~,fromXls]=xlsread(this.zFile,sheetIdx,rangeString);
    if showProgress
        rmiut.progressBarFcn('set',0.5,progressMessage);
    end



    [actualRwos,actualCols]=size(fromXls);



    for row=firstRow:lastRow
        for col=1:colCount
            if col>actualCols||row>firstRow+actualRwos-1
                this.cachedText{row,col}='';
            else
                value=fromXls{row-firstRow+1,col};
                if isnan(value)
                    this.cachedText{row,col}='';
                elseif ischar(value)
                    this.cachedText{row,col}=strtrim(value);
                else
                    this.cachedText{row,col}=num2str(value);
                end
            end
        end
        if showProgress&&mod(row,50)==0
            if rmiut.progressBarFcn('isCanceled')
                break;
            end
            fraction=1/2+double(row-firstRow)/double(lastRow-firstRow)/2;
            rmiut.progressBarFcn('set',fraction,progressMessage);
        end
    end
end
